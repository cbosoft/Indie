//
//  ViewController.swift
//  Indie
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var rad_p1_type: NSButton!
    @IBOutlet weak var rad_p2_type: NSButton!
    @IBOutlet weak var rad_p2_other: NSButton!
    @IBOutlet weak var dd_p1_choose: NSPopUpButton!
    @IBOutlet weak var dd_p2_choose: NSPopUpButton!
    @IBOutlet weak var dd_p1_custom_type: NSPopUpButton!
    @IBOutlet weak var dd_p2_custom_type: NSPopUpButton!
    @IBOutlet weak var ent_p1_custom: NSTextField!
    @IBOutlet weak var ent_p2_custom: NSTextField!
    @IBOutlet weak var chk_p2_enabled: NSButton!
    
    // TODO: generate based on system
    let predef_keys = [
        "Fan 0 Speed": "F0Ac",
        "CPU 0 Proximity Temp.": "TC0P",
        "CPU 0 Av. Core Temp.": ("TC1C", "TC2C", "TC3C", "TC4C")
        ] as [String : Any];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO load predef_keys based on system
        
        // Set predefined keys in drop downs
        dd_p1_choose.removeAllItems();
        dd_p2_choose.removeAllItems();
        for kv in self.predef_keys {
            dd_p1_choose.addItem(withTitle: kv.key)
            dd_p2_choose.addItem(withTitle: kv.key)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func quit_clicked(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func chck_p1_changed(_ sender: Any) {
        
        // predicate on predefined: true if predefined key
        let predef_p = self.rad_p1_type.state == NSControl.StateValue.on

        self.dd_p1_choose.isEnabled = predef_p;
        self.ent_p1_custom.isEnabled = !predef_p;
        self.dd_p1_custom_type.isEnabled = !predef_p;
    }
    
    @IBAction func chk_p2_changed(_ sender: Any) {
        
        // predicate on predefined: true if predefined key
        let predef_p = self.rad_p2_type.state == NSControl.StateValue.on

        self.dd_p2_choose.isEnabled = predef_p;
        self.ent_p2_custom.isEnabled = !predef_p;
        self.dd_p2_custom_type.isEnabled = !predef_p;
    }
    
    @IBAction func chk_p2_enabled_changed(_ sender: Any) {
        let enstate = self.chk_p2_enabled.state == NSControl.StateValue.on;
        let tstate = self.rad_p2_type.state == NSControl.StateValue.on
        
        self.rad_p2_type.isEnabled = enstate
        self.rad_p2_other.isEnabled = enstate
        self.dd_p2_choose.isEnabled = enstate && tstate
        self.ent_p2_custom.isEnabled = enstate && !tstate
        self.dd_p2_custom_type.isEnabled = enstate && !tstate
    }
    
}
