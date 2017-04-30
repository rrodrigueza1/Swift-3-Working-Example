//
//  CalendarController.swift
//  Assignment1
//
//  Created by Renzelle Frank V Rodrigueza on 2017-02-09.
//  Copyright © 2017 com.renzellerodrigueza. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation
class CalendarController: UIViewController, UNUserNotificationCenterDelegate {

 
    @IBOutlet weak var calendarDescription: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var calendarPrompt: UILabel!
    @IBOutlet weak var alarmNotifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func checkUserAndPass()
    {
        
        let arrayOfTabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray
        let tabBarItem1 = arrayOfTabBarItems?[1] as? UITabBarItem
        let tabBarItem2 = arrayOfTabBarItems?[2] as? UITabBarItem
        let defaults = UserDefaults.standard
        let login = defaults.string(forKey: loginKey)
        let password =  defaults.string(forKey: passwordKey)
        let role = defaults.string(forKey: userTypeKey) ?? "User"
        let alertController = UIAlertController (title: "Please enter your credentials", message: "Please provide a username, password and role to continue", preferredStyle: .alert)

        if (login ?? "").isEmpty || (password ?? "").isEmpty || (role).isEmpty
        {
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default){ (_) -> Void in

                let application = UIApplication.shared
                let url = URL(string: UIApplicationOpenSettingsURLString)! as URL
                if application.canOpenURL(url) {
                    application.open(url, options: ["":""], completionHandler: nil)
                }
            
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default){ (_) -> Void in
                self.datePicker.isHidden = true
                self.calendarDescription.isHidden = true
                self.calendarPrompt.isHidden = true
                self.alarmNotifyButton.isHidden = true
                
                tabBarItem1?.isEnabled = false
                tabBarItem2?.isEnabled = false
                
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            if role == "User"
            {
                tabBarItem1?.isEnabled = true
                tabBarItem2?.isEnabled = false
            }
            else if role == "Premium User"
            {
                tabBarItem1?.isEnabled = true
                tabBarItem2?.isEnabled = true
            }
            self.datePicker.isHidden = false
            self.calendarDescription.isHidden = false
            self.calendarPrompt.isHidden = false
            self.alarmNotifyButton.isHidden = false
        }
    
    
    }

    override func viewDidAppear(_ animated: Bool) {
         checkUserAndPass()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createNotification(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted
            {
               
                
            } else
            {
                let utterance = AVSpeechUtterance(string: "Permission Denied")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
        }
        let content = UNMutableNotificationContent()
        content.title = "Notification for today's event"
        content.body = "The event you sent today \(calendarDescription.text!) has occured."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        
        let calendar = datePicker.calendar
        
        dateComponents.year = calendar?.component(.year, from: datePicker.date)
        dateComponents.hour = calendar?.component(.hour, from: datePicker.date)
        dateComponents.month = calendar?.component(.month, from: datePicker.date)
        dateComponents.day = calendar?.component(.day, from: datePicker.date)
        dateComponents.minute = calendar?.component(.minute, from: datePicker.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
        
        center.add(request)
        let utterance = AVSpeechUtterance(string: "Successfully Created Notification")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        

    }
    
    @IBAction func buttonOpenSettingsOnClick(_ sender: UIButton) {
        let application = UIApplication.shared
        let url = URL(string: UIApplicationOpenSettingsURLString)! as URL
        if application.canOpenURL(url) {
            application.open(url, options: ["":""], completionHandler: nil)
        }
    
    }


    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                let message = "You unlock your phone!"
                let controller = UIAlertController(title: "Unlock the phone", message:message, preferredStyle: .actionSheet)
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                controller.addAction(cancelButton)
                
                present(controller, animated: true, completion: nil)
                
            case "show":
                // the user tapped our "show more info…" button
                let message = "You click the show more info in the notification!"
                let controller = UIAlertController(title: "Click the button the phone", message:message, preferredStyle: .actionSheet)
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                controller.addAction(cancelButton)
                
                present(controller, animated: true, completion: nil)
                break
                
            default:
                break
            }
        }
    
        completionHandler()
    }
    
    @IBAction func didEndOnEditing(_ sender: UITextField) {
        sender.resignFirstResponder()

    }
    
    @IBAction func onClick(_ sender: UITapGestureRecognizer) {
        calendarDescription.resignFirstResponder()
    }
}
