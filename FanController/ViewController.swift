//
//  ViewController.swift
//  FanController
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var chk_temperature: NSButton!
    @IBOutlet weak var chk_floating_setpoint: NSButton!
    @IBOutlet weak var quit_button: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func quit_clicked(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func chk_temperature_toggled(_ sender: Any) {
        self.chk_floating_setpoint.isEnabled = (self.chk_temperature.state == NSControl.StateValue.on)
    }
    
    @IBAction func chk_floating_toggled(_ sender: Any) {
    }
    
}
