import Foundation

extension DateFormatter {

    static var yearLongMonthShortDayShort: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}
