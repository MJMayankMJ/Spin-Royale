//
//  UserStats+CoreDataProperties.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/20/25.
//
//

import Foundation
import CoreData


extension UserStats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserStats> {
        return NSFetchRequest<UserStats>(entityName: "UserStats")
    }

    @NSManaged public var totalCoins: Int64
    @NSManaged public var dailySpinsRemaining: Int16
    @NSManaged public var lastDailyRewardDate: Date?
    
    // ....
    @NSManaged public var collectedCoinsToday: Bool
    @NSManaged public var collectedSpinsToday: Bool

}

extension UserStats {
    
}

