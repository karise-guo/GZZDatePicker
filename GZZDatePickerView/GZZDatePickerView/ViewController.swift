//
//  ViewController.swift
//  GZZDatePickerView
//
//  Created by Jonzzs on 2017/9/8.
//  Copyright © 2017年 Jonzzs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func yearAction(_ sender: UIButton) {
        
        let datePicker = GZZDatePicker(.year)
        datePicker.show()
    }
    
    @IBAction func monthAction(_ sender: UIButton) {
        
        let datePicker = GZZDatePicker(.month)
        datePicker.show()
    }
    
    @IBAction func dayAction(_ sender: UIButton) {
        
        let datePicker = GZZDatePicker(.day)
        datePicker.show()
    }
    
    @IBAction func timeAction(_ sender: UIButton) {
        
        let datePicker = GZZDatePicker(.time)
        datePicker.show()
    }
}

