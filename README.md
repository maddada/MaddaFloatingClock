# Madda Floating Clock

A customizable floating clock for macOS that stays on top of all windows.

Based on [FloatClock by kolbusa](https://github.com/kolbusa/FloatClock).

### How to install:
You just need the Xcode Command Line Tools. Run:
`xcode-select --install`

This opens a dialog to install the command line tools (includes Swift, git, make, etc.). It's about 1-2 GB and takes a few minutes.

After that completes, you can run:
`make install`

This command builds the .app file then moves it to your Applications folder.

You can add it to login items to make it auto start (it'll remember last position).

### 2 optional timers:

Focus Timer:
<br /><br />
<img width="387" height="58" alt="2025-12-25_CleanShot_03-06-37" src="https://github.com/user-attachments/assets/8bdceb98-31d1-48b9-b648-fb0987087c2d" />

Pomodoro Timer:
<br /><br />
<img width="387" height="58" alt="2025-12-25_CleanShot_03-06-53" src="https://github.com/user-attachments/assets/ac73df27-b181-4100-b361-65fad64a1c10" />

### Super configurable:
<img width="500" alt="2025-12-25_Vivaldi Snapshot_03-01-40" src="https://github.com/user-attachments/assets/747c47aa-b554-4b67-a125-9566326d6036" />

## Recommandation: Hide the menu bar clock by switching this setting to analog.

<img width="500"  alt="2025-12-25_System Settings_03-48-46" src="https://github.com/user-attachments/assets/e746da60-16f2-4cae-b2fd-4e17b33168e5" />

## Features & Settings

- **Time format** - Customizable time display format (e.g., hh:mm a, HH:mm:ss)
- **Time font size** - Adjustable size for the time display
- **Show date** - Toggle date display on/off
- **Date format** - Customizable date format (e.g., EEE, MM-dd)
- **Date font size** - Independent size control for the date
- **Line spacing** - Adjust gap between time and date
- **Font selection** - Choose from 18 built-in fonts including SF Pro, Menlo, Helvetica
- **Text color** - Full color picker for customization
- **Opacity** - Transparency control (10-100%)
- **Text alignment** - Left, center, or right alignment
- **Chime reminder** - Audio chime at 5-60 minute intervals
- **Chime volume** - Adjustable volume (0-100%)
- **Stopwatch timer** - Click clock to start, click timer to pause/resume, click clock again to remove
- **Total today** - Tracks cumulative timer time for the day (resets at midnight)
- **Pomodoro timer** - Click total time to start/stop, configurable work/break/long break durations
- **Draggable window** - Shift+drag to reposition, position is saved
- **Always on top** - Floats above all windows on all spaces
- **Menu bar icon** - Shows current day of week and date

## Per-Monitor Position Memory

The clock remembers its position separately for each monitor. This is useful when you switch between different display setups:

- **Different positions per screen** - Set the clock position on your external 4K monitor, then set a different position on your laptop screen. Each is saved independently.
- **Automatic restoration** - When you unplug your external monitor, the clock restores to your saved laptop screen position. Plug the external monitor back in and it returns to that monitor's saved position.
- **Multi-monitor setups** - When multiple monitors are connected, the clock appears on the largest screen and treats that as a separate configuration.

Positions are identified by monitor name and resolution (e.g., "Built-in Retina Display_1728x1117" or "LG HDR 4K_3840x2160").

## Build Instructions

Requires Swift

- Build: `make all`
- Clean: `make clean`
- Install: `make install`
- Add to login items: `make register`
- Remove from login items: `make unregister`
- Uninstall: `make uninstall`
