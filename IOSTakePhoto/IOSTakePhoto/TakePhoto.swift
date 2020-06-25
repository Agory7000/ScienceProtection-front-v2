//
//  TakePhoto.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 24.06.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import UIKit
import CryptoKit

class TakePhoto: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var userName : String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func takePhoto(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallery() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if imageView.image != nil {
            UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let alert = UIAlertController(title: "Save error", message: "Upload photo first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
    
    var imagePicker: UIImagePickerController!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func HashAndSend(_ sender: Any) {
        if imageView.image == nil {
            let alert_1 = UIAlertController(title: "Error", message: "Select photo first", preferredStyle: .alert)
            alert_1.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_1, animated: true, completion: nil)
        } else if imageView.image!.pngData() != nil {
            let digest = SHA512.hash(data: imageView.image!.pngData()!)
            let stringHash = digest.map{String(format: "%02hhx", $0)}.joined()
            let digest_2 = SHA512.hash(data: Data((stringHash + userName!).utf8))
            let stringHash_2 = digest_2.map{String(format: "%02hhx", $0)}.joined()
            let url = URL(string: "http://54.149.14.169:8000/registerHash")!
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
                        DispatchQueue.main.async {
                            self.correctUpload()
                        }
                    } else if response.statusCode == 403 {
                        DispatchQueue.main.async {
                            self.hashExists()
                        }
                        return
                    } else if response.statusCode == 400 {
                        DispatchQueue.main.async {
                            self.invalidRequest()
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            self.invalidCode()
                        }
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        self.invalidResponse()
                    }
                    return
                }
                if let mimeType = response!.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print("got data: \(dataString)")
                    }
                }
            task.resume()
        } else {
            let alert_1 = UIAlertController(title: "Error", message: "Image is not presentable in PNG format", preferredStyle: .alert)
            alert_1.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_1, animated: true, completion: nil)
        }
    }
    
    func correctUpload() {
        let alert_1 = UIAlertController(title: "Congratulations!", message: "Upload to server successful", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func hashExists() {
        let alert_1 = UIAlertController(title: "Error", message: "Hash code already exists", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func invalidRequest() {
        let alert_1 = UIAlertController(title: "Error", message: "Invalid request", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func invalidCode() {
        let alert_1 = UIAlertController(title: "Error", message: "Unknown status code", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    func invalidResponse() {
        let alert_1 = UIAlertController(title: "Error", message: "Invalid response from a server", preferredStyle: .alert)
        alert_1.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert_1, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
