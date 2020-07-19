//
//  Property.swift
//  Indie
//
//  Created by Christopher Boyle on 18/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Foundation


class Property {
    
    static let custom_commands = ["battery": Property.battery ]
    
    var keys: [String] = []
    var units : String = ""
    
    enum errors : Error {
        case keyLengthError
    }
    
    init() {
        // do nothing
    }
    
    init(fromString key: String, units: String) throws {
        
        if key.count != 4 && !key_is_custom(key) {
            throw errors.keyLengthError
        }
        
        self.keys = [key]
        self.units = units
    }
    
    init(fromArr keys: [String], units: String) throws {
        
        for key in keys {
            if (key.count != 4 && !key_is_custom(key)) {
                throw errors.keyLengthError
            }
        }
        
        self.keys = keys
        self.units = units
    
    }
    
    init(fromStringArr strings: [String]) throws {
        var keys = strings
        let units = keys.removeLast()
        
        for key in keys {
            if (key.count != 4 && !key_is_custom(key)) {
                throw errors.keyLengthError
            }
        }
        
        self.keys = keys
        self.units = units
    }
    
    func key_is_custom(_ key: String) -> Bool {
        for kv in Property.custom_commands {
            if kv.key == key {
                return true
            }
        }
        return false
    }
    
    func is_empty() -> Bool {
        return self.keys.count == 0
    }
    
    func battery() -> Double {
        let rm = SMCKit.easyReadData("B0RM")
        let fc = SMCKit.easyReadData("B0FC")
        return rm*100.0/fc
    }
    
    func get_value(_ key: String) -> Double {
        
        if key.count == 4 {
            let val = SMCKit.easyReadData(key)
        
            if val == val {
                return val
            }
        }
        
        let f_maybe = Property.custom_commands[key]
        if f_maybe != nil {
            let f = f_maybe!
            return f(self)()
        }
        
        return Double.nan
    }
    
    func measure() -> String {
        var tot: Double = 0.0
        var n: Int = 0
        
        for k in self.keys {
            let val = self.get_value(k)
            
            // if val is not nan...
            if val == val {
                tot += val
                n += 1
            }
        }
        
        let display: Double = n>0 ? tot/Double(n) : Double.nan
        
        return String(format: "%.0f%@", display, self.units)
    }
    
    func toStringArr() -> [String] {
        var rv: [String] = []
        rv.append(contentsOf: self.keys)
        rv.append(self.units)
        return rv
    }
}
