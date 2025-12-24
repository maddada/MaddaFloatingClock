Madda Floating Clock - Architecture Analysis Report

Here's a detailed understanding of how this macOS floating clock app works:

1. OVERALL ARCHITECTURE

Framework & Language:
- AppKit (not SwiftUI) - built using Cocoa framework
- Pure Swift implementation (Cocoa bindings)
- Compiled as a single executable file
- Can be built with: swiftc -o clock -gnone -O -target x86_64-apple-macosx10.14 clock.swift

App Structure:
- Uses traditional macOS AppKit patterns (NSApplication, NSWindow, NSWindowDelegate)
- Single file architecture (MaddaFloatingClock.swift - 2038 lines)
- Acts as an accessory app (menu bar utility)
- Always-on-top floating window using NSWindow.Level.floating

---
2. WINDOW POSITION SAVING & RESTORATION

Location in Code: Lines 71-88 & 1351-1365

Storage Mechanism:
- Uses UserDefaults.standard to persist window position
- Three key-value pairs used:
	- hasCustomPosition (Bool) - flag indicating if position was manually set
	- windowX (Double) - X coordinate
	- windowY (Double) - Y coordinate

SettingsManager Class - windowPosition Property:
var windowPosition: NSPoint? {
		get {
				guard defaults.bool(forKey: SettingsKeys.hasCustomPosition) else { return nil }
				return NSPoint(
						x: defaults.double(forKey: SettingsKeys.windowX),
						y: defaults.double(forKey: SettingsKeys.windowY)
				)
		}
		set {
				if let pos = newValue {
						defaults.set(true, forKey: SettingsKeys.hasCustomPosition)
						defaults.set(pos.x, forKey: SettingsKeys.windowX)
						defaults.set(pos.y, forKey: SettingsKeys.windowY)
				} else {
						defaults.set(false, forKey: SettingsKeys.hasCustomPosition)
				}
		}
}

How Position is Saved:
- Drag Events: When user Shift+drags window, DraggableView class (lines 1244-1299) captures position changes
- Line 1959-1960: draggableView.onPositionChanged callback saves position to UserDefaults
- Line 1272: Window position updated via window.setFrameOrigin(newOrigin)

How Position is Restored:
- On App Launch: Lines 1944-1948
	- initWindow() checks for saved position first
	- If position exists, uses it; otherwise uses default top-right calculation
- On Screen Change: Lines 1372-1381
	- Listens to NSApplication.didChangeScreenParametersNotification
	- Only repositions if hasCustomPosition is false (respects manual placement)
	- Calls updateWindowPosition() which recalculates position for new screen

Position Update Logic - updateWindowPosition() (Lines 1351-1365):
func updateWindowPosition() {
		let timerOffset = calculateTimerLeftOffset()

		if let savedPos = SettingsManager.shared.windowPosition {
				// Use saved position (adjusted for timer offset on left side)
				let adjustedPos = NSPoint(x: savedPos.x - timerOffset, y: savedPos.y)
				window.setFrameOrigin(adjustedPos)
		} else if let screen = window.screen {
				// Calculate default position (top-right corner)
				let pos = calcWindowPosition(windowSize: self.window.frame.size,
																		screenSize: screen.frame.size)
				let adjustedPos = NSPoint(x: pos.x - timerOffset, y: pos.y)
				window.setFrameOrigin(adjustedPos)
		}
}

---
3. MONITOR/SCREEN DETECTION

Location in Code: Lines 1372-1381, 1301-1307, 1358-1363

Screen Detection Mechanism:
- Uses macOS standard NSScreen API
- Listens to NSApplication.didChangeScreenParametersNotification
- Two sources of screen info:
	a. window.screen - current screen containing the window
	b. NSScreen.main! - primary/main screen (fallback)

Screen Change Handling (Lines 1372-1381):
NotificationCenter.default.addObserver(
		forName: NSApplication.didChangeScreenParametersNotification,
		object: NSApplication.shared,
		queue: OperationQueue.main
) {
		notification -> Void in
		if SettingsManager.shared.windowPosition == nil {
				self.updateWindowPosition()
		}
}

Default Position Calculation (Lines 1301-1307):
func calcWindowPosition(windowSize: CGSize, screenSize: CGSize) -> CGPoint {
		// top-right only for now
		return CGPointMake(
				screenSize.width - windowSize.width,
				screenSize.height - windowSize.height
		)
}

