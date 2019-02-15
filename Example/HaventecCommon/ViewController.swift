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
    var serverUrl: String!

    // Add Device Request
    var applicationUuid: String!
    var apiKey: String!
    var haventecUsername: String!
    var haventecEmail: String!

    // Activate Device Request
    var pinCode: String!
    
    // Add Device Response
    var activationToken: String!
    var deviceUuid: String!
    
    // Activate Device Response
    var authKey: String!
    var accessToken: AccessToken!
    
    // UIKit
    @IBOutlet weak var addDeviceButton: UIButton!
    @IBOutlet weak var activateDeviceButton: UIButton!
    
    @IBOutlet weak var addDeviceStatus: UILabel!
    @IBOutlet weak var addDeviceMessage: UILabel!
    @IBOutlet weak var addDeviceCode: UILabel!
    @IBOutlet weak var addDeviceActivationToken: UILabel!
    @IBOutlet weak var addDeviceDeviceUuid: UILabel!
    
    @IBOutlet weak var activateDeviceStatus: UILabel!
    @IBOutlet weak var activateDeviceMessage: UILabel!
    @IBOutlet weak var activateDeviceCode: UILabel!
    @IBOutlet weak var activateDeviceAuthKey: UILabel!
    @IBOutlet weak var activateDeviceAccessTokenValue: UILabel!
    @IBOutlet weak var activateDeviceAccessTokenType: UILabel!
    
    private func loadPropertyFile() {
        guard let fileUrl = Bundle.main.url(forResource: "App", withExtension: "plist") else { return }
        guard let properties = NSDictionary(contentsOf: fileUrl) as? [String:Any] else { return }
        
        serverUrl = properties["serverUrl"] as? String
        applicationUuid = properties["applicationUuid"] as? String
        apiKey = properties["apiKey"] as? String
        haventecUsername = properties["haventecUsername"] as? String
        haventecEmail = properties["haventecEmail"] as? String
        pinCode = properties["pinCode"] as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPropertyFile()
        // Do any additional setup after loading the view, typically from a nib.
        addDeviceStatus.font = addDeviceStatus.font.withSize(10)
        addDeviceMessage.font = addDeviceStatus.font.withSize(10)
        addDeviceCode.font = addDeviceStatus.font.withSize(10)
        addDeviceActivationToken.font = addDeviceStatus.font.withSize(10)
        addDeviceDeviceUuid.font = addDeviceStatus.font.withSize(10)
        
        activateDeviceStatus.font = activateDeviceStatus.font.withSize(10)
        activateDeviceMessage.font = activateDeviceMessage.font.withSize(10)
        activateDeviceCode.font = activateDeviceCode.font.withSize(10)
        activateDeviceAuthKey.font = activateDeviceAuthKey.font.withSize(10)
        activateDeviceAccessTokenValue.font = activateDeviceAccessTokenValue.font.withSize(10)
        activateDeviceAccessTokenType.font = activateDeviceAccessTokenType.font.withSize(10)
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
                    self.addDeviceMessage.text = "Response Status: UNSUCCESSFUL"
                }
                print("error=\(error!)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                let jsonData = responseString!.data(using: .utf8)!
                let decoder = JSONDecoder()

                do {
                    let response = try decoder.decode(AddDeviceResponse.self, from: jsonData)
                    self.deviceUuid = response.deviceUuid
                    self.activationToken = response.activationToken
                    
                    self.addDeviceCode.text = "Response Code: " + response.responseStatus.code
                    self.addDeviceMessage.text = "Response Message: " + response.responseStatus.message
                    self.addDeviceStatus.text = "Response Status: " + response.responseStatus.status
                    self.addDeviceDeviceUuid.text = "Device UUID: " + self.deviceUuid
                    self.addDeviceActivationToken.text = "Activation Token: " +  self.activationToken
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
        guard let saltBytes: [UInt8] = try? HaventecCommon.generateSalt() else { return }
        guard let hashedPinOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: pinCode) else { return }
        guard let hashedPin: String = hashedPinOptional else { return }
        
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
                    self.activateDeviceMessage.text = "Response Status: UNSUCCESSFUL"
                }
                print("error=\(error!)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                let jsonData = responseString!.data(using: .utf8)!
                let decoder = JSONDecoder()

                do {
                    let response = try decoder.decode(ActivateDeviceResponse.self, from: jsonData)
                    self.authKey = response.authKey
                    self.accessToken = response.accessToken
                    
                    self.activateDeviceCode.text = "Response Code: " + response.responseStatus.code
                    self.activateDeviceMessage.text = "Response Message: " + response.responseStatus.message
                    self.activateDeviceStatus.text = "Response Status: " + response.responseStatus.status
                    self.activateDeviceAuthKey.text = "Auth key: " + self.authKey
                    self.activateDeviceAccessTokenValue.text = "Token: " + self.accessToken.token
                    self.activateDeviceAccessTokenType.text = "Token Type: " + self.accessToken.type
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
