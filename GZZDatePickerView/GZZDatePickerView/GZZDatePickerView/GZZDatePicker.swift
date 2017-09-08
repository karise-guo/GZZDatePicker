//
//  GZZDatePicker.swift
//  GZZDatePicker
//
//  Created by Jonzzs on 2017/9/6.
//  Copyright © 2017年 Jonzzs All rights reserved.
//

import UIKit
import EZSwiftExtensions

// MARK: - 日期选择类型
enum GZZDatePickerType: Int {
    
    case year // 年
    case month // 年月
    case day // 年月日
    case time // 年月日时分
}

private let minYear = "1970" // 默认最小年份
private let maxYearCount = 50 // 默认最多向后加载年数

class GZZDatePicker: UIView {

    fileprivate var leftComponentData = Array<String>() // 左列数据
    fileprivate var middleComponentData = Array<String>() // 中列数据
    fileprivate var rightComponentData = Array<String>() // 右列数据
    
    fileprivate var datePickerType: GZZDatePickerType = .month // 日期选择类型
    fileprivate var minDate = Date(fromString: "\(minYear)-01-01-00:00", format: "yyyy-MM-dd-HH:mm") // 最小日期
    fileprivate var maxDate = Date(fromString: "\(Date().year + maxYearCount)-12-31-23:59", format: "yyyy-MM-dd-HH:mm") // 最大日期
    fileprivate var selectedDate = Date() // 当前选中日期
    
    /// 选择背景
    private lazy var backView: UIView = {
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        backView.layer.borderColor = UIColor(r: 200, g: 200, b: 200).cgColor
        backView.layer.borderWidth = 0.4
        return backView
    }()

