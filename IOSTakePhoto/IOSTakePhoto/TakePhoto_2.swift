//
//  TakePhoto_2.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 25.06.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import UIKit
import CryptoKit

class TakePhoto_2 : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var userName : String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func uploadPhotoTapped(_ sender: Any) {
        self.openGallery()
    }
    
    func openGallery() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    var imagePicker: UIImagePickerController!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
    }
    
    @IBAction func checkTapped(_ sender: Any) {
        if imageView.image == nil {
            let alert_1 = UIAlertController(title: "Error", message: "Select photo first", preferredStyle: .alert)
            alert_1.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_1, animated: true, completion: nil)
        } else if imageView.image!.pngData() != nil {
            let digest = SHA512.hash(data: imageView.image!.pngData()!)
            let stringHash = digest.map{String(format: "%02hhx", $0)}.joined()
            let digest_2 = SHA512.hash(data: Data((stringHash + userName!).utf8))
            let stringHash_2 = digest_2.map{String(format: "%02hhx", $0)}.joined()
            let url = URL(string: "http://54.149.14.169:8000/checkHash")!
            guard let uploadData = try? JSONEncoder().encode(["hash" : stringHash_2]) else {
                let alert_1 = UIAlertController(title: "Error", message: "JSON encoding failed", preferredStyle: .alert)
                alert_1.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert_1, animated: true, completion: nil)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) {data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        let alert_1 = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert_1, animated: true, completion: nil)
                    }
                    return
                }
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        print(200)
                        if let data = data, let dataString = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.hashFound(datastr : dataString)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.dataError()
                            }
                            return
                        }
                    } else if response.statusCode == 404 {
                        print(404)
                        DispatchQueue.main.async {
                            self.hashNotFound()
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            self.invalidCode()
                        }
                        return
                    }
                    if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print("recieved data: \(dataString)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.invalidResponse()
                    }
                    return
                }
            }
            task.resume()
        } else {
            let alert_1 = UIAlertController(title: "Error", message: "Image is not presentable in PNG format", preferredStyle: .alert)
            alert_1.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_1, animated: true, completion: nil)
        }
    }
    
    func hashFound(datastr : String) {
        let data = Data(datastr.utf8)
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let res = json["result"] as? String, let timestamp = json["timestamp"] as? String {
                    let alert_1 = UIAlertController(title: "Congratulations!", message: "Hash of your media file has been found. Result: \(res). Timestamp: \(timestamp). Date and time: \(NSDate(timeIntervalSince1970: Double(timestamp)!))", preferredStyle: .alert)
                    alert_1.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert_1, animated: true, completion: nil)
                } else {
                    let alert_1 = UIAlertController(title: "Error", message: "Invalid response from server", preferredStyle: .alert)
                    alert_1.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert_1, animated: true, completion: nil)
                }
            } else {
                let alert_1 = UIAlertController(title: "Error", message: "Failed to transform response data into a dictionary", preferredStyle: .alert)
                alert_1.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert_1, animated: true, completion: nil)
            }
        } catch let error as NSError {
            let alert_1 = UIAlertController(title: "Error", message: "Failed to load: \(error.localizedDescription)", preferredStyle: .alert)
            alert_1.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_1, animated: true, completion: nil)
        }
    }
    
    func hashNotFound() {
        let alert_1 = UIAlertController(title: "Error", message: "This hash does not exist in the base", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func invalidCode() {
        let alert_1 = UIAlertController(title: "Error", message: "Invalid code of response", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func invalidResponse() {
        let alert_1 = UIAlertController(title: "Error", message: "Invalid response", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func dataError() {
        let alert_1 = UIAlertController(title: "Error", message: "Invalid data revieved", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
}
