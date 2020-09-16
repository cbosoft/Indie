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
    
    // MARK: TODO
    /// Need to change these to ones that are generated based on the capabilities of the system.
    /// Not all Macs have 4 cores, not all have ONLY 4 cores. Not all macs have fans, not all macs
    /// have two fans etc etc.
    let predef_keys = [
        "Fan Av. Speed": ["F0Ac", "F1Ac", " rpm"],
        "Battery Percentage": ["BRSC", "%"],
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
        self.reflect()
        
        // show status initial value
        measureAndShow()
        
        // update values every second
        update_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
          timer in
            self.measureAndShow(timer: timer)
        }
    }
    
    // MARK: -
    // MARK: Show Popover
    @objc func show() {
        self.popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
    
    // MARK: -
    // MARK: Measure and show
    func measureAndShow() {
        if (self.properties.count == 1) {
            statusItem.button?.font = NSFont.systemFont(ofSize: 13)
            self.statusItem.button?.title = self.properties[0].measure()
        }
        else if self.properties.count == 2 {
            statusItem.button?.font = NSFont.systemFont(ofSize:13)
            self.statusItem.button?.title = String(format: "%@ | %@",
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
    
    // MARK: -
    // MARK: IB Actions

    @IBAction func quit_clicked(_ sender: Any) {
        exit(0)
    }
    
    /// Check box deciding whether Property 1 is custom or predefined
    @IBAction func chk_p1_changed(_ sender: Any) {
        self.updateProperty1IsCustom()
        self.update()
    }
    
    /// Check box deciding whether Property 2 is custom or predefined
    @IBAction func chk_p2_changed(_ sender: Any) {
        self.updateProperty2IsCustom()
        self.update()
    }
    
    /// Checkbox deciding whether p2 is enabled or nah
    @IBAction func chk_p2_enabled_changed(_ sender: Any) {
        self.updateProperty2IsEnabled()
        self.update()
    }
    
    /// Any non-control changing UI element is changed (drop downs, text entries)
    @IBAction func propert_sub_changed(_ sender: Any) {
        self.update()
    }
    
    // MARK: -
    // MARK: Get Property 1
    func get_property_1() -> Property
    {
        var prop = Property()
        
        if (self.rad_p1_type == nil) {
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
                print("property init failed \(error)")
            }
        }
        else {
            let s = self.ent_p1_custom.stringValue
            let parts = s.split(separator: ",")
            var keys: [String] = []
            for part in parts {
                let ss = String(part)
                keys.append(ss)
            }
            
            let units = self.dd_p1_custom_type.titleOfSelectedItem ?? ""
            
            do {
                prop = try Property(fromArr: keys, units: units)
            }
            catch {
                // Property init failed, leave it as default
                print("custom property init failed \(error)")
            }
        }
        
        return prop
    }
    
    // MARK: -
    // MARK: Get Property 2
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

        if (self.rad_p2_type.state == NSControl.StateValue.on) {
            let keyName = self.dd_p2_choose.titleOfSelectedItem ?? self.predef_keys.keys.first!
            var keys = self.predef_keys[keyName]!
            let units = keys.removeLast()
            do {
                prop = try Property(fromArr: keys, units: units)
            }
            catch {
                // Property init failed, leave it as default
                print("property init failed \(error)")
            }
        }
        else {
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
                print("custom property init failed \(error)")
            }
        }
        
        return prop
    }
    
    // MARK: -
    // MARK: Get Properties
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
    
    // MARK: -
    // MARK: Update
    /// Called after the form is changed by the user. The properties array is rebuilt, and saved to disk.
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
                print("Error loading from persistent storage \(error)")
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
    
    // MARK: -
    // MARK: Reflect state->UI
    /// Reflect the contents of the properties array onto the UI. Called after the a previous state is loaded.
    func reflect() {
        
        if self.properties.count == 0 {
            return
        }
        
        let prop1 = self.properties[0].toStringArr()
        let predef_key = self.strArr_in_predef(strings: prop1)
        if predef_key != nil {
            // is prebuilt
            self.setProperty1IsCustom(false)
            let predef_key_name = predef_key!
            dd_p1_choose.selectItem(withTitle: predef_key_name)
        }
        else {
            // is custom
            self.setProperty1IsCustom(true)
            var keys = prop1
            let units = keys.removeLast()
            var s = keys.removeFirst()
            for key in keys {
                s += ","
                s += key
            }
            ent_p1_custom.stringValue = s
            self.dd_p1_custom_type.selectItem(withTitle: units)
        }
        

        self.setPropert2IsEnabled(self.properties.count == 2)
        if self.properties.count == 2 {
            let prop2 = self.properties[1].toStringArr()
            let predef_key = self.strArr_in_predef(strings: prop2)
            if predef_key != nil {
                // is prebuilt
                self.setProperty2IsCustom(false)
                let predef_key_name = predef_key!
                dd_p2_choose.selectItem(withTitle: predef_key_name)
            }
            else {
                // is custom
                self.setProperty2IsCustom(true)
                var keys = prop2
                let units = keys.removeLast()
                var s = keys.removeFirst()
                for key in keys {
                    s += ","
                    s += key
                }
                ent_p2_custom.stringValue = s
                self.dd_p2_custom_type.selectItem(withTitle: units)
            }
        }
    }
    
    // MARK: -
    // MARK: check predefined for strarr
    func strArr_in_predef(strings: [String]) -> String? {
        for kv in self.predef_keys {
            if strings == kv.value {
                return kv.key
            }
        }
        return nil
    }
    
    // MARK: -
    // MARK: UI Helper funcs
    
    func setProperty1IsCustom(_ isCustom: Bool) {
        self.rad_p1_type.state = isCustom ? NSControl.StateValue.off : NSControl.StateValue.on
        self.rad_p1_type_alt.state = isCustom ? NSControl.StateValue.on : NSControl.StateValue.off
        self.updateProperty1IsCustom()
    }
    
    func updateProperty1IsCustom() {
        let isCustom = self.rad_p1_type.state == NSControl.StateValue.on
        self.dd_p1_choose.isEnabled = isCustom
        self.ent_p1_custom.isEnabled = !isCustom
        self.dd_p1_custom_type.isEnabled = !isCustom
    }
    
    func setProperty2IsCustom(_ isCustom: Bool) {
        self.rad_p2_type.state = isCustom ? NSControl.StateValue.off : NSControl.StateValue.on
        self.rad_p2_type_alt.state = isCustom ? NSControl.StateValue.on : NSControl.StateValue.off
        self.updateProperty2IsCustom()
    }
    
    func updateProperty2IsCustom() {
        let isCustom = self.rad_p2_type.state == NSControl.StateValue.on
        self.dd_p2_choose.isEnabled = isCustom
        self.ent_p2_custom.isEnabled = !isCustom
        self.dd_p2_custom_type.isEnabled = !isCustom
    }
    
    func setPropert2IsEnabled(_ isEnabled: Bool) {
        self.chk_p2_enabled.state = isEnabled ? NSControl.StateValue.on : NSControl.StateValue.off
        self.updateProperty2IsEnabled()
    }
    
    func updateProperty2IsEnabled() {
        let isEnabled = self.chk_p2_enabled.state == NSControl.StateValue.on
        let isCustom = self.rad_p2_type.state == NSControl.StateValue.on
        
        self.rad_p2_type.isEnabled = isEnabled
        self.rad_p2_type_alt.isEnabled = isEnabled
        self.dd_p2_choose.isEnabled = isEnabled && isCustom
        self.ent_p2_custom.isEnabled = isEnabled && !isCustom
        self.dd_p2_custom_type.isEnabled = isEnabled && !isCustom
        
    }
}
