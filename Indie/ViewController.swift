//
//  ViewController.swift
//  Indie
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var update_timer = Timer()
    
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
    
    let popover: NSPopover = NSPopover()
    var properties: [Property] = []
    
    // TODO: generate based on system
    let predef_keys = [
        "Fan 0 Speed": ["F0Ac", "Speed"],
        "CPU 0 Proximity Temp.": ["TC0P", "Temperature"],
        "CPU 0 Av. Core Temp.": ["TC1C", "TC2C", "TC3C", "TC4C", "Temperature"]
    ];
    
    let units = [
        "Temperature": "ºC",
        "Speed": " rpm",
        "None": ""
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view loaded")
        // TODO load predef_keys based on system
        
        // Set predefined keys in drop downs
        dd_p1_choose.removeAllItems();
        dd_p2_choose.removeAllItems();
        for kv in self.predef_keys {
            dd_p1_choose.addItem(withTitle: kv.key)
            dd_p2_choose.addItem(withTitle: kv.key)
        }
        
        // Set units in drop downs
        dd_p1_custom_type.removeAllItems();
        dd_p2_custom_type.removeAllItems();
        for kv in self.units {
            dd_p1_custom_type.addItem(withTitle: kv.key)
            dd_p2_custom_type.addItem(withTitle: kv.key)
        }
        
        popover.contentViewController = self
        popover.behavior = .transient
        
        statusItem.button?.target = self
        statusItem.button?.action = #selector(show)
        statusItem.button?.font = NSFont.systemFont(ofSize: 8)
        
        
        
        measureAndShow()
        
        update_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
          timer in
            self.measureAndShow(timer: timer)
        }
    }
    
    @objc func show() {
        self.popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func measureAndShow() {
        if (self.properties.count == 1) {
            statusItem.button?.font = NSFont.systemFont(ofSize: 13)
            self.statusItem.button?.title = self.properties[0].measure()
        }
        else if self.properties.count == 2 {
            statusItem.button?.font = NSFont.systemFont(ofSize: 8)
            self.statusItem.button?.title = String(format: "%@\n%@",
                            self.properties[0].measure(),
                            self.properties[1].measure())
        }
        else {
            // No properties
            statusItem.button?.font = NSFont.systemFont(ofSize: 13)
            self.statusItem.button?.title = "𝒾𝑛𝒹𝒾𝓮"
        }
    }
    
    @objc func measureAndShow(timer: Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                self.measureAndShow()
             }
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
        
        self.update()
    }
    
    @IBAction func chk_p2_changed(_ sender: Any) {
        
        // predicate on predefined: true if predefined key
        let predef_p = self.rad_p2_type.state == NSControl.StateValue.on

        self.dd_p2_choose.isEnabled = predef_p;
        self.ent_p2_custom.isEnabled = !predef_p;
        self.dd_p2_custom_type.isEnabled = !predef_p;
        
        self.update()
    }
    
    @IBAction func chk_p2_enabled_changed(_ sender: Any) {
        let enstate = self.chk_p2_enabled.state == NSControl.StateValue.on;
        let tstate = self.rad_p2_type.state == NSControl.StateValue.on
        
        self.rad_p2_type.isEnabled = enstate
        self.rad_p2_other.isEnabled = enstate
        self.dd_p2_choose.isEnabled = enstate && tstate
        self.ent_p2_custom.isEnabled = enstate && !tstate
        self.dd_p2_custom_type.isEnabled = enstate && !tstate
        
        self.update()
    }
    
    func get_property_1() -> Property
    {
        var prop = Property()
        
        if (self.rad_p1_type == nil) {
            print("rad is nil")
            return prop
        }

        if (self.rad_p1_type.state == NSControl.StateValue.on) {
            let keyName = self.dd_p1_choose.titleOfSelectedItem ?? self.predef_keys.keys.first!
            print(keyName)
            var keys = self.predef_keys[keyName]!
            print(keys)
            let units = self.units[keys.last!] ?? "";
            let _ = keys.removeLast()
            do {
                prop = try Property(fromArr: keys, units: units)
            }
            catch {
                // Property init failed, leave it as default
                print("property init failed")
            }
        }
        else {
            // TODO construct from custom
            let s = self.ent_p1_custom.stringValue
            let parts = s.split(separator: ",")
            var keys: [String] = []
            for part in parts {
                let ss = String(part)
                keys.append(ss)
            }
            
            let units = self.units[self.dd_p1_custom_type.titleOfSelectedItem!]!
            
            do {
                prop = try Property(fromArr: keys, units: units)
            }
            catch {
                // Property init failed, leave it as default
                print("custom property init failed")
            }
        }
        
        return prop
    }
    
    
    func get_property_2() -> Property
    {
        var prop = Property()
        
        if (self.chk_p2_enabled?.state == NSControl.StateValue.off) {
            return prop
        }
        
        if (self.rad_p2_type == nil) {
            print("rad is nil")
            return prop
        }

        if (self.rad_p1_type.state == NSControl.StateValue.on) {
            let keyName = self.dd_p2_choose.titleOfSelectedItem ?? self.predef_keys.keys.first!
            print(keyName)
            var keys = self.predef_keys[keyName]!
            print(keys)
            let units = self.units[keys.last!] ?? "";
            let _ = keys.removeLast()
            do {
                prop = try Property(fromArr: keys, units: units)
            }
            catch {
                // Property init failed, leave it as default
                print("property init failed")
            }
        }
        else {
            // TODO construct from custom
            let s = self.ent_p2_custom.stringValue
            let parts = s.split(separator: ",")
            var keys: [String] = []
            for part in parts {
                let ss = String(part)
                keys.append(ss)
            }
            
            let units = self.units[self.dd_p2_custom_type.titleOfSelectedItem!]!
            
            do {
                prop = try Property(fromArr: keys, units: units)
            }
            catch {
                // Property init failed, leave it as default
                print("custom property init failed")
            }
        }
        
        return prop
    }
    
    func get_properties() -> [Property] {
        var rv: [Property] = []
        
        let p1 = self.get_property_1()
        if (!p1.is_empty()) {
            rv.append(p1)
        }
        
        let p2 = self.get_property_2()
        if (!p2.is_empty()) {
            rv.append(p2)
        }
        
        return rv
    }
    
    func update() {
        self.properties = self.get_properties()
    }
    
}
