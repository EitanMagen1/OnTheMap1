//
//  LogInViewController.swift
//  On_The_Map_EM
//
//  Created by Lauren Efron on 04/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//Working version

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
class LogInViewController: UIViewController ,FBSDKLoginButtonDelegate {
    
    var appDelegate : AppDelegate!
    static let sheredInstance = LogInViewController()
    
    var session: NSURLSession!
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logInText: UILabel!
    @IBOutlet weak var facebookauth: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // @IBAction func FBbuttonView(sender: AnyObject) {
    //  }
    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
          let loginManager = FBSDKLoginManager()
            FBSDKLoginManager.logOut(loginManager)()
        }
        else
        {
            fbLoginView.delegate = self
            fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
            FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
            
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        if ((error) != nil)
        {
            self.presentError(error!.description)
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                logInText.text = "LogIn to Udacity With FB"
                var userInfo = [String:String]()
                userInfo[UdacityConstants.JSONKeys.access_token] = FBSDKAccessToken.currentAccessToken().tokenString
                let jsonBody = [UdacityConstants.JSONKeys.facebook_mobile: userInfo] //build the json body a array of dictianary
                
                UdacityModel.sheredInstance.requestForPOSTSession(jsonBody , completionHandler: {(success, errorType) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showActivityIndicator()//flips the condition of the indictor , stops the animation once logged in
                            self.performSegueWithIdentifier("NavigationSague", sender: self)
                        })
                    } else if errorType != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showActivityIndicator()//flips the condition of the indictor , stops the animation once logged in
                            self.presentError(errorType!)
                        })
                        
                    }
                    
                })
                
            }
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    @IBAction func signUpButtonTouchUp(sender: UIButton) {
        if let requestUrl = NSURL(string: "https://www.udacity.com/account/auth#!/signin") {
            UIApplication.sharedApplication().openURL(requestUrl)
        } else {
            presentError("Error opening url: " + "https://www.udacity.com/account/auth#!/signin")
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        emailTextField.text = ""
        passwordTextField.text = ""
        activityIndicator.hidden = true
    }
    
    @IBAction func logInButton(sender: UIButton) {
        logInText.text = "LogIn to Udacity"
        var userInfo = [String:String]()
        userInfo[UdacityConstants.JSONKeys.Username] = emailTextField.text
        userInfo[UdacityConstants.JSONKeys.Password] = passwordTextField.text
        let jsonBody = [UdacityConstants.JSONKeys.Udacity: userInfo] //build the json body a array of dictianary
        
        if emailTextField.text!.isEmpty {
            logInText.text = "Username Empty."
            return
        } else if passwordTextField.text!.isEmpty {
            logInText.text = "Password Empty."
            return
        }
        showActivityIndicator()//starts the animation of the login indicator until we loged in!
        
        UdacityModel.sheredInstance.requestForPOSTSession(jsonBody , completionHandler: {(success, errorType) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.passwordTextField.text = ""
                    self.showActivityIndicator()//flips the condition of the indictor , stops the animation once logged in
                    self.performSegueWithIdentifier("NavigationSague", sender: self)
                })
            } else if errorType != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showActivityIndicator()//flips the condition of the indictor , stops the animation once logged in
                    self.presentError(errorType!)
                })
                
            }
            
        })
    }
    
    func showActivityIndicator() {
        if activityIndicator.hidden {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
            activityIndicator.hidesWhenStopped = true
            
            
        }
    }
    
    override func presentError(alertString: String){
        /* Set transaction for when shake animation ceases */
        showActivityIndicator()
        CATransaction.begin()
        let ac = UIAlertController(title: "Error In Request", message: alertString, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        CATransaction.setCompletionBlock { () -> Void in
            self.presentViewController(ac, animated: true, completion: nil)
        }
        
        /* Configure shake animation */
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.autoreverses = true
        let fromPoint: CGPoint = CGPointMake(self.view.center.x - 5, self.emailTextField.center.y)
        let fromValue: NSValue = NSValue(CGPoint: fromPoint)
        let toPoint: CGPoint = CGPointMake(self.view.center.x + 5,self.emailTextField.center.y )
        let toValue: NSValue = NSValue(CGPoint: toPoint)
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        /* Stop animating activity indicator */
        self.activityIndicator.stopAnimating()
        
        /* Animate view layer */
        //  self.view.layer.addAnimation(animation, forKey: "position")
        self.emailTextField.layer.addAnimation(animation, forKey: "position")
        
        /* Commit transaction */
        CATransaction.commit()
    } //Error handeler
    
    
}

