//
//  ViewController.swift
//  HaventecCommon
//
//  Created by Clifford Phan on 01/29/2019.
//  Copyright (c) 2019 Clifford Phan. All rights reserved.
//

import UIKit
import HaventecCommon

class ViewController: UIViewController {
    // Normal Properties
    var hashPin: String!
    
    // Button Properties
    @IBOutlet weak var pin: UITextField!
    @IBOutlet weak var hashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateHashPin() {
        let salt = try? HaventecHelper.generateSalt(size: 128)
        
        self.hashPin = HaventecHelper.hashPin(salt: salt!, pin: self.pin.text!)
    }
    
    @IBAction func hashButtonPressed() {
        self.generateHashPin()
    }
    
    @IBAction func checkPinLength() {
        
    }

}

