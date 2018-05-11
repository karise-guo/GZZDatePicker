//
//  GZZDatePicker.swift
//  GZZDatePicker
//
//  Created by Jonzzs on 2017/9/6.
//  Copyright © 2017年 Jonzzs All rights reserved.
//

// MARK: - 日期选择框

import UIKit

// MARK: - 日期选择类型
public enum GZZDatePickerType: Int {
    case year // 年
    case month // 年月
    case day // 年月日
    case time // 年月日时分
}

private let kMinLoopCount = 8 // 最小循环数量（低于此数量的数据不需要循环）
private let kLoopCount = 1000 // 数据循环次数
private let kNormalLoadCount = 50 // 默认第一列自动加载的年数

public class GZZDatePicker: GZZBaseAlertView {

    private var leftComponentData = Array<String>() // 左列数据
    private var middleComponentData = Array<String>() // 中列数据
    private var rightComponentData = Array<String>() // 右列数据
    
    private var datePickerType: GZZDatePickerType = .month // 日期选择类型
    private var minDate: Date? // 最小日期
    private var maxDate: Date? // 最大日期
    private var selectedDate = Date() // 当前选中日期
    private var loadCount = kNormalLoadCount // 第一列自动加载的年数（会自动加载更多年数）
    
    /// 选择器
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        return pickerView
    }()
    
    private lazy var contentView: UIView = {
        return UIView()
    }()
    
    convenience init(_ type: GZZDatePickerType) {
        self.init()
        
        setType(type)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.text = "选择时间"
        setContentView(contentView)
        contentView.addSubview(pickerView)
        initData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        pickerView.frame = contentView.bounds
    }
    
    /// 获取日期字符
    private func getString(by date: Date, with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    /// 获取日期
    private func getDate(by string: String, with format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    private func initData() {
        let selYear = Calendar.current.component(.year, from: selectedDate)
        let selMonth = Calendar.current.component(.month, from: selectedDate)
        let selDate = getString(by: selectedDate, with: "yyyy-MM-dd")
        let selHour = Calendar.current.component(.hour, from: selectedDate)
        if datePickerType == .year {
            leftComponentData = getYearData()
            middleComponentData.removeAll()
            rightComponentData.removeAll()
        } else if datePickerType == .month {
            leftComponentData = getYearData()
            middleComponentData = getMonthData(by: selYear)
            rightComponentData.removeAll()
        } else if datePickerType == .day {
            leftComponentData = getYearData()
            middleComponentData = getMonthData(by: selYear)
            rightComponentData = getDayData(by: selYear, and: selMonth)
        } else if datePickerType == .time {
            leftComponentData = getDateData()
            middleComponentData = getHourData(by: selDate)
            rightComponentData = getMinuteData(by: selDate, and: selHour)
        }
        pickerView.reloadAllComponents()
        updateSelectedDate()
    }
    
    /// 更新选中日期的位置
    private func updateSelectedDate() {
        let selectedYear = Calendar.current.component(.year, from: selectedDate)
        if datePickerType == .year {
            if let yearRow = leftComponentData.index(of: "\(selectedYear)") {
                pickerView.selectRow(yearRow, inComponent: 0, animated: false)
            }
        } else if datePickerType == .month {
            if let yearRow = leftComponentData.index(of: "\(selectedYear)") {
                pickerView.selectRow(yearRow, inComponent: 0, animated: false)
            }
            if var monthRow = middleComponentData.index(of: "\(getString(by: selectedDate, with: "MM"))") {
                // 显示在循环数据的中间
                if middleComponentData.count > kLoopCount {
                    monthRow += middleComponentData.count / 2
                }
                pickerView.selectRow(monthRow, inComponent: 1, animated: false)
            }
        } else if datePickerType == .day {
            if let yearRow = leftComponentData.index(of: "\(selectedYear)") {
                pickerView.selectRow(yearRow, inComponent: 0, animated: false)
            }
            if var monthRow = middleComponentData.index(of: "\(getString(by: selectedDate, with: "MM"))") {
                // 显示在循环数据的中间
                if middleComponentData.count > kLoopCount {
                    monthRow += middleComponentData.count / 2
                }
                pickerView.selectRow(monthRow, inComponent: 1, animated: false)
            }
            if var dayRow = rightComponentData.index(of: "\(getString(by: selectedDate, with: "dd"))") {
                // 显示在循环数据的中间
                if rightComponentData.count > kLoopCount {
                    dayRow += rightComponentData.count / 2
                }
                pickerView.selectRow(dayRow, inComponent: 2, animated: false)
            }
        } else if datePickerType == .time {
            if let dateRow = leftComponentData.index(of: "\(getString(by: selectedDate, with: "yyyy-MM-dd"))") {
                pickerView.selectRow(dateRow, inComponent: 0, animated: false)
            }
            if var hourRow = middleComponentData.index(of: "\(getString(by: selectedDate, with: "HH"))") {
                // 显示在循环数据的中间
                if middleComponentData.count > kLoopCount {
                    hourRow += middleComponentData.count / 2
                }
                pickerView.selectRow(hourRow, inComponent: 1, animated: false)
            }
            if var minuteRow = rightComponentData.index(of: "\(getString(by: selectedDate, with: "mm"))") {
                // 显示在循环数据的中间
                if rightComponentData.count > kLoopCount {
                    minuteRow += rightComponentData.count / 2
                }
                pickerView.selectRow(minuteRow, inComponent: 2, animated: false)
            }
        }
    }
    
    /// 获取年份的数据
    private func getYearData() -> Array<String> {
        let selectedYear = Calendar.current.component(.year, from: selectedDate)
        var minYear = selectedYear - loadCount
        var maxYear = selectedYear + loadCount
        if let minDate = minDate {
            let minDateYear = Calendar.current.component(.year, from: minDate)
            if minDateYear > minYear {
                minYear = minDateYear
            }
        }
        if let maxDate = maxDate {
            let maxDateYear = Calendar.current.component(.year, from: maxDate)
            if maxDateYear < maxYear {
                maxYear = maxDateYear
            }
        }
        var yearData = Array<String>()
        for year in minYear...maxYear {
            yearData.append("\(year)")
        }
        return yearData
    }
    
    /// 获取月份的数据
    private func getMonthData(by year: Int) -> Array<String> {
        var minMonth = 1
        var maxMonth = 12
        if let minDate = minDate {
            if year == Calendar.current.component(.year, from: minDate) {
                minMonth = Calendar.current.component(.month, from: minDate)
            }
        }
        if let maxDate = maxDate {
            if year == Calendar.current.component(.year, from: maxDate) {
                maxMonth = Calendar.current.component(.month, from: maxDate)
            }
        }
        var monthData = Array<String>()
        for month in minMonth...maxMonth {
            monthData.append(String(format: "%02.0f", Float(month)))
        }
        // 循环数据
        var loopData = Array<String>()
        if monthData.count > kMinLoopCount && datePickerType != .time {
            for _ in 0..<kLoopCount {
                loopData.append(contentsOf: monthData)
            }
        } else {
            loopData.append(contentsOf: monthData)
        }
        return loopData
    }
    
    /// 获取天的数据
    private func getDayData(by year: Int, and month: Int) -> Array<String> {
        var dayCount = 0
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            dayCount = 31
        case 4, 6, 9, 11:
            dayCount = 30
        default:
            if year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) {
                dayCount = 29
            } else {
                dayCount = 28
            }
        }
        var minDay = 1
        var maxDay = dayCount
        if let minDate = minDate {
            let minDateYear = Calendar.current.component(.year, from: minDate)
            let minDateMonth = Calendar.current.component(.month, from: minDate)
            let minDateDay = Calendar.current.component(.day, from: minDate)
            if year == minDateYear && month == minDateMonth {
                minDay = minDateDay > dayCount ? dayCount : minDateDay
            }
        }
        if let maxDate = maxDate {
            let maxDateYear = Calendar.current.component(.year, from: maxDate)
            let maxDateMonth = Calendar.current.component(.month, from: maxDate)
            let maxDateDay = Calendar.current.component(.day, from: maxDate)
            if year == maxDateYear && month == maxDateMonth {
                maxDay = maxDateDay > dayCount ? dayCount : maxDateDay
            }
        }
        var dayData = Array<String>()
        for day in minDay...maxDay {
            dayData.append(String(format: "%02.0f", Float(day)))
        }
        // 循环数据
        var loopData = Array<String>()
        if dayData.count > kMinLoopCount && datePickerType != .time {
            for _ in 0..<kLoopCount {
                loopData.append(contentsOf: dayData)
            }
        } else {
            loopData.append(contentsOf: dayData)
        }
        return loopData
    }
    
    /// 获取日期数据
    private func getDateData() -> Array<String> {
        var dateData = Array<String>()
        for year: String in getYearData() {
            if let yearNumber = Int(year) {
                for month: String in getMonthData(by: yearNumber) {
                    if let monthNumber = Int(month) {
                        for day: String in getDayData(by: yearNumber, and: monthNumber) {
                            dateData.append("\(year)-\(month)-\(day)")
                        }
                    }
                }
            }
        }
        return dateData
    }
    
    /// 获取小时数据
    private func getHourData(by date: String) -> Array<String> {
        var minHour = 0
        var maxHour = 23
        let format = "yyyy-MM-dd"
        if let minDate = minDate {
            if date == getString(by: minDate, with: format) {
                minHour = Calendar.current.component(.hour, from: minDate)
            }
        }
        if let maxDate = maxDate {
            if date == getString(by: maxDate, with: format) {
                maxHour = Calendar.current.component(.hour, from: maxDate)
            }
        }
        var hourData = Array<String>()
        for hour in minHour...maxHour {
            hourData.append(String(format: "%02.0f", Float(hour)))
        }
        // 循环数据
        var loopData = Array<String>()
        if hourData.count > kMinLoopCount {
            for _ in 0..<kLoopCount {
                loopData.append(contentsOf: hourData)
            }
        } else {
            loopData.append(contentsOf: hourData)
        }
        return loopData
    }
    
    /// 获取分钟数据
    private func getMinuteData(by date: String, and hour: Int) -> Array<String> {
        var minMinute = 0
        var maxMinute = 59
        let format = "yyyy-MM-dd"
        if let minDate = minDate {
            if date == getString(by: minDate, with: format) && hour == Calendar.current.component(.hour, from: minDate) {
                minMinute = Calendar.current.component(.minute, from: minDate)
            }
        }
        if let maxDate = maxDate {
            if date == getString(by: maxDate, with: format) && hour == Calendar.current.component(.hour, from: maxDate) {
                maxMinute = Calendar.current.component(.minute, from: maxDate)
            }
        }
        var minuteData = Array<String>()
        for minute in minMinute...maxMinute {
            minuteData.append(String(format: "%02.0f", Float(minute)))
        }
        // 循环数据
        var loopData = Array<String>()
        if minuteData.count > kMinLoopCount {
            for _ in 0..<kLoopCount {
                loopData.append(contentsOf: minuteData)
            }
        } else {
            loopData.append(contentsOf: minuteData)
        }
        return loopData
    }
}

