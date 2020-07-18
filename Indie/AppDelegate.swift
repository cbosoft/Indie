//
//  AppDelegate.swift
//  Indie
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var update_timer = Timer()
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        statusItem.button?.font = NSFont.systemFont(ofSize: 8)
        
        do {
            try SMCKit.open()
        }
        catch {
            print("could not open connection to SMC \(error)")
            exit(1)
        }
        
        measureAndShow()
        
        update_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
          timer in
            self.measureAndShow(timer: timer)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        SMCKit.close()
    }
    
    @objc func showSettings() {
        let popoverView = NSPopover()
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "viewController") as? ViewController else {
            NSLog("Could not get ref to viewController!")
            exit(1)
        }
        
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
    
    func measureAndShow() {
        var fan_speed = Double.nan;
        var cpu_temp = Double.nan;
        
        do {
            let fan1speed = try SMCKit.fanCurrentSpeed(0)
            let fan2speed = try SMCKit.fanCurrentSpeed(1)
            fan_speed = (fan1speed + fan2speed)*0.5

            let cpu1_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC1C"))
            let cpu2_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC2C"))
            let cpu3_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC3C"))
            let cpu4_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC4C"))
            cpu_temp = (cpu1_temp + cpu2_temp + cpu3_temp + cpu4_temp) * 0.25
        }
        catch {
            // do nothing
            NSLog("Error reading values \(error)")
        }
        
        self.statusItem.button?.title = String(format: "%.0f rpm\n%.0fºC", fan_speed, cpu_temp)
    }
    
    @objc func measureAndShow(timer: Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                self.measureAndShow()
             }
          }
    }


}

