//
//  AppDelegate.swift
//  eye
//
//  Created by Alimjan on 2021/3/18.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var aboutWindow: NSWindow!
    
    
    @IBOutlet weak var launchAtStartupCheckbox: NSButtonCell!
    @IBOutlet weak var timeToNextBreak: NSMenuItem!
    @IBOutlet weak var pauseMenuItem: NSMenuItem!
    
    @IBOutlet weak var breakCountDownLabel: NSTextField!
    @IBOutlet weak var breakCountDownText: NSTextFieldCell!
    
    @IBOutlet weak var BreakIntervalTextField: ICTextField!
    
    
    @IBOutlet weak var breakIntervalTextCell: NSTextFieldCell!
    @IBOutlet weak var BreakForTextField: ICTextField!
    
    @IBOutlet weak var breakForTextCell: NSTextFieldCell!
    
    
    @IBOutlet weak var preferencesWindow: NSWindow!
    private let changeImageInterval:TimeInterval = 10
    
    private var breakTimeInSeconds:TimeInterval = 5*60
    private var breakTimeout:TimeInterval = 25*60
    
    private var breakTimeCountDown = 5*60
    private var breakTimeoutCountDown = 25*60
    
    private var timer: Timer?
    private var breakTimer: Timer?
    private var countDownTimer: Timer?
    private var breakCountDownTimer: Timer?
    
    @IBOutlet weak var skipBreakMenuItem: NSMenuItem!
    @IBOutlet weak var skipButton: NSButton!
    @IBOutlet weak var breakMenuItem: NSMenuItem!
   
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let overlayWindow = NSWindow()
    private var secondayOverlayWindows:[NSWindow] = [NSWindow]()
    private var isPaused = false
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBAction func pauseMenuItemClicked(sender: AnyObject) {
        if isPaused {
            setBreakTimer()
            setBreakCountDownTimer()
            pauseMenuItem.title = "Pause"
            breakMenuItem.isHidden = false
        } else {
            if (self.timer != nil) {
                self.timer!.invalidate()
            }
            if (self.countDownTimer != nil) {
                self.countDownTimer!.invalidate()
            }
            self.breakTimer!.invalidate()
            self.breakCountDownTimer!.invalidate()
            pauseMenuItem.title = "Unpause"
            breakTimeCountDown = Int(breakTimeout)
            timeToNextBreak.title = secondsToFormat(num:breakTimeCountDown)
            breakMenuItem.isHidden = true
        }
        isPaused = !isPaused
    }
    
    @IBAction func launchAtStartupCheckboxClicked(sender: AnyObject) {
        if launchAtStartupCheckbox.state == NSControl.StateValue.on {
            StartupLaunch.setLaunchOnLogin(true)
        } else {
            StartupLaunch.setLaunchOnLogin(false)
        }
    }
    
    @IBAction func skipBreakButtonClicked(sender: AnyObject) {
        resetBreakTimer()
    }
    @IBAction func skipBreakClicked(sender: AnyObject) {
        resetBreakTimer()
    }
    @IBAction func preferencesClicked(sender: AnyObject) {
        
        let scrn: NSScreen = NSScreen.main!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        preferencesWindow.setFrameOrigin(NSPoint(x: width/2 - 230/2, y: height/2 - 145/2))
        preferencesWindow.makeKeyAndOrderFront(preferencesWindow)
    }

    @IBAction func aboutClicked(sender: AnyObject) {
        let scrn: NSScreen = NSScreen.main!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        aboutWindow.setFrameOrigin(NSPoint(x: width/2 - 254/2, y: height/2 - 150/2))
        aboutWindow.makeKeyAndOrderFront(aboutWindow)
    }
    
    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func breakClicked(sender: AnyObject) {
        if !isPaused {
            
            self.breakTimer!.invalidate()
            self.breakCountDownTimer!.invalidate()
            statusMenu.cancelTracking()
            changeImage()
            let screens: [NSScreen] = NSScreen.screens
            
            for (_, screen) in screens.enumerated() {
                let window = NSWindow()
                window.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
                let frame = screen.frame
                window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)))
