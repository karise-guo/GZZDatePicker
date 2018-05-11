//
//  ViewController.swift
//  GZZDatePicker
//
//  Created by Jonzzs on 2018/5/11.
//  Copyright © 2018年 Jonzzs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 年
    @IBAction func yearAction(_ sender: UIButton) {
        let datePicker = GZZDatePicker(.year)
        datePicker.show()
    }
    
    // 年 月
    @IBAction func monthAction(_ sender: UIButton) {
        let datePicker = GZZDatePicker(.month)
        datePicker.show()
    }
    
    // 年 月 日
    @IBAction func dayAction(_ sender: UIButton) {
        let datePicker = GZZDatePicker(.day)
        datePicker.show()
    }
    
    // 日期 小时 分钟
    @IBAction func timeAction(_ sender: UIButton) {
        let datePicker = GZZDatePicker(.time)
        datePicker.show()
    }
}

