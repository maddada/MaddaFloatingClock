// The MIT License

// Copyright (c) 2018 Daniel
// Copyright (c) 2023 Roman Dubtsov

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// How to build:
// $ swiftc -o clock -gnone -O -target x86_64-apple-macosx10.14 clock.swift
// How to run:
// $ ./clock

import Cocoa

// MARK: - Settings Keys
struct SettingsKeys {
    static let windowX = "windowX"
    static let windowY = "windowY"
    static let hasCustomPosition = "hasCustomPosition"
    static let colorRed = "colorRed"
    static let colorGreen = "colorGreen"
    static let colorBlue = "colorBlue"
    static let opacity = "opacity"
    static let fontName = "fontName"
    static let fontWeight = "fontWeight"
    static let fontSize = "fontSize"
    static let showDate = "showDate"
    static let timeFormat = "timeFormat"
    static let dateFormat = "dateFormat"
    static let dateFontSize = "dateFontSize"
    static let lineSpacing = "lineSpacing"
    static let textAlignment = "textAlignment"
    static let chimeInterval = "chimeInterval"
    static let chimeVolume = "chimeVolume"
    static let totalTodaySeconds = "totalTodaySeconds"
    static let totalTodayDate = "totalTodayDate"
    static let clickToShowTimerEnabled = "clickToShowTimerEnabled"
    static let timerMode = "timerMode" // "stopwatch" or "pomodoro"
    static let timerGap = "timerGap"
    static let timerSide = "timerSide" // 0 = left, 1 = right
    static let pomodoroWorkDuration = "pomodoroWorkDuration"
    static let pomodoroBreakDuration = "pomodoroBreakDuration"
    static let pomodoroLongBreakDuration = "pomodoroLongBreakDuration"
    static let pomodoroSessionsBeforeLongBreak = "pomodoroSessionsBeforeLongBreak"
    static let settingsWindowX = "settingsWindowX"
    static let settingsWindowY = "settingsWindowY"
    static let hasSettingsWindowPosition = "hasSettingsWindowPosition"
}

// MARK: - Settings Manager
class SettingsManager {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard

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

    var textColor: NSColor {
        get {
            let red = defaults.object(forKey: SettingsKeys.colorRed) as? CGFloat ?? 1.0
            let green = defaults.object(forKey: SettingsKeys.colorGreen) as? CGFloat ?? 1.0
            let blue = defaults.object(forKey: SettingsKeys.colorBlue) as? CGFloat ?? 1.0
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        set {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            if let color = newValue.usingColorSpace(.sRGB) {
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                defaults.set(red, forKey: SettingsKeys.colorRed)
                defaults.set(green, forKey: SettingsKeys.colorGreen)
                defaults.set(blue, forKey: SettingsKeys.colorBlue)
            }
        }
    }

    var opacity: CGFloat {
        get {
            let value = defaults.object(forKey: SettingsKeys.opacity) as? CGFloat
            return value ?? 0.75
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.opacity)
        }
    }

    var fontName: String {
        get {
            return defaults.string(forKey: SettingsKeys.fontName) ?? "Trebuchet MS"
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.fontName)
        }
    }

    var fontWeight: String {
        get {
            return defaults.string(forKey: SettingsKeys.fontWeight) ?? "regular"
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.fontWeight)
        }
    }

    var fontSize: CGFloat {
        get {
            let value = defaults.object(forKey: SettingsKeys.fontSize) as? CGFloat
            return value ?? 19
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.fontSize)
        }
    }

    var showDate: Bool {
        get {
            if defaults.object(forKey: SettingsKeys.showDate) == nil {
                return false
            }
            return defaults.bool(forKey: SettingsKeys.showDate)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.showDate)
        }
    }

    var timeFormat: String {
        get {
            return defaults.string(forKey: SettingsKeys.timeFormat) ?? "hh:mm a"
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.timeFormat)
        }
    }

    var dateFormat: String {
        get {
            return defaults.string(forKey: SettingsKeys.dateFormat) ?? "EEE, MM-dd"
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.dateFormat)
        }
    }

    var dateFontSize: CGFloat {
        get {
            let value = defaults.object(forKey: SettingsKeys.dateFontSize) as? CGFloat
            return value ?? 16
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.dateFontSize)
        }
    }

    var lineSpacing: CGFloat {
        get {
            let value = defaults.object(forKey: SettingsKeys.lineSpacing) as? CGFloat
            return value ?? 2
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.lineSpacing)
        }
    }

    // 0 = left, 1 = center, 2 = right
    var textAlignment: Int {
        get {
            if defaults.object(forKey: SettingsKeys.textAlignment) == nil {
                return 1 // default center
            }
            return defaults.integer(forKey: SettingsKeys.textAlignment)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.textAlignment)
        }
    }

    func getNSTextAlignment() -> NSTextAlignment {
        switch textAlignment {
        case 0: return .left
        case 2: return .right
        default: return .center
        }
    }

    // Click to show timer
    var clickToShowTimerEnabled: Bool {
        get {
            if defaults.object(forKey: SettingsKeys.clickToShowTimerEnabled) == nil {
                return true // enabled by default
            }
            return defaults.bool(forKey: SettingsKeys.clickToShowTimerEnabled)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.clickToShowTimerEnabled)
        }
    }

    // Timer mode: "stopwatch" or "pomodoro"
    var timerMode: String {
        get {
            return defaults.string(forKey: SettingsKeys.timerMode) ?? "stopwatch"
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.timerMode)
        }
    }

    var isPomodoroMode: Bool {
        return timerMode == "pomodoro"
    }

    // Gap between clock and timer
    var timerGap: CGFloat {
        get {
            let value = defaults.object(forKey: SettingsKeys.timerGap) as? CGFloat
            return value ?? 22
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.timerGap)
        }
    }

    // Which side timer appears on: 0 = left, 1 = right
    var timerSide: Int {
        get {
            if defaults.object(forKey: SettingsKeys.timerSide) == nil {
                return 0 // default left
            }
            return defaults.integer(forKey: SettingsKeys.timerSide)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.timerSide)
        }
    }

    // Pomodoro settings (in minutes)
    var pomodoroWorkDuration: Int {
        get {
            let value = defaults.object(forKey: SettingsKeys.pomodoroWorkDuration) as? Int
            return value ?? 25
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.pomodoroWorkDuration)
        }
    }

    var pomodoroBreakDuration: Int {
        get {
            let value = defaults.object(forKey: SettingsKeys.pomodoroBreakDuration) as? Int
            return value ?? 5
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.pomodoroBreakDuration)
        }
    }

    var pomodoroLongBreakDuration: Int {
        get {
            let value = defaults.object(forKey: SettingsKeys.pomodoroLongBreakDuration) as? Int
            return value ?? 15
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.pomodoroLongBreakDuration)
        }
    }

    var pomodoroSessionsBeforeLongBreak: Int {
        get {
            let value = defaults.object(forKey: SettingsKeys.pomodoroSessionsBeforeLongBreak) as? Int
            return value ?? 4
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.pomodoroSessionsBeforeLongBreak)
        }
    }

    // Settings window position
    var settingsWindowPosition: NSPoint? {
        get {
            guard defaults.bool(forKey: SettingsKeys.hasSettingsWindowPosition) else { return nil }
            return NSPoint(
                x: defaults.double(forKey: SettingsKeys.settingsWindowX),
                y: defaults.double(forKey: SettingsKeys.settingsWindowY)
            )
        }
        set {
            if let pos = newValue {
                defaults.set(true, forKey: SettingsKeys.hasSettingsWindowPosition)
                defaults.set(pos.x, forKey: SettingsKeys.settingsWindowX)
                defaults.set(pos.y, forKey: SettingsKeys.settingsWindowY)
            } else {
                defaults.set(false, forKey: SettingsKeys.hasSettingsWindowPosition)
            }
        }
    }

    // 0-100 volume percentage
    var chimeVolume: Int {
        get {
            if defaults.object(forKey: SettingsKeys.chimeVolume) == nil {
                return 50
            }
            return defaults.integer(forKey: SettingsKeys.chimeVolume)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.chimeVolume)
        }
    }

    // 0 = disabled, 5-60 minutes
    var chimeInterval: Int {
        get {
            return defaults.integer(forKey: SettingsKeys.chimeInterval)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.chimeInterval)
        }
    }

    // Total time tracked - stored in JSON file with history per day
    private var timerDataURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MaddaFloatingClock")

        // Create directory if needed
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)

        return appDir.appendingPathComponent("timer_data.json")
    }

    private func loadAllTimerData() -> [String: [String: Any]] {
        guard let data = try? Data(contentsOf: timerDataURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return [:]
        }
        return json
    }

    private func saveAllTimerData(_ data: [String: [String: Any]]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys]) {
            try? jsonData.write(to: timerDataURL)
        }
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var totalTodaySeconds: Int {
        get {
            let allData = loadAllTimerData()
            let today = todayString()

            guard let dayData = allData[today],
                  let seconds = dayData["total_seconds"] as? Int else {
                return 0
            }
            return seconds
        }
        set {
            var allData = loadAllTimerData()
            let today = todayString()

            if allData[today] == nil {
                allData[today] = [:]
            }
            allData[today]?["total_seconds"] = newValue

            saveAllTimerData(allData)
        }
    }

    private func getNSFontWeight() -> NSFont.Weight {
        switch fontWeight.lowercased() {
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        default: return .regular
        }
    }

    // NSFontManager weight values (0-15 scale)
    private func getFontManagerWeight() -> Int {
        switch fontWeight.lowercased() {
        case "light": return 3
        case "regular": return 5
        case "medium": return 6
        case "semibold": return 8
        case "bold": return 9
        case "heavy": return 11
        default: return 5
        }
    }

    func getFont() -> NSFont {
        if fontName == "System" {
            return NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: getNSFontWeight())
        } else {
            let fontManager = NSFontManager.shared
            if let font = fontManager.font(withFamily: fontName, traits: [], weight: getFontManagerWeight(), size: fontSize) {
                return font
            }
            // Fallback to basic font
            if let font = NSFont(name: fontName, size: fontSize) {
                return font
            }
            return NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: getNSFontWeight())
        }
    }

    func getDateFont() -> NSFont {
        if fontName == "System" {
            return NSFont.monospacedDigitSystemFont(ofSize: dateFontSize, weight: getNSFontWeight())
        } else {
            let fontManager = NSFontManager.shared
            if let font = fontManager.font(withFamily: fontName, traits: [], weight: getFontManagerWeight(), size: dateFontSize) {
                return font
            }
            // Fallback to basic font
            if let font = NSFont(name: fontName, size: dateFontSize) {
                return font
            }
            return NSFont.monospacedDigitSystemFont(ofSize: dateFontSize, weight: getNSFontWeight())
        }
    }
}