//                window.level = Int(CGWindowLevelForKey(.StatusWindowLevelKey))
                window.titlebarAppearsTransparent  =   true
                window.titleVisibility             =   .hidden
                window.styleMask = NSWindow.StyleMask.borderless
             
                window.setFrame(frame, display: true)
                window.makeKeyAndOrderFront(window)
                secondayOverlayWindows.append(window)
            }
            
            let screen = NSScreen.main
            let rect: NSRect = screen!.frame
            let height = rect.size.height
            let width = rect.size.width
            var frame = screen!.frame
            frame.size = NSMakeSize(width, height)
            overlayWindow.setFrame(frame, display: true)
            overlayWindow.makeKeyAndOrderFront(overlayWindow)
            overlayWindow.setIsVisible(true)
            
            skipButton.setFrameOrigin(NSPoint(x: width/2 - 75, y: 150))
            breakCountDownLabel.setFrameOrigin(NSPoint(x: width/2 - 87, y: 220))
            
            self.timer = Timer.scheduledTimer(timeInterval:changeImageInterval,
                                                                target:self,
                                                                selector:#selector(AppDelegate.changeImage),
                                                                userInfo:nil,
                                                                repeats:true)
            
           RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
            
            skipBreakMenuItem.isHidden = false
            breakMenuItem.isHidden = true
            
            self.breakTimer = Timer.scheduledTimer(timeInterval:breakTimeInSeconds,
                                                                     target:self,
                                                                     selector:#selector(AppDelegate.resetBreakTimer),
                                                                     userInfo:nil,
                                                                     repeats:false)
            
            breakTimeoutCountDown = Int(breakTimeInSeconds)
            
            breakCountDownText.title = secondsToFormat(num:breakTimeoutCountDown)
            
            self.countDownTimer = Timer.scheduledTimer(timeInterval: 1,
                                                                         target:self,
                                                                         selector:#selector(AppDelegate.updateText),
                                                                         userInfo:nil,
                                                                         repeats:true)
           RunLoop.current.add(countDownTimer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    @objc func updateText(){
        breakTimeoutCountDown = breakTimeoutCountDown - 1
        breakCountDownText.title = secondsToFormat(num:breakTimeoutCountDown)
    }
    
    @objc func updateLabel(){
        breakTimeCountDown = breakTimeCountDown - 1
        timeToNextBreak.title = secondsToFormat(num:breakTimeCountDown)
    }
    
    func secondsToFormat(num: Int) -> String {
        var minutes = String(num / 60)
        var seconds = String(num - Int(minutes)! * 60)
        if (minutes.characters.count == 1){
            minutes = "0" + minutes
        }
        if (seconds.characters.count == 1){
            seconds = "0" + seconds
        }
        return minutes + " : " + seconds;
    }
    
    @objc func resetBreakTimer(){
        self.timer!.invalidate()
        self.countDownTimer!.invalidate()
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        overlayWindow.setIsVisible(false)
        skipBreakMenuItem.isHidden = true
        breakMenuItem.isHidden = false
        
        for (_, window) in self.secondayOverlayWindows.enumerated() {
            window.setIsVisible(false)
            window.orderOut(window)
            
            if let objIndex=self.secondayOverlayWindows.index(of:window){
                self.secondayOverlayWindows.remove(at: objIndex)
            }
        }
        
        setBreakTimer()
        setBreakCountDownTimer()
    }
    
    @objc func changeImage(){
        let scrn: NSScreen = overlayWindow.screen!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width
        DispatchQueue.global().async {
            do {
                let url = "https://source.unsplash.com/random/"+String(Int(width))+"x"+String(Int(height))
                let data = try Data(contentsOf: URL(string: url)!)
                
                    let imageFromUrl =  NSImage(data: data)
                    self.overlayWindow.backgroundColor =  NSColor (patternImage: imageFromUrl!)
                    
                    for (_, window) in self.secondayOverlayWindows.enumerated() {
                        let screenSize = window.screen!.frame.size
                        let imageFromUrl2 =  NSImage(data: data)
                        imageFromUrl2!.size = NSSize(width: screenSize.width, height: screenSize.height)
                        window.backgroundColor =  NSColor (patternImage: imageFromUrl2!)
                    }
                    
          
            }catch  {
  
            }
            
        }

    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.overlayWindow.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
        
        let icon = NSImage(named: NSImage.Name(rawValue: "StatusBarIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        overlayWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)))
        
        overlayWindow.titlebarAppearsTransparent  =   true
        overlayWindow.titleVisibility             =   .hidden

        overlayWindow.styleMask = NSWindow.StyleMask.borderless
        overlayWindow.setFrameOrigin(NSPoint(x: 0, y: 0))
        
        overlayWindow.titleVisibility = NSWindow.TitleVisibility.hidden;
        overlayWindow.titlebarAppearsTransparent = true
        
        skipBreakMenuItem.isHidden = true
        overlayWindow.contentView?.addSubview(skipButton)
        overlayWindow.contentView?.addSubview(breakCountDownLabel)
        breakCountDownLabel.cell?.backgroundStyle = NSView.BackgroundStyle.raised
        
        overlayWindow.backgroundColor = NSColor (patternImage: NSImage(named: NSImage.Name(rawValue: "background"))!)
        
        getPreferences()
        changeImage()
        setBreakTimer()
        setBreakCountDownTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.breakForTextDidChange), name: NSNotification.Name(rawValue: "ICTextFieldDidChange"), object: BreakForTextField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.breakIntrevalTextDidChange), name: NSNotification.Name(rawValue: "ICTextFieldDidChange"), object: BreakIntervalTextField)
        
        
    }
    
    @objc func breakForTextDidChange(notification: NSNotification){
        var value = Int(breakForTextCell.title)
        if !(value ?? 0 > 0){
            value = 5
        }
        
        value = value! * 60
        breakTimeCountDown = value!
        
        
        let defaults = UserDefaults.standard
        defaults.set(value!, forKey: "BreakTime")
        
        breakTimeInSeconds = TimeInterval(breakTimeCountDown)
        breakMenuItem.title = "Break for " + String(breakTimeCountDown/60) + " min"
        
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        setBreakTimer()
        setBreakCountDownTimer()
    }
    
    @objc func breakIntrevalTextDidChange(notification: NSNotification){
        var value = Int(breakIntervalTextCell.title)
        if !(value ?? 0 > 0){
            value = 30
        }
        
        value = value! * 60
        
        breakTimeoutCountDown = value!
        
        breakTimeout = TimeInterval(breakTimeoutCountDown)
        
        let defaults = UserDefaults.standard
        defaults.set(value!, forKey: "BreakTimeout")
        
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        setBreakTimer()
        setBreakCountDownTimer()
    }
    
    
    func getPreferences(){
        
        if StartupLaunch.isAppLoginItem {
            launchAtStartupCheckbox.state = NSControl.StateValue.on
        } else {
            launchAtStartupCheckbox.state = NSControl.StateValue.off
        }
        
        let defaults = UserDefaults.standard
        let breakTimeoutCountDownStored = defaults.integer(forKey: "BreakTimeout")
        let breakTimeCountDownStored = defaults.integer(forKey: "BreakTime")
        
        if (breakTimeoutCountDownStored == 0){
            breakTimeoutCountDown = 25*60
        } else {
            breakTimeoutCountDown = breakTimeoutCountDownStored
        }
        
        if (breakTimeCountDownStored == 0){
            breakTimeCountDown = 5*60
        } else {
            breakTimeCountDown = breakTimeCountDownStored
        }
        
        breakTimeout = TimeInterval(breakTimeoutCountDown)
        breakTimeInSeconds = TimeInterval(breakTimeCountDown)
        breakMenuItem.title = "Break for " + String(breakTimeCountDown/60) + " min"
        
        breakForTextCell.title = String(breakTimeCountDown/60)
        breakIntervalTextCell.title = String(breakTimeoutCountDown/60)
        
    }
    
    func setBreakCountDownTimer(){
        breakTimeCountDown = Int(breakTimeout)
        
        timeToNextBreak.title = secondsToFormat(num:breakTimeCountDown)
        
        self.breakCountDownTimer = Timer.scheduledTimer(timeInterval: 1,
                                                                          target:self,
                                                                          
                                                                          selector:#selector(AppDelegate.updateLabel),
                                                                          userInfo:nil,
                                                                          repeats:true)
       RunLoop.current.add(breakCountDownTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func setBreakTimer(){
        self.breakTimer = Timer.scheduledTimer(timeInterval: breakTimeout,
                                                                 target:self,
                                                                 selector:#selector(AppDelegate.breakClicked),
                                                                 userInfo:nil,
                                                                 repeats:false)
       RunLoop.current.add(breakTimer!, forMode: RunLoopMode.commonModes)
        
    }
    
    func applicationWillTerminate(_ aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
}