    /// 确定按钮
    private lazy var confirmButton: UIButton = {
        
        let confirmButton = UIButton()
        confirmButton.setTitle("确定", for: .normal)
        confirmButton.setTitleColor(UIColor.orange, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        return confirmButton
    }()
    
    /// 取消按钮
    private lazy var cancelButton: UIButton = {
        
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor.orange, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        return cancelButton
    }()
    
    /// 选择器
    private lazy var pickerView: UIPickerView = {
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        return pickerView
    }()
    
    convenience init(_ type: GZZDatePickerType) {
        self.init()
        self.setType(type)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initViews()
        self.initData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        
        self.alpha = 0
        self.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let pickerHeight: CGFloat = 250.0
        self.frame = CGRect(x: 0, y: 0, w: width, h: height)
        self.backView.frame = CGRect(x: 0, y: height, w: width, h: pickerHeight)
        self.addSubview(self.backView)
        
        let buttonWidth: CGFloat = 70
        let buttonHeight: CGFloat = 40
        let seperatorHeight: CGFloat = 0.4
        self.confirmButton.frame = CGRect(x: width - buttonWidth, y: 0, w: buttonWidth, h: buttonHeight)
        self.cancelButton.frame = CGRect(x: 0, y: 0, w: buttonWidth, h: buttonHeight)
        let seperatorView = UIView(x: 0, y: buttonHeight, w: width, h: seperatorHeight)
        seperatorView.backgroundColor =  UIColor(r: 200, g: 200, b: 200)
        self.pickerView.frame = CGRect(x: 0, y: buttonHeight + seperatorHeight, w: width, h: pickerHeight - buttonHeight - seperatorHeight)
        self.backView.addSubviews([self.confirmButton, self.cancelButton, seperatorView, self.pickerView])
        
        self.confirmButton.addTarget(for: .touchUpInside, action: { (sender) in
            self.hide()
        })
        self.cancelButton.addTarget(for: .touchUpInside, action: { (sender) in
            self.hide()
        })
        self.addTapGesture { (recognizer) in
            self.hide()
        }
    }
    
    private func initData() {
        
        let selYear = self.selectedDate.year
        let selMonth = self.selectedDate.month
        let selDate = self.selectedDate.toString(format: "yyyy-MM-dd")
        let selHour = self.selectedDate.hour
        if self.datePickerType == .year {
            
            self.leftComponentData = self.getYearData()
            self.middleComponentData.removeAll()
            self.rightComponentData.removeAll()
        } else if self.datePickerType == .month {
            
            self.leftComponentData = self.getYearData()
            self.middleComponentData = self.getMonthData(by: selYear)
            self.rightComponentData.removeAll()
        } else if self.datePickerType == .day {
            
            self.leftComponentData = self.getYearData()
            self.middleComponentData = self.getMonthData(by: selYear)
            self.rightComponentData = self.getDayData(by: selYear, and: selMonth)
        } else if self.datePickerType == .time {
            
            self.leftComponentData = self.getDateData()
            self.middleComponentData = self.getHourData(by: selDate)
            self.rightComponentData = self.getMinuteData(by: selDate, and: selHour)
        }
        self.pickerView.reloadAllComponents()
        self.updateSelectedDate()
    }
    
    /// 更新选中日期
    private func updateSelectedDate() {
        if self.datePickerType == .year {
            
            let yearRow = self.leftComponentData.index(of: "\(self.selectedDate.year)")
            self.pickerView.selectRow(yearRow!, inComponent: 0, animated: true)
        } else if self.datePickerType == .month {
            
            let yearRow = self.leftComponentData.index(of: "\(self.selectedDate.year)")
            let monthRow = self.middleComponentData.index(of: "\(self.selectedDate.toString(format: "MM"))")
            self.pickerView.selectRow(yearRow!, inComponent: 0, animated: true)
            self.pickerView.selectRow(monthRow!, inComponent: 1, animated: true)
        } else if self.datePickerType == .day {
            
            let yearRow = self.leftComponentData.index(of: "\(self.selectedDate.year)")
            let monthRow = self.middleComponentData.index(of: "\(self.selectedDate.toString(format: "MM"))")
            let dayRow = self.rightComponentData.index(of: "\(self.selectedDate.toString(format: "dd"))")
            self.pickerView.selectRow(yearRow!, inComponent: 0, animated: true)
            self.pickerView.selectRow(monthRow!, inComponent: 1, animated: true)
            self.pickerView.selectRow(dayRow!, inComponent: 2, animated: true)
        } else if self.datePickerType == .time {
            
            let dateRow = self.leftComponentData.index(of: "\(self.selectedDate.toString(format: "yyyy-MM-dd"))")
            let hourRow = self.middleComponentData.index(of: "\(self.selectedDate.toString(format: "HH"))")
            let minuteRow = self.rightComponentData.index(of: "\(self.selectedDate.toString(format: "mm"))")
            self.pickerView.selectRow(dateRow!, inComponent: 0, animated: true)
            self.pickerView.selectRow(hourRow!, inComponent: 1, animated: true)
            self.pickerView.selectRow(minuteRow!, inComponent: 2, animated: true)
        }
    }
    
    /// 获取年份的数据
    private func getYearData() -> Array<String> {
        
        let minYear = self.minDate?.year
        let maxYear = self.maxDate?.year
        var yearData = Array<String>()
        for year: Int in minYear!...maxYear! {
            yearData.append("\(year)")
        }
        return yearData
    }
    
    /// 获取月份的数据
    fileprivate func getMonthData(by year: Int) -> Array<String> {
        
        var minMonth = 1
        var maxMonth = 12
        if year == self.minDate?.year {
            minMonth = (self.minDate?.month)!
        }
        if year == self.maxDate?.year {
            maxMonth = (self.maxDate?.month)!
        }
        var monthData = Array<String>()
        for month: Int in minMonth...maxMonth {
            monthData.append(String(format: "%02.0f", month.toFloat))
        }
        return monthData
    }
    
    /// 获取天的数据
    fileprivate func getDayData(by year: Int, and month: Int) -> Array<String> {
        
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
        if year == self.minDate?.year && month == self.minDate?.month {
            if (self.minDate?.day)! > dayCount {
                minDay = dayCount
            } else {
                minDay = (self.minDate?.day)!
            }
        }
        if year == self.maxDate?.year && month == self.maxDate?.month {
            if (self.maxDate?.day)! > dayCount {
                maxDay = dayCount
            } else {
                maxDay = (self.maxDate?.day)!
            }
        }
        var dayData = Array<String>()
        for day: Int in minDay...maxDay {
            dayData.append(String(format: "%02.0f", day.toFloat))
        }
        return dayData
    }
    
    /// 获取日期数据
    private func getDateData() -> Array<String> {
        
        var dateData = Array<String>()
        for year: String in self.getYearData() {
            for month: String in self.getMonthData(by: year.toInt()!) {
                for day: String in self.getDayData(by: year.toInt()!, and: month.toInt()!) {
                    dateData.append("\(year)-\(month)-\(day)")
                }
            }
        }
        return dateData
    }
    
    /// 获取小时数据
    fileprivate func getHourData(by date: String) -> Array<String> {
        
        var minHour = 0
        var maxHour = 23
        let format = "yyyy-MM-dd"
        if date == self.minDate?.toString(format: format) {
            minHour = (self.minDate?.hour)!
        }
        if date == self.maxDate?.toString(format: format) {
            maxHour = (self.maxDate?.hour)!
        }
        var hourData = Array<String>()
        for hour: Int in minHour...maxHour {
            hourData.append(String(format: "%02.0f", hour.toFloat))
        }
        return hourData
    }
    
    /// 获取分钟数据
    fileprivate func getMinuteData(by date: String, and hour: Int) -> Array<String> {
        
        var minMinute = 0
        var maxMinute = 59
        let format = "yyyy-MM-dd"
        if date == self.minDate?.toString(format: format) && hour == self.minDate?.hour {
            minMinute = (self.minDate?.minute)!
        }
        if date == self.maxDate?.toString(format: format) && hour == self.maxDate?.hour {
            maxMinute = (self.maxDate?.minute)!
        }
        var minuteData = Array<String>()
        for minute: Int in minMinute...maxMinute {
            minuteData.append(String(format: "%02.0f", minute.toFloat))
        }
        return minuteData
    }
    
    /// 显示
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.backView.frame.y = UIScreen.main.bounds.size.height - 250
        }
    }
    
    /// 隐藏
    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.backView.frame.y = UIScreen.main.bounds.size.height
        }) { (isComplete) in
            self.removeFromSuperview()
        }
    }
    
    /// 设置日期选择类型（默认 .month）
    func setType(_ type: GZZDatePickerType) {
        self.datePickerType = type
        self.initData()
    }
    
    /// 设置最小日期（默认 1970 年）
    func setMinDate(_ date: Date) {
        self.minDate = date
        self.initData()
    }
    
    /// 设置最大日期（默认当前时间向后 50 年）
    func setMaxDate(_ date: Date) {
        self.maxDate = date
        self.initData()
    }
    
    func getMinDate() -> Date { return self.minDate! } // 获取最小日期
    func getMaxDate() -> Date { return self.maxDate! } // 获取最大日期
    
    /// 设置选中日期（默认当前时间）
    func setSelectedDate(_ date: Date) {
        self.selectedDate = date
        self.updateSelectedDate()
    }
    
    /// 获取选中日期
    func getSelectedDate() -> Date {
        return self.selectedDate
    }
    
    /// 设置确定按钮的点击事件
    func setConfirmButtonAction(buttonAction: @escaping (Date) -> Void) {
        self.confirmButton.addTarget(for: .touchUpInside, action: { (sender) in
            self.hide()
            buttonAction(self.getSelectedDate())
        })
    }
}


