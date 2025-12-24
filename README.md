# Madda Floating Clock

A customizable floating clock for macOS that stays on top of all windows.

Based on [FloatClock by kolbusa](https://github.com/kolbusa/FloatClock).

To install:
Just run `make install` to build the .app file then move it to your Applications folder.
You can add it to login items to make it auto start.

<img width="794" height="804" alt="2025-12-25_Madda Floating Clock_02-55-41" src="https://github.com/user-attachments/assets/c5f157ea-3d08-4fa0-b679-b3d9a1f1cd48" />
<img width="853" height="730" alt="2025-12-25_Madda Floating Clock_02-53-45" src="https://github.com/user-attachments/assets/b20d8c3e-6a5a-4ead-bcc3-e6e4a7144662" />

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

## Build Instructions

Requires Swift

- Build: `make all`
- Clean: `make clean`
- Install: `make install`
- Add to login items: `make register`
- Remove from login items: `make unregister`
- Uninstall: `make uninstall`