// MARK: - UIPickerViewDataSource
extension GZZDatePicker: UIPickerViewDataSource {
    
    /// 列数
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if datePickerType == .year {
            return 1
        } else if datePickerType == .month {
            return 2
        }
        return 3
    }
    
    /// 每列个数
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return leftComponentData.count
        } else if component == 1 {
            return middleComponentData.count
        }
        return rightComponentData.count
    }
}

// MARK: - UIPickerViewDelegate
extension GZZDatePicker: UIPickerViewDelegate {
    
    /// 每列宽度
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let padding: CGFloat = 35.0
        let width = pickerView.frame.width
        if datePickerType == .year {
            return width
        } else if datePickerType == .month {
            return (width - padding * 2) / 2
        } else if datePickerType == .day {
            return (width - padding * 3) / 3
        } else if datePickerType == .time {
            if component == 0 {
                return width / 3
            } else {
                return (width - padding * 3) / 3
            }
        }
        return 0
    }
    
    /// 每列内容
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleLabel: UILabel?
        if let view = view {
            titleLabel = view as? UILabel
        } else {
            titleLabel = UILabel()
            titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
            titleLabel?.textColor = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1)
            titleLabel?.textAlignment = .center
        }
        if component == 0 {
            titleLabel?.text = leftComponentData[row]
        } else if component == 1 {
            titleLabel?.text = middleComponentData[row]
        } else {
            titleLabel?.text = rightComponentData[row]
        }
        return titleLabel!
    }
    
    /// 选中事件
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if datePickerType == .year {
            let year = leftComponentData[pickerView.selectedRow(inComponent: 0)]
            if let date = getDate(by: year, with: "yyyy") {
                selectedDate = date
            }
        } else if datePickerType == .month {
            if component == 0 {
                if let year = Int(leftComponentData[row]) {
                    middleComponentData = getMonthData(by: year)
                    pickerView.reloadComponent(1) // 刷新月份数据
                }
            }
            let year = leftComponentData[pickerView.selectedRow(inComponent: 0)]
            let month = middleComponentData[pickerView.selectedRow(inComponent: 1)]
            if let date = getDate(by: "\(year)-\(month)", with: "yyyy-MM") {
                selectedDate = date
            }
        } else if datePickerType == .day {
            if component == 0 {
                if let year = Int(leftComponentData[row]) {
                    middleComponentData = getMonthData(by: year)
                    pickerView.reloadComponent(1) // 刷新月份
                    if let month = Int(middleComponentData[pickerView.selectedRow(inComponent: 1)]) {
                        rightComponentData = getDayData(by: year, and: month)
                        pickerView.reloadComponent(2) // 刷新天数
                    }
                }
            } else if component == 1 {
                var day = rightComponentData[pickerView.selectedRow(inComponent: 2)] // 原本选择的天数
                if let year = Int(leftComponentData[pickerView.selectedRow(inComponent: 0)]) {
                    if let month = Int(middleComponentData[row]) {
                        rightComponentData = getDayData(by: year, and: month)
                        pickerView.reloadComponent(2) // 刷新天数
                        // 显示原本选择的天数
                        let maxDay = rightComponentData.count / kLoopCount
                        if let dayCount = Int(day) {
                            if dayCount > maxDay {
                                day = String(maxDay)
                            }
                        }
                        if var dayRow = rightComponentData.index(of: day) {
                            if rightComponentData.count > kLoopCount {
                                dayRow += rightComponentData.count / 2
                            }
                            pickerView.selectRow(dayRow, inComponent: 2, animated: false)
                        }
                    }
                }
            }
            
            let year = leftComponentData[pickerView.selectedRow(inComponent: 0)]
            let month = middleComponentData[pickerView.selectedRow(inComponent: 1)]
            let day = rightComponentData[pickerView.selectedRow(inComponent: 2)]
            if let date = getDate(by: "\(year)-\(month)-\(day)", with: "yyyy-MM-dd") {
                selectedDate = date
            }
        } else if  datePickerType == .time {
            if component == 0 {
                let date = leftComponentData[row]
                middleComponentData = getHourData(by: date)
                pickerView.reloadComponent(1) // 刷新小时
                if let hour = Int(middleComponentData[pickerView.selectedRow(inComponent: 1)]) {
                    rightComponentData = getMinuteData(by: date, and: hour)
                    pickerView.reloadComponent(2) // 刷新分钟
                }
            } else if component == 1 {
                let date = leftComponentData[pickerView.selectedRow(inComponent: 0)]
                if let hour = Int(middleComponentData[row]) {
                    rightComponentData = getMinuteData(by: date, and: hour)
                    pickerView.reloadComponent(2) // 刷新分钟
                }
            }
            let date = leftComponentData[pickerView.selectedRow(inComponent: 0)]
            let hour = middleComponentData[pickerView.selectedRow(inComponent: 1)]
            let minute = rightComponentData[pickerView.selectedRow(inComponent: 2)]
            if let date = getDate(by: "\(date)-\(hour)-\(minute)", with: "yyyy-MM-dd-HH-mm") {
                selectedDate = date
            }
        }
        // 选中第一个或最后一个自动加载更多数据
        if component == 0 && (row == 0 || row == leftComponentData.count - 1) {
            initData()
        }
    }
}

// MARK: - 公有接口
extension GZZDatePicker {
    
    /// 设置日期选择类型（默认 .month）
    public func setType(_ type: GZZDatePickerType) {
        datePickerType = type
        loadCount = type == .time ? 1 : kNormalLoadCount
        initData()
    }
    
    /// 设置最小日期（默认不限制）
    public func setMinDate(_ date: Date?) {
        minDate = date
        initData()
    }
    
    /// 设置最大日期（默认不限制）
    public func setMaxDate(_ date: Date?) {
        maxDate = date
        initData()
    }
    
    public func getMinDate() -> Date? { return minDate } // 获取最小日期
    public func getMaxDate() -> Date? { return maxDate } // 获取最大日期
    
    /// 设置选中日期（默认当前时间）
    public func setSelectedDate(_ date: Date) {
        selectedDate = date
        initData()
    }
    
    /// 获取选中日期
    public func getSelectedDate() -> Date {
        return selectedDate
    }
}
