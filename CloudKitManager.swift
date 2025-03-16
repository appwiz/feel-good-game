import Foundation
import CloudKit
import Combine

// Define a struct to hold game state data
struct GameStateData {
    let score: Int
    let flowersSeen: Int
    let interval: Double
    let lastModified: Date
    
    init(score: Int, flowersSeen: Int, interval: Double, lastModified: Date = Date()) {
        self.score = score
        self.flowersSeen = flowersSeen
        self.interval = interval
        self.lastModified = lastModified
    }
    
    // Create from CloudKit record
    init(record: CKRecord) {
        self.score = record["score"] as? Int ?? 0
        self.flowersSeen = record["flowersSeen"] as? Int ?? 0
        self.interval = record["interval"] as? Double ?? 2.0
        self.lastModified = record["lastModified"] as? Date ?? Date()
    }
    
    // Merge with another state, taking the higher values for score and flowers
    func mergeWith(_ other: GameStateData) -> GameStateData {
        return GameStateData(
            score: max(self.score, other.score),
            flowersSeen: max(self.flowersSeen, other.flowersSeen),
            interval: other.lastModified > self.lastModified ? other.interval : self.interval,
            lastModified: Date()
        )
    }
}

enum CloudKitError: Error {
    case accountNotAvailable
    case networkError
    case recordNotFound
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .accountNotAvailable:
            return "iCloud account is not available. Please sign in to iCloud in Settings."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .recordNotFound:
            return "Game state not found in iCloud."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

class CloudKitManager {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let recordType = "GameState"
    private let recordID = CKRecord.ID(recordName: "FeelGoodGameState")
    
    // Publishers for sync status
    private let syncStatusSubject = PassthroughSubject<Bool, Never>()
    var syncStatus: AnyPublisher<Bool, Never> {
        return syncStatusSubject.eraseToAnyPublisher()
    }
    
    // Last sync time
    private var lastSyncTime: Date?
    
    private init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
        
        // Set up notification for iCloud account changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudAccountChanged),
            name: NSNotification.Name.CKAccountChanged,
            object: nil
        )
    }
    
    @objc private func iCloudAccountChanged() {
        // Check account status when iCloud account changes
        checkAccountStatus { _ in }
    }
    
    // Check if iCloud is available
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        container.accountStatus { status, error in
            let isAvailable = status == .available
            DispatchQueue.main.async {
                completion(isAvailable)
            }
        }
    }
    
    // Save game state to iCloud with conflict resolution
    func saveGameState(score: Int, flowersSeen: Int, interval: Double, completion: @escaping (Error?) -> Void) {
        syncStatusSubject.send(true) // Start syncing
        
        let newState = GameStateData(score: score, flowersSeen: flowersSeen, interval: interval)
        
        // Check if user is signed in to iCloud
        container.accountStatus { [weak self] status, error in
            guard let self = self else { 
                DispatchQueue.main.async {
                    self?.syncStatusSubject.send(false) // End syncing
                    completion(CloudKitError.unknown(NSError(domain: "CloudKitManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self reference lost"])))
                }
                return
            }
            
            if status == .available {
                // User is signed in to iCloud
                self.fetchExistingRecord { result in
                    switch result {
                    case .success(let existingRecord):
                        // Update existing record or create new one
                        let record = existingRecord ?? CKRecord(recordType: self.recordType, recordID: self.recordID)
                        
                        // If we have an existing record, merge the states
                        if existingRecord != nil {
                            let existingState = GameStateData(record: record)
                            let mergedState = existingState.mergeWith(newState)
                            
                            // Update record with merged values
                            record["score"] = mergedState.score as CKRecordValue
                            record["flowersSeen"] = mergedState.flowersSeen as CKRecordValue
                            record["interval"] = mergedState.interval as CKRecordValue
                            record["lastModified"] = mergedState.lastModified as CKRecordValue
                        } else {
                            // New record, just set the values
                            record["score"] = newState.score as CKRecordValue
                            record["flowersSeen"] = newState.flowersSeen as CKRecordValue
                            record["interval"] = newState.interval as CKRecordValue
                            record["lastModified"] = newState.lastModified as CKRecordValue
                        }
                        
                        // Save to CloudKit
                        self.privateDatabase.save(record) { _, error in
                            DispatchQueue.main.async {
                                self.lastSyncTime = Date()
                                self.syncStatusSubject.send(false) // End syncing
                                
                                if let error = error {
                                    completion(CloudKitError.unknown(error))
                                } else {
                                    completion(nil)
                                }
                            }
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.syncStatusSubject.send(false) // End syncing
                            completion(error)
                        }
                    }
                }
            } else {
                // User is not signed in to iCloud
                DispatchQueue.main.async {
                    self.syncStatusSubject.send(false) // End syncing
                    completion(CloudKitError.accountNotAvailable)
                }
            }
        }
    }
    
    // Load game state from iCloud
    func loadGameState(completion: @escaping (Result<GameStateData, Error>) -> Void) {
        syncStatusSubject.send(true) // Start syncing
        
        // Check if user is signed in to iCloud
        container.accountStatus { [weak self] status, error in
            guard let self = self else {
                DispatchQueue.main.async {
                    self?.syncStatusSubject.send(false) // End syncing
                    completion(.failure(CloudKitError.unknown(NSError(domain: "CloudKitManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self reference lost"]))))
                }
                return
            }
            
            if status == .available {
                // User is signed in to iCloud
                self.fetchExistingRecord { result in
                    DispatchQueue.main.async {
                        self.syncStatusSubject.send(false) // End syncing
                        
                        switch result {
                        case .success(let record):
                            if let record = record {
                                // Extract values from record
                                let gameState = GameStateData(record: record)
                                self.lastSyncTime = Date()
                                completion(.success(gameState))
                            } else {
                                // No record found, return default values
                                let defaultState = GameStateData(score: 0, flowersSeen: 0, interval: 2.0)
                                completion(.success(defaultState))
                            }
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            } else {
                // User is not signed in to iCloud
                DispatchQueue.main.async {
                    self.syncStatusSubject.send(false) // End syncing
                    completion(.failure(CloudKitError.accountNotAvailable))
                }
            }
        }
    }
    
    // Fetch existing game state record
    private func fetchExistingRecord(completion: @escaping (Result<CKRecord?, Error>) -> Void) {
        // Try to fetch by record ID first (more efficient)
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error as? CKError {
                if error.code == .unknownItem {
                    // Record not found by ID, try query as fallback
                    self.queryForGameStateRecord(completion: completion)
                } else {
                    // Other error
                    completion(.failure(CloudKitError.unknown(error)))
                }
            } else if let error = error {
                completion(.failure(CloudKitError.unknown(error)))
            } else {
                completion(.success(record))
            }
        }
    }
    
    // Query for game state record as fallback
    private func queryForGameStateRecord(completion: @escaping (Result<CKRecord?, Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(.failure(CloudKitError.unknown(error)))
                return
            }
            
            // Return the first record found (there should only be one)
            completion(.success(records?.first))
        }
    }
    
    // Get last sync time
    func getLastSyncTime() -> Date? {
        return lastSyncTime
    }
}
