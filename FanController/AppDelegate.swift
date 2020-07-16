//
//  AppDelegate.swift
//  FanController
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var status_update_timer = Timer()
    var control_timer = Timer()
    var cpu_temp  :Double = 0.0
    var fan_speed :Double = 0.0
    

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
        
        
        updateFanSpeed()
        updateDisplayedText()
        
        status_update_timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
          timer in
            self.updateDisplayedText(timer: timer)
        }
        
        control_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
          timer in
            self.updateFanSpeed(timer: timer)
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
    
    func updateDisplayedText() {
        self.statusItem.button?.title = String(format: "%.0f rpm\n%.0fºC", self.fan_speed, self.cpu_temp)
    }
    
    // https://stackoverflow.com/questions/29561476/run-background-task-as-loop-in-swift/29564713#29564713
    @objc func updateDisplayedText(timer:Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                self.updateDisplayedText()
             }
          }
    }
    
    func updateFanSpeed() {
        do {
            let fan1speed = try SMCKit.fanCurrentSpeed(0)
            let fan2speed = try SMCKit.fanCurrentSpeed(1)
            self.fan_speed = (fan1speed + fan2speed)*0.5

            let cpu1_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC1C"))
            let cpu2_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC2C"))
            let cpu3_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC3C"))
            let cpu4_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC4C"))
            self.cpu_temp = (cpu1_temp + cpu2_temp + cpu3_temp + cpu4_temp) * 0.25
        }
        catch {
            // do nothing
            NSLog("Error reading values \(error)")
        }
        
        // TODO get control action from PID controller
        let control_action :Double = 2e3
        let data = control_action.toFLT_()
        let bytes: SMCBytes = (data.0, data.1, data.2, data.3, UInt8(0), UInt8(0),
                               UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                               UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                               UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                               UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                               UInt8(0), UInt8(0))
        do {
            try SMCKit.writeData(SMCKey(code: IOFourCharCode(fromStaticString: "F0Tg"),
                                info: DataTypes.FLT_), data: bytes)
        }
        catch {
            NSLog("Couldn't write SMC: \(error)")
        }
    }
    
    @objc func updateFanSpeed(timer:Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                self.updateFanSpeed()
             }
          }
    }


}

