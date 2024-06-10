//
//  ReminderDateCalculator.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 21/10/17.
//  Copyright © 2017 Saturday Apps.
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

import Foundation

extension Calendar {

    public func dateByAddingNumberOfDays(_ numberOfDays: Int, to date: Date) -> Date {
        if let date = self.date(byAdding: .day, value: numberOfDays, to: date) {
            return date
        } else {
            assertionFailure("Failed to calculate date")
            return date.addingTimeInterval(TimeInterval(numberOfDays * 60 * 60 * 24))
        }
    }

    public func numberOfDaysBetween(startDate: Date, endDate: Date, stopCountingAfterMaxDays maxDays: Int = 365) -> Int {
        var numberOfDays = 0
        var stop = false
        while !stop && numberOfDays < maxDays {
            let testDate = self.date(byAdding: .day, value: numberOfDays, to: startDate)!
            let test = self.isDate(testDate, inSameDayAs: endDate)
            guard test == false else {
                stop = true
                break
            }
            numberOfDays += 1
        }
        return numberOfDays
    }

    public func dateWithExact(hour desiredHour: Int, onSameDayAs inputDate: Date) -> Date {
        // get the start of the day
        let start = self.startOfDay(for: inputDate)
        // find out what the hour of the start of the day (sometimes its not 0)
        let startComponents = self.dateComponents([.hour], from: start)
        let startHour = startComponents.hour!
        // do the math to get the current hour of the start of the day (usually 0) to the desired hour
        // then add it to the start of the day date
        let end = self.date(byAdding: .hour, value: desiredHour - startHour, to: start)!

        return end
    }

    public func dateWithExact(hour desiredHour: Int, onSameDayAs inputDate: Date?) -> Date? {
        guard let inputDate = inputDate else { return nil }
        let adjusted: Date = self.dateWithExact(hour: desiredHour, onSameDayAs: inputDate)
        return adjusted
    }

    public func endOfDay(for date: Date) -> Date {
        let plusOneDay = self.date(byAdding: .day, value: 1, to: date)!
        let startOfPlusOneDay = self.startOfDay(for: plusOneDay)
        let oneSecondBeforeStartOfPlusOneDay = self.date(byAdding: .second, value: -1, to: startOfPlusOneDay)!
        return oneSecondBeforeStartOfPlusOneDay
    }

    public func userNotificationCompatibleDateComponents(with date: Date) -> DateComponents {
        return self.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }
}

public enum ReminderDateCalculator {

    public static func late(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let beginningOfTime = Date.distantPast
        let startOfNow = calendar.startOfDay(for: now)
        return DateInterval(start: beginningOfTime, end: startOfNow)
    }

    public static func today(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        // get the range of NOW
        let range = calendar.dateInterval(of: .day, for: now)!
        // get the previous end so all values are contiguous
        let previousEnd = self.late(calendar: calendar, now: now).end

        return DateInterval(start: previousEnd, end: range.end)
    }

    public static func tomorrow(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        // get tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        // get the range of tomorrow
        let range = calendar.dateInterval(of: .day, for: tomorrow)!
        // get the previous end so all values are contiguous
        let previousEnd = self.today(calendar: calendar, now: now).end

        return DateInterval(start: previousEnd, end: range.end)
    }

    public static func thisWeek(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        // find the start of next week using NOW as the reference
        let rangeOfWeekContainingToday = calendar.dateInterval(of: .weekOfMonth, for: now)!
        let endOfWeekContainingToday = rangeOfWeekContainingToday.end
        // this is a super cheap hack to roll things in to the next unit
        let beginningOfNextWeek = endOfWeekContainingToday.addingTimeInterval(1)
        let rangeOfNextWeek = calendar.dateInterval(of: .weekOfMonth, for: beginningOfNextWeek)!
        let startOfNextWeek = rangeOfNextWeek.start
        // get the previous end so all values are contiguous
        let previousEnd = self.tomorrow(calendar: calendar, now: now).end
        // make sure that start of next week is after previousEnd
        if startOfNextWeek >= previousEnd {
            return DateInterval(start: previousEnd, end: startOfNextWeek)
        } else {
            return DateInterval(start: previousEnd, end: previousEnd)
        }
    }

    public static func later(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfNextWeek = self.thisWeek(calendar: calendar, now: now).end
        let endOfDays = Date.distantFuture
        return DateInterval(start: startOfNextWeek, end: endOfDays)
    }
    
    public static func lateAndToday(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let start = self.late(calendar: calendar, now: now).start
        let end = self.today(calendar: calendar, now: now).end
        return .init(start: start, end: end)
    }
    
}
