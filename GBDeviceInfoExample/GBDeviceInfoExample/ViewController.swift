//
//  ViewController.swift
//  GBDeviceInfoExample
//
//  Created by Carles Roig on 10/04/2019.
//

import UIKit
import GBDeviceInfo

class ViewController: UIViewController {

    @IBOutlet private weak var deviceView: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = GBDeviceInfo.deviceInfo().modelString ?? "Model not accesible"
        let os = String(format: "Running on %d.%d", GBDeviceInfo.deviceInfo().osVersion.major,  GBDeviceInfo.deviceInfo().osVersion.minor)
        deviceView?.text = model  + "\n" + os
    }
    
}

