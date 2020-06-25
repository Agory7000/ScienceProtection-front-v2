//
//  ChooseOperation.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 24.06.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import UIKit

class ChooseOperation: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var userName : String?
    
    @IBOutlet weak var UserName: UITextField!
    @IBAction func UserNameEdited(_ sender: Any) {
        userName = UserName.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        UserName.resignFirstResponder()
        return true
    }
    
    @IBAction func UploadHashTapped(_ sender: Any) {
        if userName == nil {
            let alert = UIAlertController(title: "Please, enter your name first", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "UploadHash", sender: self)
        }
    }
    
    @IBAction func CheckHashTapped(_ sender: Any) {
        if userName == nil {
            let alert = UIAlertController(title: "Please, enter your name first", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "CheckHash", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserName.delegate = self
        userName = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UploadHash" {
            guard let destination = segue.destination as? StartingScene else {return}
            destination.userName = userName
        } else if segue.identifier == "CheckHash" {
            guard let destination = segue.destination as? CheckHash else {return}
            destination.userName = userName
        } else {
            return
        }
    }
}
