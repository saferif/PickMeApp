//
//  LoginViewController.swift
//  Feed Me
//
//  Created by Evgeney on 12/14/15.
//  Copyright © 2015 Ron Kliffer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  @IBOutlet weak var usernameText: UITextField!
  @IBOutlet weak var carNumberText: UITextField!
  @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  
    // MARK: - Navigation
  
  /*override func shouldPerformSegueWithIdentifier(segue_identifier: String, sender: AnyObject?) -> Bool {
    if (segue_identifier == "LoginSegue") {
      if (usernameText.text! == "aaa") {
        return true
      }
    }
    return false
  }*/
  
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if segue.identifier == "LoginSegue" {
        if let mapVC = segue.destinationViewController as? MapViewController {
          do {
            print(usernameText.text!)
            print(carNumberText.text!)
            print(NSJSONSerialization.isValidJSONObject(["username": usernameText.text!, "carNumber": carNumberText.text!]))
          try mapVC.userInfo = NSJSONSerialization.dataWithJSONObject(["username": usernameText.text!, "carNumber": carNumberText.text!], options: [])
          } catch {
            print("Error with JSON in loginViewController")
          }
        }
      }
    }


}
