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
    
    var properties: [Property] = []
    
    var storyboard: NSStoryboard
    var vc: ViewController
    
    override init() {
        print("start init")
        self.storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "viewController") as? ViewController else {
            NSLog("Could not get ref to viewController!")
            exit(1)
        }
        
        self.vc = vc
        super.init()
        print("end init")
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.vc.ad = self
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
        
        self.update()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        SMCKit.close()
    }
    
    @objc func showSettings() {
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
    
    func measureAndShow() {
        if (self.properties.count > 0) {
            var allempty = true
            for prop in self.properties {
                if (!prop.is_empty()) {
                    allempty = false
                }
            }
            
            if (allempty) {
                return
            }
            
            if (self.properties.count == 1) {
                self.statusItem.button?.title = self.properties[0].measure()
            }
            else {
                self.statusItem.button?.title = String(format: "%@\n%@",
                               self.properties[0].measure(),
                               self.properties[1].measure())
            }
        }
    }
    
    @objc func measureAndShow(timer: Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                self.measureAndShow()
             }
          }
    }
    
    func update() {
        self.properties = vc.get_properties()
    }


}