// MARK: - UIPickerViewDataSource
extension GZZDatePicker: UIPickerViewDataSource {
    
    /// 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.datePickerType == .year {
            return 1
        } else if self.datePickerType == .month {
            return 2
        }
        return 3
    }
    
    /// 每列个数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        let padding: CGFloat = 30.0
        if self.datePickerType == .year {
            return self.w
        } else if self.datePickerType == .month {
            return (self.w - padding * 2) / 2
        }
        return (self.w - padding * 3) / 3
    }
    
    /// 每列内容
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var titleLabel: UILabel?
        if let view = view {
            titleLabel = view as? UILabel
        } else {
            titleLabel = UILabel()
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            titleLabel?.textColor = UIColor(r: 102, g: 102, b: 102)
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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.datePickerType == .year {
            
            let year = self.leftComponentData[pickerView.selectedRow(inComponent: 0)]
            self.selectedDate = Date(fromString: year, format: "yyyy")!
        } else if self.datePickerType == .month {
            if component == 0 {
                
                let year = self.leftComponentData[row].toInt()
                self.middleComponentData = self.getMonthData(by: year!)
                pickerView.reloadComponent(1) // 刷新月份数据
            }
            let year = self.leftComponentData[pickerView.selectedRow(inComponent: 0)]
            let month = self.middleComponentData[pickerView.selectedRow(inComponent: 1)]
            self.selectedDate = Date(fromString: "\(year)-\(month)", format: "yyyy-MM")!
        } else if self.datePickerType == .day {
            if component == 0 {
                
                let year = self.leftComponentData[row].toInt()
                self.middleComponentData = self.getMonthData(by: year!)
                pickerView.reloadComponent(1) // 刷新月份
                
                let month = self.middleComponentData[pickerView.selectedRow(inComponent: 1)].toInt()
                self.rightComponentData = self.getDayData(by: year!, and: month!)
                pickerView.reloadComponent(2) // 刷新天数
            } else if component == 1 {
                
                let year = self.leftComponentData[pickerView.selectedRow(inComponent: 0)].toInt()
                let month = self.middleComponentData[row].toInt()
                self.rightComponentData = self.getDayData(by: year!, and: month!)
                pickerView.reloadComponent(2) // 刷新天使
            }
            let year = self.leftComponentData[pickerView.selectedRow(inComponent: 0)]
            let month = self.middleComponentData[pickerView.selectedRow(inComponent: 1)]
            let day = self.rightComponentData[pickerView.selectedRow(inComponent: 2)]
            self.selectedDate = Date(fromString: "\(year)-\(month)-\(day)", format: "yyyy-MM-dd")!
        } else if  self.datePickerType == .time {
            if component == 0 {
                
                let date = self.leftComponentData[row]
                self.middleComponentData = self.getHourData(by: date)
                pickerView.reloadComponent(1) // 刷新小时
                
                let hour = self.middleComponentData[pickerView.selectedRow(inComponent: 1)].toInt()
                self.rightComponentData = self.getMinuteData(by: date, and: hour!)
                pickerView.reloadComponent(2) // 刷新分钟
            } else if component == 1 {
                
                let date = self.leftComponentData[pickerView.selectedRow(inComponent: 0)]
                let hour = self.middleComponentData[row].toInt()
                self.rightComponentData = self.getMinuteData(by: date, and: hour!)
                pickerView.reloadComponent(2) // 刷新分钟
            }
            let date = self.leftComponentData[pickerView.selectedRow(inComponent: 0)]
            let hour = self.middleComponentData[pickerView.selectedRow(inComponent: 1)]
            let minute = self.rightComponentData[pickerView.selectedRow(inComponent: 2)]
            self.selectedDate = Date(fromString: "\(date)-\(hour)-\(minute)", format: "yyyy-MM-dd-HH-mm")!
        }
    }
}
