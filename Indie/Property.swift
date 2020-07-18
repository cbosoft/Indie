//
//  Property.swift
//  Indie
//
//  Created by Christopher Boyle on 18/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Foundation


class Property {
    
    var keys: [String] = []
    var units : String = ""
    
    enum errors : Error {
        case keyLengthError
    }
    
    init() {
        // do nothing
    }
    
    init(fromString key: String, units: String) throws {
        
        if key.count != 4 {
            throw errors.keyLengthError
        }
        
        self.keys = [key]
        self.units = units
    }
    
    init(fromArr keys: [String], units: String) throws {
        
        for key in keys {
            if (key.count != 4) {
                throw errors.keyLengthError
            }
        }
        
        self.keys = keys
        self.units = units
    
    }
    
    func is_empty() -> Bool {
        return self.keys.count == 0
    }
    
    func measure() -> String {
        var tot: Double = 0.0
        var n: Int = 0
        
        for k in self.keys {
            let val = SMCKit.easyReadData(k)
            
            // if val is not nan...
            if val == val {
                tot += val
                n += 1
            }
        }
        
        let display: Double = n>0 ? tot/Double(n) : Double.nan
        
        return String(format: "%.1f%@", display, self.units)
    }
}
