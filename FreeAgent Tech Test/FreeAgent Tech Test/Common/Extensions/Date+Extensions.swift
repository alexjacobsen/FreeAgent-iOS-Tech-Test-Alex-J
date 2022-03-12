import Foundation

extension Date {

    var yearLongMonthShortDayShort: String {
        return DateFormatter.yearLongMonthShortDayShort.string(from: self)
    }

}
