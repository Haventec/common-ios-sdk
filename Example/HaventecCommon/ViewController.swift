//
//  ViewController.swift
//  HaventecCommon
//
//  Created by Clifford Phan on 01/29/2019.
//  Copyright (c) 2019 Clifford Phan. All rights reserved.
//

import UIKit
import HaventecCommon

class ViewController: UIViewController, NSURLConnectionDataDelegate {
    let serverUrl: String = "https://api.haventec.com/authenticate/v1-2"
    
    // Add Device Request
    let applicationUuid: String = "e4c8380a-20db-4814-91e7-563b35a7381c"
    let apiKey: String = "d997872d-7b51-4953-b338-5980e7ec128f"
    let haventecUsername: String = "foobar123"
    let haventecEmail: String = "clifford.phan@haventec.com"
    
    // Activate Device Request
    let pinCode: String = "1234";
    
    // Add Device Response
    var activationToken: String!
    var deviceUuid: String!
    
    // Activate Device Response
    var authKey: String!
    var accessToken: AccessToken!

//    private UserDetails userDetails;
//    private List<DeviceDetails> devices;
    
    // UIKit
    @IBOutlet weak var addDeviceButton: UIButton!
    @IBOutlet weak var activateDeviceButton: UIButton!
    @IBOutlet weak var addDeviceResponse: UILabel!
    @IBOutlet weak var activateDeviceResponse: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addDeviceResponse.adjustsFontSizeToFitWidth = true
        addDeviceResponse.lineBreakMode = NSLineBreakMode.byWordWrapping
        addDeviceResponse.numberOfLines = 0
        
        activateDeviceResponse.adjustsFontSizeToFitWidth = true
        activateDeviceResponse.lineBreakMode = NSLineBreakMode.byWordWrapping
        activateDeviceResponse.numberOfLines = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addDevice() {
        let url = URL(string: serverUrl + "/self-service/device")!
        
        let jsonString: String = "{"
            + "\"applicationUuid\": \"" + applicationUuid + "\","
            + "\"username\": \"" + haventecUsername + "\","
            + "\"email\": \"" + haventecEmail + "\","
            + "\"deviceName\": \"iOS Device\""
            + "}";
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpMethod = "POST"
        request.httpBody = jsonString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                DispatchQueue.main.async {
                    self.addDeviceResponse.text = error?.localizedDescription
                }
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                self.addDeviceResponse.text = responseString
                let jsonData = responseString!.data(using: .utf8)!
                let decoder = JSONDecoder()
                
                do {
                    let response = try decoder.decode(AddDeviceResponse.self, from: jsonData)
                    self.deviceUuid = response.deviceUuid
                    self.activationToken = response.activationToken
                } catch {
                    print("Unexpected error: \(error)")
                    return
                }
            }
            print("responseString = \(responseString!)")
        }
        
        task.resume()
    }
    
    @IBAction func activateDevice() {
        guard let salt = try? HaventecCommon.generateSalt(size: 128) else { return }
        let hashedPin: String = HaventecCommon.hashPin(salt: salt, pin: pinCode)
        
        let url = URL(string: serverUrl + "/authentication/activate/device")!
        
        let jsonString: String = "{"
            + "\"applicationUuid\": \"" + applicationUuid + "\","
            + "\"username\": \"" + haventecUsername + "\","
            + "\"deviceUuid\": \"" + deviceUuid + "\","
            + "\"hashedPin\": \"" + hashedPin + "\","
            + "\"activationToken\": \"" + activationToken + "\""
            + "}";
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpMethod = "POST"
        request.httpBody = jsonString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                DispatchQueue.main.async {
                    self.activateDeviceResponse.text = error?.localizedDescription
                }
                print("error=\(error!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                self.activateDeviceResponse.text = responseString
                let jsonData = responseString!.data(using: .utf8)!
                let decoder = JSONDecoder()
                
                do {
                    let response = try decoder.decode(ActivateDeviceResponse.self, from: jsonData)
                    self.authKey = response.authKey
                    self.accessToken = response.accessToken
                } catch {
                    print("Unexpected error: \(error)")
                    return
                }
            }
            print("responseString = \(responseString!)")
        }
        
        task.resume()
    }

}
