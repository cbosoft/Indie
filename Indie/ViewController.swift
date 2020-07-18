//
//  ViewController.swift
//  Indie
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // MARK: IB Outlets
    @IBOutlet weak var rad_p1_type: NSButton!
    @IBOutlet weak var rad_p1_type_alt: NSButton!
    @IBOutlet weak var rad_p2_type: NSButton!
    @IBOutlet weak var rad_p2_type_alt: NSButton!
    @IBOutlet weak var dd_p1_choose: NSPopUpButton!
    @IBOutlet weak var dd_p2_choose: NSPopUpButton!
    @IBOutlet weak var dd_p1_custom_type: NSPopUpButton!
    @IBOutlet weak var dd_p2_custom_type: NSPopUpButton!
    @IBOutlet weak var ent_p1_custom: NSTextField!
    @IBOutlet weak var ent_p2_custom: NSTextField!
    @IBOutlet weak var chk_p2_enabled: NSButton!
    
    // MARK: Variables
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var update_timer = Timer()
    let popover: NSPopover = NSPopover()
    var properties: [Property] = []
    
    // MARK: TODO: generate based on system
    let predef_keys = [
        "Fan Av. Speed": ["F0Ac", "F1Ac", " rpm"],
        "CPU 0 Proximity Temp.": ["TC0P", "ºC"],
        "CPU 0 Av. Core Temp.": ["TC1C", "TC2C", "TC3C", "TC4C", "ºC"]
    ];
    
    let units = ["ºC", " rpm", " %", ""];
    
    // MARK: -
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        dd_p1_custom_type.addItems(withTitles: self.units)
        dd_p2_custom_type.addItems(withTitles: self.units)
        
        // setup popover
        popover.contentViewController = self
        popover.behavior = .transient
        
        // open popover on status click
        statusItem.button?.target = self
        statusItem.button?.action = #selector(show)
        
        // set up properties
        self.properties = self.load_previous_or_defaults()
        
        // show status initial value
        measureAndShow()
        
        // update values every second
        update_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
          timer in
            self.measureAndShow(timer: timer)
        }
    }
    // MARK: -
    
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
        self.rad_p2_type_alt.isEnabled = enstate
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
            var keys = self.predef_keys[keyName]!
            let units = keys.removeLast()
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
            
            let units = self.dd_p1_custom_type.titleOfSelectedItem!
            
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
            var keys = self.predef_keys[keyName]!
            let units = keys.removeLast()
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
            
            let units = self.dd_p2_custom_type.titleOfSelectedItem!
            
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
        self.save()
    }
    
    // MARK: -
    // MARK: Defaults
    /// Returns the default set of properties.
    func default_properties() -> [Property] {
        return [
            try! Property(fromArr: ["F0Ac", "F1Ac"], units: " rpm"),
            try! Property(fromArr: ["TC1C", "TC2C", "TC3C", "TC4C"], units: "ºC")
        ]
    }
    
    // MARK: -
    // MARK: Load
    /// Load the previous set of properties, or get the default set.
    func load_previous_or_defaults() -> [Property] {
        let defaults = UserDefaults.standard
        let value = defaults.array(forKey: "indie_properties")

        if value == nil {
            return default_properties()
        }
        
        let properties = value as! [[String]]
        var rv: [Property] = []
        for prop in properties {
            do {
                try rv.append(Property(fromStringArr: prop))
            }
            catch {
                print("Error loading from persistent storage")
                return default_properties()
            }
        }
        return rv
    }
    
    // MARK: -
    // MARK: Save
    /// Save the properties to persistent storage for loading next time.
    func save() {
        let defaults = UserDefaults.standard
        var prop_ser: [[String]] = []
        for prop in self.properties {
            prop_ser.append(prop.toStringArr())
        }
        defaults.set(prop_ser, forKey: "indie_properties")
    }
    
    }
    
    // MARK: -
    // MARK: UI Helper funcs
    
    func setProperty1IsCustom(_ v: Bool) {
        self.rad_p1_type.state = v ? NSControl.StateValue.off : NSControl.StateValue.on
        self.rad_p1_type_alt.state = v ? NSControl.StateValue.on : NSControl.StateValue.off
        self.chk_p1_changed("no")
    }
    
    func setProperty2IsCustom(_ v: Bool) {
        self.rad_p2_type.state = v ? NSControl.StateValue.off : NSControl.StateValue.on
        self.rad_p2_type_alt.state = v ? NSControl.StateValue.on : NSControl.StateValue.off
        self.chk_p2_changed("no")
    }
}
