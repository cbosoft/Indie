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
class AppDelegate: NSViewController, NSApplicationDelegate {
    
    var vc: ViewController? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        do {
            try SMCKit.open()
        }
        catch {
            print("could not open connection to SMC \(error)")
            exit(1)
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "viewController") as? ViewController else {
            NSLog("Could not get ref to viewController!")
            exit(1)
        }
        
        self.vc = vc
        self.vc?.loadView()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        SMCKit.close()
    }


}

