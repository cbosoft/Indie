//
//  AppDelegate.swift
//  FanController
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var status_update_timer = Timer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = " "
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
        do {
            try SMCKit.open()
        }
        catch {
            print("could not open connection to SMC \(error)")
            exit(1)
        }
        

        status_update_timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
          timer in
            self.updateDisplayedText(timer: timer)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        SMCKit.close()
    }
    
    // https://stackoverflow.com/questions/29561476/run-background-task-as-loop-in-swift/29564713#29564713
    @objc func updateDisplayedText(timer:Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                var fan_str = "--"
                var temp_str = "--"
                
                do {
                    let fan1speed = try SMCKit.fanCurrentSpeed(0)
                    let fan2speed = try SMCKit.fanCurrentSpeed(1)
                    fan_str = String(format: "%.0f", (fan1speed+fan2speed)*0.5)
                    
                    let cpu1_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC1C"))
                    let cpu2_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC2C"))
                    let cpu3_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC3C"))
                    let cpu4_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC4C"))
                    let cpu_temp = (cpu1_temp + cpu2_temp + cpu3_temp + cpu4_temp) * 0.25
                    temp_str = String(format: "%.0f", cpu_temp)
                }
                catch {
                    // do nothing
                }
                
                self.statusItem.button?.title = String(format: "%@ rpm %@ºC", fan_str, temp_str)
              }
          }
    }


}

