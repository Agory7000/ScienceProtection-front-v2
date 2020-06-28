//
//  MakeVideo.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 26.06.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit
import MobileCoreServices
import Photos
import CommonCrypto

class MakeVideo : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var userName : String?
    var videoData : Data?
    
    @IBOutlet weak var indicator: UIImageView!
    
    @IBAction func uploadTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Video", message: nil, preferredStyle: .actionSheet)
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
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallery() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    var imagePicker: UIImagePickerController!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeMovie as String) {
            let url = (info[UIImagePickerController.InfoKey.mediaURL] as! URL)
            let path = url.relativePath
            print(url)
            if imagePicker.sourceType == .camera {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                /*PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { saved, error in
                            if saved {
                                let fetchOptions = PHFetchOptions()
                                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

                                // After uploading we fetch the PHAsset for most recent video and then get its current location url

                                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                                    let newObj = avurlAsset as! AVURLAsset
                                    print(newObj.url)
                                    self.videoURL = newObj.url
                                    self.videoPath = self.videoURL!.relativePath
                                    print(self.videoPath!)
                                    // This is the URL we need now to access the video from gallery directly.
                                    })
                            }
                }*/
            }
            /*let bufferSize = 1024 * 1024
            do {
                let file = try FileHandle(forReadingFrom: url)
                defer {
                    file.closeFile()
                }
                var context = CC_MD5_CTX()
                CC_MD5_Init(&context)
                while autoreleasepool(invoking: {
                    let data = file.readData(ofLength: bufferSize)
                    if data.count > 0 {
                        data.withUnsafeBytes({_ = CC_MD5_Update(&context, $0.baseAddress, numericCast(data.count))})
                        return true
                    } else {
                        return false
                    }
            }) {}
                
                var digest: [UInt8] = Array(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                _ = CC_MD5_Final(&digest, &context)
                hashAndSend(data: Data(digest))
            } catch {
                print(error.localizedDescription)
            }
            */
            do {
                videoData = try Data(contentsOf: url as URL)
                print(videoData!)
            } catch {
                print(error.localizedDescription)
                return
            }
        } else {
            let ac = UIAlertController(title: "Error", message: "Wrong media type.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        imagePicker.dismiss(animated: true, completion: nil)
        indicator.image = #imageLiteral(resourceName: "Green")
    }
    
    @objc func video(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your video has been saved to your camera roll.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    /*
    func hashAndSend(data: Data) {
        let digest = SHA256.hash(data: data)
        let stringHash = digest.map{String(format: "%02hhx", $0)}.joined()
        let digest_2 = SHA256.hash(data: Data((stringHash + userName!).utf8))
        let stringHash_2 = digest_2.map{String(format: "%02hhx", $0)}.joined()
        print(stringHash_2)
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
                    let alert_1 = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
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
    }
    */
    @IBAction func sendTapped(_ sender: Any) {
        if (videoData == nil) {
            let alert_1 = UIAlertController(title: "Error", message: "No video data", preferredStyle: .alert)
            alert_1.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_1, animated: true, completion: nil)
            return
        }
        let digest = SHA512.hash(data: videoData!)
        let stringHash = digest.map{String(format: "%02hhx", $0)}.joined()
        let digest_2 = SHA512.hash(data: Data((stringHash + userName!).utf8))
        let stringHash_2 = digest_2.map{String(format: "%02hhx", $0)}.joined()
        print(stringHash_2)
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
                    let alert_1 = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
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
        /*
        let stream = InputStream(fileAtPath: path!)!
        stream.open()
        let bufferSize = 512
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var prevStringHash = ""
        while stream.hasBytesAvailable {
            var hasher = SHA512()
            let read = stream.read(buffer, maxLength: bufferSize)
            let bufferPointer = UnsafeRawBufferPointer(start: buffer, count: read)
            hasher.update(bufferPointer: bufferPointer)
            let digest = hasher.finalize()
            let stringHash = digest.map{String(format: "%02hhx", $0)}.joined()
            prevStringHash += stringHash
        }
        */
    }
    
    func correctUpload() {
        let alert_1 = UIAlertController(title: "Congratulations!", message: "Upload to server successful. You can check the status of your transaction in Check Hash section of main menu.", preferredStyle: .alert)
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
        indicator.image = #imageLiteral(resourceName: "Red") // image literal
    }
}
