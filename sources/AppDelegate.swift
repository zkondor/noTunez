//
//  AppDelegate.swift
//  noTunez
//
//  Updated by Andrew Sichevoi on Feb 2023.
//
//  Created by Tom Taylor on 04/01/2017.
//  Copyright © 2017 Twisted Digital Ltd. All rights reserved.
//

import Cocoa
import ServiceManagement
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let defaults = UserDefaults.standard

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // TODO: to follow an active screen to show, we can create an instance using the *current* NSScreen
    let osdNotification = makeOSDNotification(screen: NSScreen.main!)

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var launchAtLoginMenuItem: NSMenuItem!

    @IBAction func hideIconClicked(_ sender: NSMenuItem) {
        defaults.set(true, forKey: "hideIcon")
        NSStatusBar.system.removeStatusItem(statusItem)
        self.appIsLaunched()
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func launchAtLogin(_ sender: NSMenuItem) {
        LaunchAtLogin.isEnabled.toggle()
        self.updateLaunchAtLogin()
    }

    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem.menu = statusMenu
            statusItem.popUpMenu(statusMenu)
            statusItem.menu = nil
        } else {
            if statusItem.image == NSImage(named: "StatusBarButtonImage") {
                self.appIsLaunched()
                statusItem.image = NSImage(named: "StatusBarButtonImageActive")
            } else {
                statusItem.image = NSImage(named: "StatusBarButtonImage")
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = NSImage(named: "StatusBarButtonImageActive")

        if let button = statusItem.button {
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        if defaults.bool(forKey: "hideIcon") {
            NSStatusBar.system.removeStatusItem(statusItem)
        }

        self.updateLaunchAtLogin()
        self.appIsLaunched()
        self.createListener()
    }

    func updateLaunchAtLogin() -> Void {
        launchAtLoginMenuItem.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    func createListener() {
        let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
        workspaceNotificationCenter.addObserver(self, selector: #selector(self.appWillLaunch(note:)), name: NSWorkspace.willLaunchApplicationNotification, object: nil)
    }

    func appIsLaunched() {
        let apps = NSWorkspace.shared.runningApplications
        for currentApp in apps.enumerated() {
            let runningApp = apps[currentApp.offset]

            if(runningApp.activationPolicy == .regular) {
                if(runningApp.bundleIdentifier == "com.apple.iTunes") {
                    self.terminateProcessWith(Int(runningApp.processIdentifier), runningApp.localizedName!)
                }
                if(runningApp.bundleIdentifier == "com.apple.Music") {
                    self.terminateProcessWith(Int(runningApp.processIdentifier), runningApp.localizedName!)
                }
            }
        }
    }

    @objc func appWillLaunch(note:Notification) {
        if statusItem.image == NSImage(named: "StatusBarButtonImageActive") || defaults.bool(forKey: "hideIcon") {
            if let processName:String = note.userInfo?["NSApplicationBundleIdentifier"] as? String {
                if let processId = note.userInfo?["NSApplicationProcessIdentifier"] as? Int {
                    handleLaunchedApp(processId, processName)
                }
            }
        }
    }

    func handleLaunchedApp(_ processId: Int, _ processName: String) -> Void {
        switch processName {
        case "com.apple.iTunes", "com.apple.Music":
            self.terminateProcessWith(processId, processName)
            self.launchReplacement()
            self.showOSDNotification()
        default:break
        }
    }

    func launchReplacement() {
        let replacement = defaults.string(forKey: "replacement");
        if (replacement != nil) {
            let task = Process()

            task.arguments = [replacement!];
            task.launchPath = "/usr/bin/open"
            task.launch()
        }
    }

    func terminateProcessWith(_ processId:Int,_ processName:String) {
        let process = NSRunningApplication.init(processIdentifier: pid_t(processId))
        process?.forceTerminate()
    }

    func showOSDNotification() {
        if !defaults.bool(forKey: "notificationOnHandle.enabled") {
            return
        }

        let notificationInterval = max(defaults.double(forKey: "notificationOnHandle.showInterval"), 1.0)
        osdNotification.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + notificationInterval) { [self] in
            osdNotification.close()
        }
    }
}