// MARK: - Settings Window Controller
class SettingsWindowController: NSWindowController, NSWindowDelegate {
    var colorWell: NSColorWell!
    var opacitySlider: NSSlider!
    var opacityLabel: NSTextField!
    var fontPopup: NSPopUpButton!
    var fontSizeField: NSTextField!
    var showDateCheckbox: NSButton!
    var timeFormatField: NSTextField!
    var dateFormatField: NSTextField!
    var dateFontSizeField: NSTextField!
    var dateFontSizeSlider: NSSlider!
    var lineSpacingField: NSTextField!
    var lineSpacingSlider: NSSlider!
    var fontSizeSlider: NSSlider!
    var alignmentControl: NSSegmentedControl!
    var chimeSlider: NSSlider!
    var chimeLabel: NSTextField!
    var chimeVolumeSlider: NSSlider!
    var chimeVolumeLabel: NSTextField!
    var dateFormatRow: NSStackView!
    var lineSpacingRow: NSStackView!
    var dateSizeRow: NSStackView!
    var timerGapRow: NSStackView!
    var timerSideRow: NSStackView!
    var timerModeRow: NSStackView!
    var timerExplanationLabel: NSTextField!
    var timerHistoryButton: NSButton!
    var timerModeControl: NSSegmentedControl!
    var pomodoroExplanationLabel: NSTextField!
    var pomodoroWorkRow: NSStackView!
    var pomodoroBreakRow: NSStackView!
    var pomodoroLongBreakRow: NSStackView!
    var pomodoroSessionsRow: NSStackView!
    var onSettingsChanged: (() -> Void)?
    var onChimeIntervalChanged: (() -> Void)?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 100),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        self.init(window: window)
        window.delegate = self

        // Restore saved position or center
        if let savedPos = SettingsManager.shared.settingsWindowPosition {
            window.setFrameOrigin(savedPos)
        } else {
            window.center()
        }

        setupUI()

        // Size window to fit content vertically, keep width at 380
        window.layoutIfNeeded()
        let fittingSize = window.contentView?.fittingSize ?? NSZeroSize
        let newFrame = NSRect(origin: window.frame.origin, size: NSSize(width: 380, height: fittingSize.height))
        window.setFrame(newFrame, display: true)
    }

    func windowDidMove(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            SettingsManager.shared.settingsWindowPosition = window.frame.origin
        }
    }

    func setupUI() {
        guard let contentView = window?.contentView else { return }

        let settings = SettingsManager.shared
        let labelWidth: CGFloat = 100
        let rowSpacing: CGFloat = 12
        let sectionSpacing: CGFloat = 35

        // Helper to create a label with fixed width
        func makeLabel(_ text: String) -> NSTextField {
            let label = NSTextField(labelWithString: text)
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
            return label
        }

        // Helper to create a row stack
        func makeRow(_ views: [NSView]) -> NSStackView {
            let row = NSStackView(views: views)
            row.orientation = .horizontal
            row.alignment = .centerY
            row.spacing = 10
            return row
        }

        // Helper to create section header
        func makeSectionHeader(_ text: String) -> NSTextField {
            let header = NSTextField(labelWithString: text)
            header.font = NSFont.boldSystemFont(ofSize: 16)
            header.textColor = NSColor.secondaryLabelColor
            return header
        }

        // Main vertical stack
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = rowSpacing
        mainStack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        // ═══════════════════════════════════════
        // INFORMATION SECTION
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("Madda Floating Clock"))

        let infoText = """
        This is a minimal, always-on-top desktop clock, focus/pomodoro timer for macOS.

        • Right-click on clock to open settings
        • Hold Shift and drag to move the clock
        • Post issues or suggestions on GitHub
        """
        let infoLabel = NSTextField(wrappingLabelWithString: infoText)
        infoLabel.font = NSFont.systemFont(ofSize: 15)
        infoLabel.textColor = NSColor.secondaryLabelColor
        mainStack.addArrangedSubview(infoLabel)

        // Section gap
        let infoSectionSpacer = NSView()
        infoSectionSpacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        mainStack.addArrangedSubview(infoSectionSpacer)
        mainStack.setCustomSpacing(20, after: infoSectionSpacer)

        // ═══════════════════════════════════════
        // TIME SECTION
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("TIME"))

        // Time Format
        timeFormatField = NSTextField()
        timeFormatField.stringValue = settings.timeFormat
        timeFormatField.placeholderString = "hh:mm a"
        timeFormatField.target = self
        timeFormatField.action = #selector(timeFormatChanged)
        timeFormatField.widthAnchor.constraint(equalToConstant: 140).isActive = true

        // Font Size
        fontSizeSlider = NSSlider()
        fontSizeSlider.minValue = 10
        fontSizeSlider.maxValue = 72
        fontSizeSlider.integerValue = Int(settings.fontSize)
        fontSizeSlider.target = self
        fontSizeSlider.action = #selector(fontSizeSliderChanged)
        fontSizeSlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        fontSizeField = NSTextField()
        fontSizeField.stringValue = "\(Int(settings.fontSize))"
        fontSizeField.alignment = .center
        fontSizeField.target = self
        fontSizeField.action = #selector(fontSizeChanged)
        fontSizeField.widthAnchor.constraint(equalToConstant: 45).isActive = true
        let fontSizeRow = makeRow([makeLabel("Time size:"), fontSizeSlider, fontSizeField])
        mainStack.addArrangedSubview(fontSizeRow)

        let timeHelpButton = NSButton(title: "?", target: self, action: #selector(openFormatHelp))
        timeHelpButton.bezelStyle = .roundRect
        timeHelpButton.toolTip = "Open format reference"
        let timeFormatRow = makeRow([makeLabel("Time format:"), timeFormatField, timeHelpButton])
        mainStack.addArrangedSubview(timeFormatRow)

        // Section gap
        mainStack.setCustomSpacing(sectionSpacing, after: timeFormatRow)

        // ═══════════════════════════════════════
        // DATE SECTION
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("DATE"))

        // Show Date
        showDateCheckbox = NSButton(checkboxWithTitle: "Show date", target: self, action: #selector(showDateChanged))
        showDateCheckbox.state = settings.showDate ? .on : .off
        mainStack.addArrangedSubview(showDateCheckbox)

        // Date Format
        dateFormatField = NSTextField()
        dateFormatField.stringValue = settings.dateFormat
        dateFormatField.placeholderString = "EEE, MM-dd"
        dateFormatField.target = self
        dateFormatField.action = #selector(dateFormatChanged)
        dateFormatField.widthAnchor.constraint(equalToConstant: 140).isActive = true

        let formatHelpButton = NSButton(title: "?", target: self, action: #selector(openFormatHelp))
        formatHelpButton.bezelStyle = .roundRect
        formatHelpButton.toolTip = "Open format reference"
        dateFormatRow = makeRow([makeLabel("Date format:"), dateFormatField, formatHelpButton])
        dateFormatRow.isHidden = !settings.showDate
        mainStack.addArrangedSubview(dateFormatRow)

        // Line Spacing
        lineSpacingSlider = NSSlider()
        lineSpacingSlider.minValue = -5
        lineSpacingSlider.maxValue = 20
        lineSpacingSlider.doubleValue = Double(settings.lineSpacing)
        lineSpacingSlider.target = self
        lineSpacingSlider.action = #selector(lineSpacingSliderChanged)
        lineSpacingSlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        lineSpacingField = NSTextField()
        lineSpacingField.stringValue = String(format: "%.1f", settings.lineSpacing)
        lineSpacingField.alignment = .center
        lineSpacingField.target = self
        lineSpacingField.action = #selector(lineSpacingChanged)
        lineSpacingField.widthAnchor.constraint(equalToConstant: 45).isActive = true
        lineSpacingRow = makeRow([makeLabel("Line spacing:"), lineSpacingSlider, lineSpacingField])
        lineSpacingRow.isHidden = !settings.showDate
        mainStack.addArrangedSubview(lineSpacingRow)

        // Date Font Size
        dateFontSizeSlider = NSSlider()
        dateFontSizeSlider.minValue = 8
        dateFontSizeSlider.maxValue = 48
        dateFontSizeSlider.integerValue = Int(settings.dateFontSize)
        dateFontSizeSlider.target = self
        dateFontSizeSlider.action = #selector(dateFontSizeSliderChanged)
        dateFontSizeSlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        dateFontSizeField = NSTextField()
        dateFontSizeField.stringValue = "\(Int(settings.dateFontSize))"
        dateFontSizeField.alignment = .center
        dateFontSizeField.target = self
        dateFontSizeField.action = #selector(dateFontSizeChanged)
        dateFontSizeField.widthAnchor.constraint(equalToConstant: 45).isActive = true
        dateSizeRow = makeRow([makeLabel("Date size:"), dateFontSizeSlider, dateFontSizeField])
        dateSizeRow.isHidden = !settings.showDate
        mainStack.addArrangedSubview(dateSizeRow)

        // Section gap - use invisible spacer so spacing persists even when date elements are hidden
        let dateSectionSpacer = NSView()
        dateSectionSpacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        mainStack.addArrangedSubview(dateSectionSpacer)
        mainStack.setCustomSpacing(sectionSpacing, after: dateSectionSpacer)

        // ═══════════════════════════════════════
        // STYLE SECTION
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("STYLE"))

        // Font Name
        fontPopup = NSPopUpButton()
        let fonts = [
            "System",
            "SF Pro", "SF Pro Rounded", "SF Mono",
            "Menlo", "Monaco", "Courier New",
            "Helvetica Neue", "Helvetica",
            "Arial", "Arial Rounded MT Bold",
            "Avenir", "Avenir Next",
            "Futura", "Gill Sans",
            "Georgia", "Times New Roman",
            "Verdana", "Trebuchet MS"
        ]
        fontPopup.addItems(withTitles: fonts)
        if let index = fonts.firstIndex(of: settings.fontName) {
            fontPopup.selectItem(at: index)
        }
        fontPopup.target = self
        fontPopup.action = #selector(fontChanged)
        fontPopup.widthAnchor.constraint(equalToConstant: 200).isActive = true
        let fontRow = makeRow([makeLabel("Font name:"), fontPopup])
        mainStack.addArrangedSubview(fontRow)

        // Font Weight
        let weightPopup = NSPopUpButton()
        let weights = ["Light", "Regular", "Medium", "Semibold", "Bold", "Heavy"]
        weightPopup.addItems(withTitles: weights)
        if let index = weights.firstIndex(of: settings.fontWeight.capitalized) {
            weightPopup.selectItem(at: index)
        } else {
            weightPopup.selectItem(withTitle: "Regular")
        }
        weightPopup.target = self
        weightPopup.action = #selector(fontWeightChanged)
        weightPopup.widthAnchor.constraint(equalToConstant: 200).isActive = true
        let weightRow = makeRow([makeLabel("Font weight:"), weightPopup])
        mainStack.addArrangedSubview(weightRow)

        // Color
        colorWell = NSColorWell()
        colorWell.color = settings.textColor
        colorWell.target = self
        colorWell.action = #selector(colorChanged)
        colorWell.widthAnchor.constraint(equalToConstant: 50).isActive = true
        colorWell.heightAnchor.constraint(equalToConstant: 24).isActive = true
        let colorRow = makeRow([makeLabel("Color:"), colorWell])
        mainStack.addArrangedSubview(colorRow)

        // Opacity
        opacitySlider = NSSlider()
        opacitySlider.minValue = 0.1
        opacitySlider.maxValue = 1.0
        opacitySlider.doubleValue = Double(settings.opacity)
        opacitySlider.target = self
        opacitySlider.action = #selector(opacityChanged)
        opacitySlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        opacityLabel = NSTextField(labelWithString: "\(Int(settings.opacity * 100))%")
        opacityLabel.widthAnchor.constraint(equalToConstant: 45).isActive = true
        let opacityRow = makeRow([makeLabel("Opacity:"), opacitySlider, opacityLabel])
        mainStack.addArrangedSubview(opacityRow)

        // Alignment
        alignmentControl = NSSegmentedControl(labels: ["Left", "Center", "Right"], trackingMode: .selectOne, target: self, action: #selector(alignmentChanged))
        alignmentControl.selectedSegment = settings.textAlignment
        let alignmentRow = makeRow([makeLabel("Alignment:"), alignmentControl])
        mainStack.addArrangedSubview(alignmentRow)

        // Section gap
        mainStack.setCustomSpacing(sectionSpacing, after: alignmentRow)

        // ═══════════════════════════════════════
        // TIMER SECTION
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("TIMER & POMODORO"))

        // Click to show timer checkbox
        let clickToShowTimerCheckbox = NSButton(checkboxWithTitle: "Click on clock to show timer", target: self, action: #selector(clickToShowTimerChanged))
        clickToShowTimerCheckbox.state = settings.clickToShowTimerEnabled ? .on : .off
        mainStack.addArrangedSubview(clickToShowTimerCheckbox)

        // Timer mode picker
        timerModeControl = NSSegmentedControl(labels: ["Stopwatch", "Pomodoro"], trackingMode: .selectOne, target: self, action: #selector(timerModeChanged))
        timerModeControl.selectedSegment = settings.isPomodoroMode ? 1 : 0
        timerModeRow = makeRow([makeLabel("Mode:"), timerModeControl])
        timerModeRow.isHidden = !settings.clickToShowTimerEnabled
        mainStack.addArrangedSubview(timerModeRow)

        // Timer gap slider
        let timerGapSlider = NSSlider()
        timerGapSlider.minValue = -20
        timerGapSlider.maxValue = 60
        timerGapSlider.integerValue = Int(settings.timerGap)
        timerGapSlider.target = self
        timerGapSlider.action = #selector(timerGapChanged)
        timerGapSlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        let timerGapLabel = NSTextField(labelWithString: "\(Int(settings.timerGap)) px")
        timerGapLabel.widthAnchor.constraint(equalToConstant: 45).isActive = true
        timerGapLabel.tag = 999 // Tag to find it later
        timerGapRow = makeRow([makeLabel("Timer gap:"), timerGapSlider, timerGapLabel])
        timerGapRow.isHidden = !settings.clickToShowTimerEnabled
        mainStack.addArrangedSubview(timerGapRow)

        // Timer side control
        let timerSideControl = NSSegmentedControl(labels: ["Left", "Right"], trackingMode: .selectOne, target: self, action: #selector(timerSideChanged))
        timerSideControl.selectedSegment = settings.timerSide
        timerSideControl.tag = 998 // Tag to find it later
        timerSideRow = makeRow([makeLabel("Timer side:"), timerSideControl])
        timerSideRow.isHidden = !settings.clickToShowTimerEnabled
        mainStack.addArrangedSubview(timerSideRow)

        // Stopwatch explanation (shown when mode is stopwatch)
        let showStopwatch = settings.clickToShowTimerEnabled && !settings.isPomodoroMode
        timerExplanationLabel = NSTextField(wrappingLabelWithString: "Click clock to start • Click timer to pause/resume\nClick clock to stop and save time")
        timerExplanationLabel.font = NSFont.systemFont(ofSize: 11)
        timerExplanationLabel.textColor = NSColor.secondaryLabelColor
        timerExplanationLabel.isHidden = !showStopwatch
        mainStack.addArrangedSubview(timerExplanationLabel)

        // Pomodoro explanation (shown when mode is pomodoro)
        let showPomodoro = settings.clickToShowTimerEnabled && settings.isPomodoroMode
        pomodoroExplanationLabel = NSTextField(wrappingLabelWithString: "Click clock to start/stop Pomodoro\n🍅 = Work • ☕ = Break")
        pomodoroExplanationLabel.font = NSFont.systemFont(ofSize: 11)
        pomodoroExplanationLabel.textColor = NSColor.secondaryLabelColor
        pomodoroExplanationLabel.isHidden = !showPomodoro
        mainStack.addArrangedSubview(pomodoroExplanationLabel)

        // Pomodoro Work duration
        let workSlider = NSSlider()
        workSlider.minValue = 1
        workSlider.maxValue = 60
        workSlider.integerValue = settings.pomodoroWorkDuration
        workSlider.target = self
        workSlider.action = #selector(pomodoroWorkChanged)
        workSlider.widthAnchor.constraint(equalToConstant: 100).isActive = true

        let workLabel = NSTextField(labelWithString: "\(settings.pomodoroWorkDuration) min")
        workLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        workLabel.tag = 1001
        pomodoroWorkRow = makeRow([makeLabel("Work:"), workSlider, workLabel])
        pomodoroWorkRow.isHidden = !showPomodoro
        mainStack.addArrangedSubview(pomodoroWorkRow)

        // Pomodoro Break duration
        let breakSlider = NSSlider()
        breakSlider.minValue = 1
        breakSlider.maxValue = 30
        breakSlider.integerValue = settings.pomodoroBreakDuration
        breakSlider.target = self
        breakSlider.action = #selector(pomodoroBreakChanged)
        breakSlider.widthAnchor.constraint(equalToConstant: 100).isActive = true

        let breakLabel = NSTextField(labelWithString: "\(settings.pomodoroBreakDuration) min")
        breakLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        breakLabel.tag = 1002
        pomodoroBreakRow = makeRow([makeLabel("Break:"), breakSlider, breakLabel])
        pomodoroBreakRow.isHidden = !showPomodoro
        mainStack.addArrangedSubview(pomodoroBreakRow)

        // Pomodoro Long break duration
        let longBreakSlider = NSSlider()
        longBreakSlider.minValue = 5
        longBreakSlider.maxValue = 60
        longBreakSlider.integerValue = settings.pomodoroLongBreakDuration
        longBreakSlider.target = self
        longBreakSlider.action = #selector(pomodoroLongBreakChanged)
        longBreakSlider.widthAnchor.constraint(equalToConstant: 100).isActive = true

        let longBreakLabel = NSTextField(labelWithString: "\(settings.pomodoroLongBreakDuration) min")
        longBreakLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        longBreakLabel.tag = 1003
        pomodoroLongBreakRow = makeRow([makeLabel("Long break:"), longBreakSlider, longBreakLabel])
        pomodoroLongBreakRow.isHidden = !showPomodoro
        mainStack.addArrangedSubview(pomodoroLongBreakRow)

        // Pomodoro Sessions before long break
        let sessionsSlider = NSSlider()
        sessionsSlider.minValue = 2
        sessionsSlider.maxValue = 8
        sessionsSlider.integerValue = settings.pomodoroSessionsBeforeLongBreak
        sessionsSlider.target = self
        sessionsSlider.action = #selector(pomodoroSessionsChanged)
        sessionsSlider.widthAnchor.constraint(equalToConstant: 100).isActive = true

        let sessionsLabel = NSTextField(labelWithString: "\(settings.pomodoroSessionsBeforeLongBreak)")
        sessionsLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sessionsLabel.tag = 1004
        pomodoroSessionsRow = makeRow([makeLabel("Sessions:"), sessionsSlider, sessionsLabel])
        pomodoroSessionsRow.isHidden = !showPomodoro
        mainStack.addArrangedSubview(pomodoroSessionsRow)

        // View history button
        timerHistoryButton = NSButton(title: "Saved Focus Times", target: self, action: #selector(viewTimerHistory))
        timerHistoryButton.bezelStyle = .rounded
        timerHistoryButton.controlSize = .small
        timerHistoryButton.isHidden = !settings.clickToShowTimerEnabled
        mainStack.addArrangedSubview(timerHistoryButton)

        // Section gap - use invisible spacer so spacing persists even when timer elements are hidden
        let timerSectionSpacer = NSView()
        timerSectionSpacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        mainStack.addArrangedSubview(timerSectionSpacer)
        mainStack.setCustomSpacing(sectionSpacing, after: timerSectionSpacer)

        // ═══════════════════════════════════════
        // CHIME SECTION
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("CHIME"))

        // Chime Volume
        chimeVolumeSlider = NSSlider()
        chimeVolumeSlider.minValue = 0
        chimeVolumeSlider.maxValue = 100
        chimeVolumeSlider.integerValue = settings.chimeVolume
        chimeVolumeSlider.target = self
        chimeVolumeSlider.action = #selector(chimeVolumeChanged)
        chimeVolumeSlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        chimeVolumeLabel = NSTextField(labelWithString: "\(settings.chimeVolume)%")
        chimeVolumeLabel.widthAnchor.constraint(equalToConstant: 45).isActive = true
        let chimeVolumeRow = makeRow([makeLabel("Chime volume:"), chimeVolumeSlider, chimeVolumeLabel])
        mainStack.addArrangedSubview(chimeVolumeRow)

        // Chime Interval
        chimeSlider = NSSlider()
        chimeSlider.minValue = 0
        chimeSlider.maxValue = 60
        chimeSlider.integerValue = settings.chimeInterval
        chimeSlider.target = self
        chimeSlider.action = #selector(chimeIntervalChanged)
        chimeSlider.widthAnchor.constraint(equalToConstant: 140).isActive = true

        let chimeText = settings.chimeInterval == 0 ? "Off" : "\(settings.chimeInterval) min"
        chimeLabel = NSTextField(labelWithString: chimeText)
        chimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        let chimeRow = makeRow([makeLabel("Chime every:"), chimeSlider, chimeLabel])
        mainStack.addArrangedSubview(chimeRow)

        // Section gap
        mainStack.setCustomSpacing(sectionSpacing, after: chimeRow)

        // ═══════════════════════════════════════
        // BUTTONS
        // ═══════════════════════════════════════

        mainStack.addArrangedSubview(makeSectionHeader("OTHER"))

        let githubButton = NSButton(title: "Visit Github", target: self, action: #selector(visitGithub))
        githubButton.bezelStyle = .rounded
        githubButton.widthAnchor.constraint(equalToConstant: 111).isActive = true

        let resetButton = NSButton(title: "Reset Position", target: self, action: #selector(resetPosition))
        resetButton.bezelStyle = .rounded
        resetButton.widthAnchor.constraint(equalToConstant: 111).isActive = true

        let restartButton = NSButton(title: "Restart", target: self, action: #selector(restartApp))
        restartButton.bezelStyle = .rounded
        restartButton.widthAnchor.constraint(equalToConstant: 111).isActive = true

        let quitButton = NSButton(title: "Quit", target: self, action: #selector(quitApp))
        quitButton.bezelStyle = .rounded
        quitButton.widthAnchor.constraint(equalToConstant: 111).isActive = true

        let buttonRow1 = NSStackView(views: [githubButton, resetButton])
        buttonRow1.orientation = .horizontal
        buttonRow1.spacing = 10
        mainStack.addArrangedSubview(buttonRow1)

        let buttonRow2 = NSStackView(views: [restartButton, quitButton])
        buttonRow2.orientation = .horizontal
        buttonRow2.spacing = 10
        mainStack.addArrangedSubview(buttonRow2)

        // Add main stack to content view
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc func restartApp() {
        let executablePath = Bundle.main.executablePath ?? ProcessInfo.processInfo.arguments[0]
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        try? process.run()
        NSApp.terminate(nil)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    @objc func colorChanged() {
        SettingsManager.shared.textColor = colorWell.color
        onSettingsChanged?()
    }

    @objc func opacityChanged() {
        let value = CGFloat(opacitySlider.doubleValue)
        SettingsManager.shared.opacity = value
        opacityLabel.stringValue = "\(Int(value * 100))%"
        onSettingsChanged?()
    }

    @objc func fontChanged() {
        if let fontName = fontPopup.titleOfSelectedItem {
            SettingsManager.shared.fontName = fontName
            onSettingsChanged?()
        }
    }

    @objc func fontWeightChanged(_ sender: NSPopUpButton) {
        if let weight = sender.titleOfSelectedItem {
            SettingsManager.shared.fontWeight = weight.lowercased()
            onSettingsChanged?()
        }
    }

    @objc func fontSizeChanged() {
        if let size = Double(fontSizeField.stringValue), size >= 8 && size <= 100 {
            SettingsManager.shared.fontSize = CGFloat(size)
            fontSizeSlider.integerValue = Int(size)
            onSettingsChanged?()
        }
    }

    @objc func fontSizeSliderChanged() {
        let size = fontSizeSlider.integerValue
        SettingsManager.shared.fontSize = CGFloat(size)
        fontSizeField.stringValue = "\(size)"
        onSettingsChanged?()
    }

    @objc func alignmentChanged() {
        SettingsManager.shared.textAlignment = alignmentControl.selectedSegment
        onSettingsChanged?()
    }

    @objc func showDateChanged() {
        let showDate = showDateCheckbox.state == .on
        SettingsManager.shared.showDate = showDate
        dateSizeRow.isHidden = !showDate
        dateFormatRow.isHidden = !showDate
        lineSpacingRow.isHidden = !showDate
        onSettingsChanged?()
    }

    @objc func timeFormatChanged() {
        SettingsManager.shared.timeFormat = timeFormatField.stringValue
        onSettingsChanged?()
    }

    @objc func dateFormatChanged() {
        SettingsManager.shared.dateFormat = dateFormatField.stringValue
        onSettingsChanged?()
    }

    @objc func openFormatHelp() {
        if let url = URL(string: "https://www.nsdateformatter.com") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func dateFontSizeChanged() {
        if let size = Double(dateFontSizeField.stringValue), size >= 8 && size <= 100 {
            SettingsManager.shared.dateFontSize = CGFloat(size)
            dateFontSizeSlider.integerValue = Int(size)
            onSettingsChanged?()
        }
    }

    @objc func dateFontSizeSliderChanged() {
        let size = dateFontSizeSlider.integerValue
        SettingsManager.shared.dateFontSize = CGFloat(size)
        dateFontSizeField.stringValue = "\(size)"
        onSettingsChanged?()
    }

    @objc func lineSpacingChanged() {
        if let spacing = Double(lineSpacingField.stringValue), spacing >= -5 && spacing <= 50 {
            SettingsManager.shared.lineSpacing = CGFloat(spacing)
            lineSpacingSlider.doubleValue = spacing
            onSettingsChanged?()
        }
    }

    @objc func lineSpacingSliderChanged() {
        // Round to 1 decimal place
        let spacing = (lineSpacingSlider.doubleValue * 10).rounded() / 10
        SettingsManager.shared.lineSpacing = CGFloat(spacing)
        lineSpacingField.stringValue = String(format: "%.1f", spacing)
        onSettingsChanged?()
    }

    @objc func chimeVolumeChanged() {
        let volume = chimeVolumeSlider.integerValue
        SettingsManager.shared.chimeVolume = volume
        chimeVolumeLabel.stringValue = "\(volume)%"
    }

    @objc func chimeIntervalChanged() {
        // Snap to 5-minute increments, or 0 for off
        var interval = chimeSlider.integerValue
        if interval > 0 && interval < 5 {
            interval = 5
        } else if interval > 5 {
            interval = (interval / 5) * 5
        }
        chimeSlider.integerValue = interval
        SettingsManager.shared.chimeInterval = interval
        chimeLabel.stringValue = interval == 0 ? "Off" : "\(interval) min"
        onChimeIntervalChanged?()
    }

    @objc func clickToShowTimerChanged(_ sender: NSButton) {
        let enabled = sender.state == .on
        SettingsManager.shared.clickToShowTimerEnabled = enabled
        let isPomodoroMode = SettingsManager.shared.isPomodoroMode

        timerModeRow.isHidden = !enabled
        timerGapRow.isHidden = !enabled
        timerSideRow.isHidden = !enabled
        timerHistoryButton.isHidden = !enabled

        // Show appropriate explanation based on mode
        timerExplanationLabel.isHidden = !enabled || isPomodoroMode
        pomodoroExplanationLabel.isHidden = !enabled || !isPomodoroMode
        pomodoroWorkRow.isHidden = !enabled || !isPomodoroMode
        pomodoroBreakRow.isHidden = !enabled || !isPomodoroMode
        pomodoroLongBreakRow.isHidden = !enabled || !isPomodoroMode
        pomodoroSessionsRow.isHidden = !enabled || !isPomodoroMode
    }

    @objc func timerModeChanged(_ sender: NSSegmentedControl) {
        let isPomodoroMode = sender.selectedSegment == 1
        SettingsManager.shared.timerMode = isPomodoroMode ? "pomodoro" : "stopwatch"

        // Update visibility
        timerExplanationLabel.isHidden = isPomodoroMode
        pomodoroExplanationLabel.isHidden = !isPomodoroMode
        pomodoroWorkRow.isHidden = !isPomodoroMode
        pomodoroBreakRow.isHidden = !isPomodoroMode
        pomodoroLongBreakRow.isHidden = !isPomodoroMode
        pomodoroSessionsRow.isHidden = !isPomodoroMode
    }

    @objc func timerGapChanged(_ sender: NSSlider) {
        let gap = sender.integerValue
        SettingsManager.shared.timerGap = CGFloat(gap)
        // Update the label
        if let label = sender.superview?.subviews.first(where: { $0.tag == 999 }) as? NSTextField {
            label.stringValue = "\(gap) px"
        }
        onSettingsChanged?()
    }

    @objc func timerSideChanged(_ sender: NSSegmentedControl) {
        SettingsManager.shared.timerSide = sender.selectedSegment
        onSettingsChanged?()
    }

    @objc func viewTimerHistory() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MaddaFloatingClock")
        let fileURL = appDir.appendingPathComponent("timer_data.json")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } else {
            let alert = NSAlert()
            alert.messageText = "No Timer Data"
            alert.informativeText = "No saved times yet. Use the timer to start tracking!"
            alert.alertStyle = .informational
            alert.runModal()
        }
    }

    @objc func pomodoroWorkChanged(_ sender: NSSlider) {
        let value = sender.integerValue
        SettingsManager.shared.pomodoroWorkDuration = value
        if let label = sender.superview?.subviews.first(where: { $0.tag == 1001 }) as? NSTextField {
            label.stringValue = "\(value) min"
        }
    }

    @objc func pomodoroBreakChanged(_ sender: NSSlider) {
        let value = sender.integerValue
        SettingsManager.shared.pomodoroBreakDuration = value
        if let label = sender.superview?.subviews.first(where: { $0.tag == 1002 }) as? NSTextField {
            label.stringValue = "\(value) min"
        }
    }

    @objc func pomodoroLongBreakChanged(_ sender: NSSlider) {
        let value = sender.integerValue
        SettingsManager.shared.pomodoroLongBreakDuration = value
        if let label = sender.superview?.subviews.first(where: { $0.tag == 1003 }) as? NSTextField {
            label.stringValue = "\(value) min"
        }
    }

    @objc func pomodoroSessionsChanged(_ sender: NSSlider) {
        let value = sender.integerValue
        SettingsManager.shared.pomodoroSessionsBeforeLongBreak = value
        if let label = sender.superview?.subviews.first(where: { $0.tag == 1004 }) as? NSTextField {
            label.stringValue = "\(value)"
        }
    }

    @objc func resetPosition() {
        SettingsManager.shared.windowPosition = nil
        onSettingsChanged?()
    }

    @objc func visitGithub() {
        if let url = URL(string: "https://github.com/maddada/MaddaFloatingClock") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Draggable View
class DraggableView: NSView {
    var initialMouseLocation: NSPoint = .zero
    var initialWindowLocation: NSPoint = .zero
    var onPositionChanged: ((NSPoint) -> Void)?
    var onClockClicked: (() -> Void)?
    var onTimerClicked: (() -> Void)?
    var onTotalClicked: (() -> Void)?
    var onRightClick: (() -> Void)?

    var clockFrame: NSRect = .zero
    var timerFrame: NSRect = .zero
    var totalFrame: NSRect = .zero
    var timerVisible: Bool = false

    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.shift) {
            initialMouseLocation = NSEvent.mouseLocation
            initialWindowLocation = window?.frame.origin ?? .zero
        }
    }

    override func mouseDragged(with event: NSEvent) {
        if event.modifierFlags.contains(.shift) {
            let currentMouseLocation = NSEvent.mouseLocation
            let dx = currentMouseLocation.x - initialMouseLocation.x
            let dy = currentMouseLocation.y - initialMouseLocation.y
            let newOrigin = NSPoint(x: initialWindowLocation.x + dx, y: initialWindowLocation.y + dy)
            window?.setFrameOrigin(newOrigin)
        }
    }

    override func mouseUp(with event: NSEvent) {
        if event.modifierFlags.contains(.shift) {
            if let origin = window?.frame.origin {
                onPositionChanged?(origin)
            }
            return
        }

        // Handle clicks
        let clickLocation = convert(event.locationInWindow, from: nil)

        if timerVisible && timerFrame.contains(clickLocation) {
            onTimerClicked?()
        } else if timerVisible && totalFrame.contains(clickLocation) {
            onTotalClicked?()
        } else if clockFrame.contains(clickLocation) {
            onClockClicked?()
        }
    }

    override func rightMouseUp(with event: NSEvent) {
        onRightClick?()
    }
}

func calcWindowPosition(windowSize: CGSize, screenSize: CGSize) -> CGPoint {
    // top-right only for now
    return CGPointMake(
        screenSize.width - windowSize.width,
        screenSize.height - windowSize.height
    )
}

// MARK: - Clock App Delegate
class Clock: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    var settingsWindowController: SettingsWindowController?
    var timeLabel: NSTextField!
    var dateLabel: NSTextField!
    var separatorLabel: NSTextField!
    var timerLabel: NSTextField!
    var totalTodayLabel: NSTextField!
    var draggableView: DraggableView!
    var updateTimer: Timer?
    var chimeTimer: Timer?

    // Timer state
    var stopwatchTimer: Timer?
    var stopwatchSeconds: Int = 0
    var stopwatchRunning: Bool = false
    var stopwatchVisible: Bool = false

    // Pomodoro state
    var pomodoroActive: Bool = false
    var pomodoroIsBreak: Bool = false
    var pomodoroSecondsRemaining: Int = 0
    var pomodoroCompletedSessions: Int = 0

    // Calculate how much the window origin needs to shift left when timer is on the left
    func calculateTimerLeftOffset() -> CGFloat {
        guard stopwatchVisible && SettingsManager.shared.timerSide == 0 else { return 0 }

        let settings = SettingsManager.shared
        let font = settings.getFont()
        let timeAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let timerText = "00:00:00"
        let timerWidth = timerText.size(withAttributes: timeAttributes).width + 10
        let separatorText = ""
        let separatorWidth = separatorText.size(withAttributes: timeAttributes).width
        let halfGap = settings.timerGap / 2

        return round(timerWidth + halfGap + separatorWidth + halfGap)
    }

    func updateWindowPosition() {
        let timerOffset = calculateTimerLeftOffset()

        if let savedPos = SettingsManager.shared.windowPosition {
            // Adjust saved position to account for timer on left
            let adjustedPos = NSPoint(x: savedPos.x - timerOffset, y: savedPos.y)
            window.setFrameOrigin(adjustedPos)
        } else if let screen = window.screen {
            let pos = calcWindowPosition(windowSize: self.window.frame.size,
                                         screenSize: screen.frame.size)
            // Adjust calculated position to account for timer on left
            let adjustedPos = NSPoint(x: pos.x - timerOffset, y: pos.y)
            window.setFrameOrigin(adjustedPos)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.initTimeDisplay()
        self.initMenuBar()
        self.scheduleNextChime()

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
    }

    func initMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateMenuBarIcon(button: button)
            scheduleMidnightUpdate(button: button)
        }

        setupMenu()
    }

    func scheduleMidnightUpdate(button: NSStatusBarButton) {
        let calendar = Calendar.current
        if let midnight = calendar.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) {
            let timeUntilMidnight = midnight.timeIntervalSinceNow
            Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { [weak self] _ in
                self?.updateMenuBarIcon(button: button)
                self?.scheduleMidnightUpdate(button: button)
            }
        }
    }

    func setupMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Madda Clock Settings...", action: #selector(openSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Restart", action: #selector(restartApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
    }

    @objc func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
            settingsWindowController?.onSettingsChanged = { [weak self] in
                self?.applySettings()
            }
            settingsWindowController?.onChimeIntervalChanged = { [weak self] in
                self?.scheduleNextChime()
            }
        }
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func restartApp() {
        let executablePath = Bundle.main.executablePath ?? ProcessInfo.processInfo.arguments[0]
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        try? process.run()
        NSApp.terminate(nil)
    }

    func scheduleNextChime() {
        chimeTimer?.invalidate()
        chimeTimer = nil

        let interval = SettingsManager.shared.chimeInterval
        guard interval > 0 else { return }

        let calendar = Calendar.current
        let now = Date()
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)

        // Find next chime time
        let currentIntervalStart = (minute / interval) * interval
        var nextChimeMinute = currentIntervalStart + interval
        var secondsUntilChime: Int

        if nextChimeMinute >= 60 {
            // Next chime is in the next hour
            nextChimeMinute = nextChimeMinute % 60
            secondsUntilChime = (60 - minute - 1) * 60 + (60 - second) + nextChimeMinute * 60
        } else {
            secondsUntilChime = (nextChimeMinute - minute) * 60 - second
        }

        if secondsUntilChime <= 0 {
            secondsUntilChime += interval * 60
        }

        chimeTimer = Timer.scheduledTimer(withTimeInterval: Double(secondsUntilChime), repeats: false) { [weak self] _ in
            self?.playChime()
            self?.scheduleNextChime()
        }
    }

    func playChime() {
        if let sound = NSSound(named: "Glass") {
            sound.volume = Float(SettingsManager.shared.chimeVolume) / 100.0
            sound.play()
        }
    }

    func applySettings() {
        let settings = SettingsManager.shared

        // Update font
        timeLabel.font = settings.getFont()
        dateLabel.font = settings.getDateFont()
        separatorLabel.font = settings.getFont()
        timerLabel.font = settings.getFont()
        totalTodayLabel.font = settings.getDateFont()

        // Update color and opacity
        let color = settings.textColor.withAlphaComponent(settings.opacity)
        timeLabel.textColor = color
        dateLabel.textColor = color
        separatorLabel.textColor = color
        totalTodayLabel.textColor = color
        // Timer uses dimmed color if paused
        if stopwatchVisible {
            timerLabel.textColor = stopwatchRunning ? color : color.withAlphaComponent(settings.opacity * 0.5)
        } else {
            timerLabel.textColor = color
        }

        // Update alignment
        let alignment = settings.getNSTextAlignment()
        timeLabel.alignment = alignment
        dateLabel.alignment = alignment

        // Show/hide date label
        dateLabel.isHidden = !settings.showDate
        // Show/hide total today (only visible when date is shown AND stopwatch is visible)
        totalTodayLabel.isHidden = !settings.showDate || !stopwatchVisible

        // Update display format and window size
        updateLabelContent()
        updateWindowSize()

        // Update position
        updateWindowPosition()
    }

    // MARK: - Stopwatch Methods

    func startStopwatch() {
        if stopwatchVisible {
            return
        }

        stopwatchVisible = true
        stopwatchRunning = true
        stopwatchSeconds = 0
        draggableView.timerVisible = true

        separatorLabel.isHidden = false
        timerLabel.isHidden = false
        totalTodayLabel.isHidden = !SettingsManager.shared.showDate
        updateTimerDisplay()
        updateTotalTodayDisplay()

        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.pomodoroActive {
                self.pomodoroTick()
                self.updateTimerDisplay()
                self.updateTotalTodayDisplay()
            } else if self.stopwatchRunning {
                self.stopwatchSeconds += 1
                self.updateTimerDisplay()
            }
        }

        updateWindowSize()
        updateWindowPosition()
    }

    func toggleStopwatch() {
        stopwatchRunning = !stopwatchRunning
        timerLabel.textColor = stopwatchRunning
            ? SettingsManager.shared.textColor.withAlphaComponent(SettingsManager.shared.opacity)
            : SettingsManager.shared.textColor.withAlphaComponent(SettingsManager.shared.opacity * 0.5)
    }

    func removeStopwatch() {
        stopwatchTimer?.invalidate()
        stopwatchTimer = nil

        // Add elapsed time to today's total (only for stopwatch mode)
        if !pomodoroActive {
            SettingsManager.shared.totalTodaySeconds += stopwatchSeconds
        }

        // Reset pomodoro state
        pomodoroActive = false
        pomodoroCompletedSessions = 0

        stopwatchVisible = false
        stopwatchRunning = false
        stopwatchSeconds = 0
        draggableView.timerVisible = false

        separatorLabel.isHidden = true
        timerLabel.isHidden = true
        totalTodayLabel.isHidden = true

        updateWindowSize()
        updateWindowPosition()
    }

    func updateTimerDisplay() {
        if pomodoroActive {
            // Show pomodoro countdown
            let minutes = pomodoroSecondsRemaining / 60
            let seconds = pomodoroSecondsRemaining % 60
            timerLabel.stringValue = String(format: "%02d:%02d", minutes, seconds)
        } else {
            let hours = stopwatchSeconds / 3600
            let minutes = (stopwatchSeconds % 3600) / 60
            let seconds = stopwatchSeconds % 60
            if hours > 0 {
                timerLabel.stringValue = String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                timerLabel.stringValue = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }

    func updateTotalTodayDisplay() {
        if pomodoroActive {
            // Show pomodoro status: emoji and session count
            let prefix = pomodoroIsBreak ? "☕" : "🍅"
            totalTodayLabel.stringValue = "\(prefix) #\(pomodoroCompletedSessions + 1)"
        } else {
            let total = SettingsManager.shared.totalTodaySeconds
            let hours = total / 3600
            let minutes = (total % 3600) / 60
            let seconds = total % 60
            if hours > 0 {
                totalTodayLabel.stringValue = String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                totalTodayLabel.stringValue = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }

    // MARK: - Pomodoro Methods

    func startPomodoro() {
        pomodoroActive = true
        pomodoroIsBreak = false
        pomodoroSecondsRemaining = SettingsManager.shared.pomodoroWorkDuration * 60
        updateTotalTodayDisplay()
    }

    func togglePomodoro() {
        if pomodoroActive {
            // Stop pomodoro
            pomodoroActive = false
            pomodoroCompletedSessions = 0
            updateTotalTodayDisplay()
        } else {
            // Start pomodoro
            startPomodoro()
        }
    }

    func pomodoroTick() {
        guard pomodoroActive else { return }

        pomodoroSecondsRemaining -= 1

        if pomodoroSecondsRemaining <= 0 {
            pomodoroSessionComplete()
        }
    }

    func pomodoroSessionComplete() {
        // Play sound
        if let sound = NSSound(named: "Glass") {
            sound.volume = Float(SettingsManager.shared.chimeVolume) / 100.0
            sound.play()
        }

        if pomodoroIsBreak {
            // Break is over, start work
            pomodoroIsBreak = false
            pomodoroSecondsRemaining = SettingsManager.shared.pomodoroWorkDuration * 60
        } else {
            // Work is over, start break
            pomodoroCompletedSessions += 1

            // Check if it's time for a long break
            let sessionsBeforeLong = SettingsManager.shared.pomodoroSessionsBeforeLongBreak
            if pomodoroCompletedSessions >= sessionsBeforeLong {
                pomodoroSecondsRemaining = SettingsManager.shared.pomodoroLongBreakDuration * 60
                pomodoroCompletedSessions = 0
            } else {
                pomodoroSecondsRemaining = SettingsManager.shared.pomodoroBreakDuration * 60
            }
            pomodoroIsBreak = true
        }
    }

    func updateLabelContent() {
        // The timer handles this, but we trigger an immediate update
        updateTimer?.fire()
    }

    func updateWindowSize() {
        let settings = SettingsManager.shared
        let size = calculateWindowSize()

        var frame = window.frame
        frame.size = size
        window.setFrame(frame, display: true)

        draggableView.frame = NSRect(x: 0, y: 0, width: size.width, height: size.height)

        // Layout labels
        let font = settings.getFont()
        let dateFont = settings.getDateFont()
        let timeHeight = font.pointSize + 4
        let dateHeight = dateFont.pointSize + 4
        let timeAttributes: [NSAttributedString.Key: Any] = [.font: font]

        // Calculate clock width (time label width)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = settings.timeFormat
        let sampleTime = timeFormatter.string(from: Date())
        var clockWidth = sampleTime.size(withAttributes: timeAttributes).width + 22

        if settings.showDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = settings.dateFormat
            let sampleDate = dateFormatter.string(from: Date())
            let dateAttributes: [NSAttributedString.Key: Any] = [.font: dateFont]
            let dateWidth = sampleDate.size(withAttributes: dateAttributes).width + 22
            clockWidth = max(clockWidth, dateWidth)
        }

        // Timer measurements
        let timerGap = settings.timerGap
        let timerText = "00:00:00" // Use longer format to ensure space for hours
        let separatorText = ""
        let timerWidth = timerText.size(withAttributes: timeAttributes).width + 10
        let separatorWidth = separatorText.size(withAttributes: timeAttributes).width

        // Determine positions based on timer side setting
        let timerOnLeft = settings.timerSide == 0
        let halfGap = timerGap / 2

        var clockX: CGFloat = 0
        var separatorX: CGFloat = 0
        var timerX: CGFloat = 0

        if stopwatchVisible {
            if timerOnLeft {
                // Timer on left: [timer] [halfGap] [|] [halfGap] [clock]
                timerX = 0
                separatorX = round(timerWidth + halfGap)
                clockX = round(separatorX + separatorWidth + halfGap)
            } else {
                // Timer on right: [clock] [halfGap] [|] [halfGap] [timer]
                clockX = 0
                separatorX = round(clockWidth + halfGap)
                timerX = round(separatorX + separatorWidth + halfGap)
            }
        } else {
            clockX = 0
        }

        // Update clock frame tracking for click detection
        if settings.showDate {
            let clockFrameHeight = timeHeight + dateHeight + settings.lineSpacing
            draggableView.clockFrame = NSRect(x: clockX, y: 0, width: clockWidth, height: clockFrameHeight)
            timeLabel.frame = NSRect(x: clockX, y: dateHeight + settings.lineSpacing, width: clockWidth, height: timeHeight)
            dateLabel.frame = NSRect(x: clockX, y: 0, width: clockWidth, height: dateHeight)
        } else {
            draggableView.clockFrame = NSRect(x: clockX, y: 0, width: clockWidth, height: size.height)
            timeLabel.frame = NSRect(x: clockX, y: 0, width: clockWidth, height: size.height)
        }

        // Layout timer labels
        if stopwatchVisible {
            let timerY = settings.showDate ? dateHeight + settings.lineSpacing : 0
            let timerHeight = settings.showDate ? timeHeight : size.height

            separatorLabel.frame = NSRect(x: separatorX, y: timerY, width: separatorWidth, height: timerHeight)
            timerLabel.frame = NSRect(x: timerX, y: timerY, width: timerWidth, height: timerHeight)
            draggableView.timerFrame = NSRect(x: timerX, y: timerY, width: timerWidth, height: timerHeight)

            // Position total today label below timer (only when date is shown)
            if settings.showDate {
                totalTodayLabel.frame = NSRect(x: timerX, y: 0, width: timerWidth, height: dateHeight)
                draggableView.totalFrame = NSRect(x: timerX, y: 0, width: timerWidth, height: dateHeight)
            }
        }
    }

    func calculateWindowSize() -> NSSize {
        let settings = SettingsManager.shared
        let font = settings.getFont()

        // Create sample text to measure using current format
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = settings.timeFormat
        let sampleTime = timeFormatter.string(from: Date())

        let timeAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let timeSize = sampleTime.size(withAttributes: timeAttributes)

        var width = timeSize.width + 22
        var height = timeSize.height + 8

        if settings.showDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = settings.dateFormat
            let sampleDate = dateFormatter.string(from: Date())

            let dateFont = settings.getDateFont()
            let dateAttributes: [NSAttributedString.Key: Any] = [.font: dateFont]
            let dateSize = sampleDate.size(withAttributes: dateAttributes)

            width = max(timeSize.width, dateSize.width) + 22
            height = timeSize.height + dateSize.height + settings.lineSpacing + 2
        }

        // Add space for timer if visible
        if stopwatchVisible {
            let timerText = "00:00:00" // Use longer format to ensure space for hours
            let separatorText = ""
            let timerSize = timerText.size(withAttributes: timeAttributes)
            let separatorSize = separatorText.size(withAttributes: timeAttributes)
            let timerGap = settings.timerGap
            width += timerSize.width + separatorSize.width + timerGap + 20 // extra padding for timer
        }

        return NSSize(width: width, height: height)
    }

    func updateMenuBarIcon(button: NSStatusBarButton) {
        let formatter = DateFormatter()

        formatter.dateFormat = "EEE"
        let dayOfWeek = formatter.string(from: Date()).uppercased().prefix(3)

        formatter.dateFormat = "d"
        let dayNumber = formatter.string(from: Date())

        let iconSize = NSSize(width: 24, height: 22)
        let image = NSImage(size: iconSize, flipped: false) { rect in
            let dayFont = NSFont.systemFont(ofSize: 7, weight: .bold)
            let numberFont = NSFont.systemFont(ofSize: 12, weight: .bold)

            let dayAttributes: [NSAttributedString.Key: Any] = [
                .font: dayFont,
                .foregroundColor: NSColor.white
            ]
            let numberAttributes: [NSAttributedString.Key: Any] = [
                .font: numberFont,
                .foregroundColor: NSColor.white
            ]

            let dayString = String(dayOfWeek)
            let daySize = dayString.size(withAttributes: dayAttributes)
            let dayRect = NSRect(x: (rect.width - daySize.width) / 2, y: rect.height - daySize.height - 1, width: daySize.width, height: daySize.height)
            dayString.draw(in: dayRect, withAttributes: dayAttributes)

            let numberSize = dayNumber.size(withAttributes: numberAttributes)
            let numberRect = NSRect(x: (rect.width - numberSize.width) / 2, y: 1, width: numberSize.width, height: numberSize.height)
            dayNumber.draw(in: numberRect, withAttributes: numberAttributes)

            return true
        }
        image.isTemplate = true
        button.image = image
    }

    func initLabels(interval: TimeInterval) {
        let settings = SettingsManager.shared

        let timeFormatter = DateFormatter()
        let dateFormatter = DateFormatter()

        let color = settings.textColor.withAlphaComponent(settings.opacity)

        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadow.shadowOffset = NSMakeSize(0, 0)
        shadow.shadowBlurRadius = 1

        let alignment = settings.getNSTextAlignment()

        // Time label
        timeLabel = NSTextField()
        timeLabel.font = settings.getFont()
        timeLabel.isBezeled = false
        timeLabel.isEditable = false
        timeLabel.drawsBackground = false
        timeLabel.alignment = alignment
        timeLabel.textColor = color
        timeLabel.shadow = shadow

        // Date label
        dateLabel = NSTextField()
        dateLabel.font = settings.getDateFont()
        dateLabel.isBezeled = false
        dateLabel.isEditable = false
        dateLabel.drawsBackground = false
        dateLabel.alignment = alignment
        dateLabel.textColor = color
        dateLabel.shadow = shadow
        dateLabel.isHidden = !settings.showDate

        // Separator label
        separatorLabel = NSTextField()
        separatorLabel.font = settings.getFont()
        separatorLabel.isBezeled = false
        separatorLabel.isEditable = false
        separatorLabel.drawsBackground = false
        separatorLabel.alignment = .center
        separatorLabel.textColor = color
        separatorLabel.shadow = shadow
        separatorLabel.stringValue = ""
        separatorLabel.isHidden = true

        // Timer label
        timerLabel = NSTextField()
        timerLabel.font = settings.getFont()
        timerLabel.isBezeled = false
        timerLabel.isEditable = false
        timerLabel.drawsBackground = false
        timerLabel.alignment = .center
        timerLabel.textColor = color
        timerLabel.shadow = shadow
        timerLabel.stringValue = "00:00"
        timerLabel.isHidden = true

        // Total today label
        totalTodayLabel = NSTextField()
        totalTodayLabel.font = settings.getDateFont()
        totalTodayLabel.isBezeled = false
        totalTodayLabel.isEditable = false
        totalTodayLabel.drawsBackground = false
        totalTodayLabel.alignment = .center
        totalTodayLabel.textColor = color
        totalTodayLabel.shadow = shadow
        totalTodayLabel.stringValue = "00:00"
        totalTodayLabel.isHidden = true

        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            let currentSettings = SettingsManager.shared
            timeFormatter.dateFormat = currentSettings.timeFormat
            dateFormatter.dateFormat = currentSettings.dateFormat

            self?.timeLabel.stringValue = timeFormatter.string(from: Date())
            self?.dateLabel.stringValue = dateFormatter.string(from: Date())
        }
        updateTimer?.tolerance = interval / 10
        updateTimer?.fire()
    }

    func initWindow(size: CGSize) -> NSWindow {
        let settings = SettingsManager.shared
        let pos: CGPoint
        if let savedPos = settings.windowPosition {
            pos = savedPos
        } else {
            pos = calcWindowPosition(windowSize: size, screenSize: NSScreen.main!.frame.size)
        }

        let rect = NSMakeRect(pos.x, pos.y, size.width, size.height)
        let window = NSWindow(
            contentRect: rect,
            styleMask: .borderless,
            backing: .buffered,
            defer: true
        )

        draggableView = DraggableView(frame: NSMakeRect(0, 0, size.width, size.height))
        draggableView.onPositionChanged = { newPos in
            SettingsManager.shared.windowPosition = newPos
        }
        draggableView.onClockClicked = { [weak self] in
            guard let self = self else { return }
            if self.stopwatchVisible {
                self.removeStopwatch()
            } else if SettingsManager.shared.clickToShowTimerEnabled {
                if SettingsManager.shared.isPomodoroMode {
                    self.startPomodoro()
                    self.startStopwatch() // Still start the timer display
                } else {
                    self.startStopwatch()
                }
            }
        }
        draggableView.onTimerClicked = { [weak self] in
            guard let self = self else { return }
            if SettingsManager.shared.isPomodoroMode {
                // In pomodoro mode, clicking timer doesn't pause
                return
            }
            self.toggleStopwatch()
        }
        draggableView.onRightClick = { [weak self] in
            self?.openSettings()
        }
        draggableView.onTotalClicked = {
            // Total click does nothing now - pomodoro is started by clock click
        }

        // Add all labels
        draggableView.addSubview(timeLabel)
        draggableView.addSubview(dateLabel)
        draggableView.addSubview(separatorLabel)
        draggableView.addSubview(timerLabel)
        draggableView.addSubview(totalTodayLabel)

        // Layout labels
        let font = settings.getFont()
        let dateFont = settings.getDateFont()
        let timeHeight = font.pointSize + 4
        let dateHeight = dateFont.pointSize + 4

        if settings.showDate {
            timeLabel.frame = NSRect(x: 0, y: dateHeight + settings.lineSpacing, width: size.width, height: timeHeight)
            dateLabel.frame = NSRect(x: 0, y: 0, width: size.width, height: dateHeight)
        } else {
            timeLabel.frame = draggableView.bounds
        }

        // Set initial clock frame for click detection
        draggableView.clockFrame = draggableView.bounds

        window.contentView = draggableView
        window.ignoresMouseEvents = false
        window.level = NSWindow.Level.floating
        window.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
        window.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        window.orderFrontRegardless()

        return window
    }

    func initTimeDisplay() {
        initLabels(interval: 1)

        let size = calculateWindowSize()

        self.window = self.initWindow(size: size)
    }
}

let clock = Clock()

let app = NSApplication.shared
app.delegate = clock
app.setActivationPolicy(.accessory)
app.run()
