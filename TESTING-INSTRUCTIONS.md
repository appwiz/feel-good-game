# Feel Good Game - Testing Instructions

This document provides instructions for testing the Feel Good game on iOS, iPadOS, and macOS platforms.

## Prerequisites
- Xcode 14.0 or later
- iOS/iPadOS 15.0+ simulator or device
- macOS 12.0+ (Monterey or later)
- Active Apple Developer account (for GameCenter and iCloud testing)

## Building the Project
1. Open the project in Xcode
2. Select the appropriate scheme for your target platform (iOS, iPadOS, or macOS)
3. Build the project (⌘+B)
4. Run the project (⌘+R)

## Test Scenarios

### Basic Gameplay Testing
1. **Launch the app**
   - Verify the game launches directly into gameplay with no loading screen
   - Confirm a rectangle appears on screen

2. **Rectangle appearance**
   - Observe that rectangles appear in random locations
   - Verify rectangles are fully contained within the screen
   - Confirm new rectangles appear approximately every 2 seconds by default
   - Observe that rectangles have various colors/gradients

3. **Tapping rectangles**
   - Tap within the bounds of a rectangle
   - Verify the score increments
   - Confirm a pleasant sound plays
   - Observe the rectangle disappears with an animation
   - Verify a new rectangle appears

4. **Flower appearance**
   - Continue tapping rectangles until a flower appears (approximately 1 in 5 taps)
   - Verify the flower count increments
   - Confirm a special sound plays for the flower
   - Observe the flower animation

### Settings Testing
1. **Access settings**
   - Tap the "Settings" button
   - Verify the settings screen appears

2. **Adjust rectangle appearance interval**
   - Move the slider to change the interval (range: 0.1s to 5s)
   - Tap "Save & Return"
   - Verify rectangles now appear at the new interval rate

3. **View game statistics**
   - Open settings again
   - Verify the current score and flower count are displayed correctly

### Cloud Integration Testing

#### iCloud Testing
1. **Sign in to iCloud**
   - Ensure you're signed into iCloud on your test device
   - Verify the sync status indicator shows connected

2. **Test synchronization**
   - Play the game and accumulate some score
   - Force close the app
   - Relaunch the app
   - Verify your score and settings are restored

3. **Cross-device testing** (if multiple devices available)
   - Play the game on one device
   - Launch the game on a second device signed into the same iCloud account
   - Verify the score, flower count, and settings sync between devices

#### GameCenter Testing
1. **Sign in to GameCenter**
   - Ensure you're signed into GameCenter on your test device
   - Verify your GameCenter username appears in the game

2. **Achievement testing**
   - Play until you reach 100 taps
   - Verify the achievement notification appears
   - Open GameCenter achievements view to confirm the achievement is unlocked

3. **Leaderboard testing**
   - Accumulate a score
   - Open the GameCenter leaderboard
   - Verify your score is reported to the leaderboard

### Edge Case Testing
1. **Offline mode**
   - Turn off internet connection
   - Verify the game still functions
   - Confirm appropriate offline indicators are shown

2. **Rapid tapping**
   - Tap rectangles very rapidly
   - Verify the game handles this without issues

3. **Device orientation** (iOS/iPadOS)
   - Rotate the device between portrait and landscape
   - Verify the UI adapts appropriately

4. **Window resizing** (macOS)
   - Resize the game window
   - Verify the UI adapts to different window sizes

## Reporting Issues
If you encounter any issues during testing, please document the following:
1. Test scenario and steps to reproduce
2. Expected behavior
3. Actual behavior
4. Platform and device/simulator used
5. Screenshots or video if applicable

## Test Completion
After completing all test scenarios, review the TEST-REPORT.md file to ensure all test cases have been verified.
