//
//  CD_Base.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreData

@objc(CD_Base)
internal class CD_Base: NSManagedObject {

    class var entityName: String { "CD_Base" }
    class var requestBase: NSFetchRequest<CD_Base> {
        NSFetchRequest<CD_Base>(entityName: self.entityName)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        let now = Date()
        self.raw_dateCreated = now
        self.raw_dateModified = now
    }
    
    override func willSave() {
        super.willSave()
        
        let now = Date()
        let mod = self.raw_dateModified ?? now
        let interval = abs(mod.timeIntervalSince(now))
        guard interval >= 1 else { return }
        self.raw_dateModified = now
    }
}

@objc(CD_Migrated)
internal class CD_Migrated: CD_Base {
    class override var entityName: String { "CD_Migrated" }
    class var request: NSFetchRequest<CD_Migrated> {
        NSFetchRequest<CD_Migrated>(entityName: self.entityName)
    }
}
