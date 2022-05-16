//
//  Created by Jeffrey Bergier on 2021/12/31.
//  Copyright © 2021 Saturday Apps.
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

struct TransformCollection<Collection: RandomAccessCollection, Output>: RandomAccessCollection
       where Collection.Index == Int
{
    typealias Transform = (Collection.Element) -> Output
    typealias Element = Output
    typealias Index = Int
    
    private let collection: Collection
    private let transform: Transform
    
    init(collection: Collection, transform: @escaping Transform) {
        self.collection = collection
        self.transform = transform
    }
    
    var startIndex: Int { self.collection.startIndex }
    var endIndex: Int { self.collection.endIndex }
    subscript(position: Int) -> Output {
        self.transform(self.collection[position])
    }
}