Key Behaviors:
- Default placement: top-right corner of the current screen
- On screen disconnect/connect: Window repositions only if user hasn't manually placed it (hasCustomPosition == false)
- If user manually repositioned, manual position is preserved across screen changes
- Accounts for timer offset when timer appears on the left side

---
4. WINDOW CONFIGURATION

Window Properties (Lines 1951-2020):
- Style: Borderless (NSWindow.CollectionBehavior.borderless)
- Level: Floating (always on top) - NSWindow.Level.floating
- Behavior: Can join all spaces - NSWindow.CollectionBehavior.canJoinAllSpaces
- Background: Transparent - NSColor(red: 0, green: 0, blue: 0, alpha: 0)
- Mouse Events: Enabled - window.ignoresMouseEvents = false
- Backing: Buffered

---
5. PREFERENCES STORAGE

UserDefaults Keys (Lines 31-64):

The app stores extensive preferences via UserDefaults with these categories:

Window Positioning:
- windowX, windowY - main clock window position
- hasCustomPosition - flag for custom positioning
- settingsWindowX, settingsWindowY - settings window position
- hasSettingsWindowPosition - settings window position flag

Display Settings:
- timeFormat - time display format string (default: "hh:mm a")
- dateFormat - date display format (default: "EEE, MM-dd")
- colorRed, colorGreen, colorBlue - RGB color components
- opacity - alpha value (0.1 to 1.0)
- fontName - font selection (default: "Trebuchet MS")
- fontWeight - font weight (light/regular/medium/semibold/bold/heavy)
- fontSize - time text size (default: 19)
- dateFontSize - date text size (default: 16)
- lineSpacing - gap between time and date (default: 2)
- textAlignment - 0=left, 1=center, 2=right
- showDate - boolean to toggle date display

Timer/Pomodoro:
- clickToShowTimerEnabled - toggle timer feature (default: true)
- timerMode - "stopwatch" or "pomodoro"
- timerGap - spacing between clock and timer (default: 22)
- timerSide - 0=left, 1=right positioning
- pomodoroWorkDuration - work session length in minutes (default: 25)
- pomodoroBreakDuration - short break length (default: 5)
- pomodoroLongBreakDuration - long break length (default: 15)
- pomodoroSessionsBeforeLongBreak - sessions until long break (default: 4)

Audio/Chime:
- chimeInterval - 0=disabled, 5-60 minute intervals
- chimeVolume - 0-100%

Timer Data:
- Stored separately in JSON file: ~/Library/Application Support/MaddaFloatingClock/timer_data.json
- Tracks daily timer usage with date keys

---
6. IMPORTANT ARCHITECTURAL NOTES

Class Structure:
- SettingsKeys (lines 32-64) - Constants container
- SettingsManager (lines 67-463) - Singleton managing all preferences
- SettingsWindowController (lines 466-1242) - Settings UI window
- DraggableView (lines 1245-1299) - Custom NSView for drag/click handling
- Clock (lines 1310-2030) - Main application delegate

Screen Change Vulnerability Fix:
- Git history mentions: "Fix crash when transitioning between monitor setups"
- Current implementation handles screen changes safely by checking hasCustomPosition

UI Framework:
- Manual NSView/NSStackView layout (not Auto Layout constraints)
- NSTextField for text display
- NSColorWell, NSSlider, NSButton, NSSegmentedControl for settings

Display Update Mechanism:
- Timer-based updates: Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
- Updates clock display every second
- Window resizing triggers when timer visibility changes

---
7. KEY CODE LOCATIONS

| Functionality                | Location                                                                |
|------------------------------|-------------------------------------------------------------------------|
| Position Saving/Restoring    | Lines 71-88 (getter/setter), 1959-1960 (on drag), 1944-1948 (on launch) |
| Screen Change Handling       | Lines 1372-1381                                                         |
| Default Position Calculation | Lines 1301-1307                                                         |
| Window Creation              | Lines 1941-2021                                                         |
| Settings Window Position     | Lines 310-327                                                           |
| SettingsManager Singleton    | Line 68                                                                 |
| Draggable View Logic         | Lines 1266-1281 (drag events)                                           |
| Menu Bar Icon                | Lines 1819-1855                                                         |
| Chime Scheduling             | Lines 1438-1471                                                         |
| Timer/Pomodoro Logic         | Lines 1521-1680                                                         |

---
This is a well-structured AppKit application with robust window positioning, solid preferences management, and proper screen detection handling. The key
insight for multi-monitor support is that it respects manually-set positions while intelligently repositioning only when the window was at default
placement during a screen configuration change.