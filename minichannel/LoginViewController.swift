
//
//  LoginViewController.swift
//  minichannel
//
//  Created by nagasaka.shogo on 1/18/17.
//  Copyright © 2017 jp.ne.donuts. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet var signInButton: GIDSignInButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        GIDSignIn.sharedInstance().uiDelegate = self
        try? Auth.auth().signOut()
        // ユーザーデータ確認
        if let user = Auth.auth().currentUser, let name = user.displayName, let email = user.email {
            print("\(name) \(email)")
        } else {
            print("no current user")
        }
        // ここにログインした後の処理を書く
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
