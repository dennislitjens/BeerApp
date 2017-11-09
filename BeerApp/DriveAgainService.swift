//
//  DriveAgainNotificationService.swift
//  BeerApp
//
//  Created by Dennis Litjens on 6/11/17.
//  Copyright © 2017 Dennis Litjens. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

class DriveAgainService {
    
    let viewController: UIViewController
    var weight: Double
    var bodyfluid: Double
    var beerUnits: Double
    var firstBeerDateTime: Date
    
    init(viewController: UIViewController, weight: Double, bodyfluid: Double, beerUnits: Double, firstBeerDateTime: Date){
        self.viewController = viewController
        self.weight = weight
        self.bodyfluid = bodyfluid
        self.beerUnits = beerUnits
        self.firstBeerDateTime = firstBeerDateTime
    }
    
    private func notificationsNotAllowedAlert(){
        let alertNotificationNotAllowed = UIAlertController(title: "Oops!", message: "You've not granted permission for notifications, go to settings.", preferredStyle: .alert)
        alertNotificationNotAllowed.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewController.present(alertNotificationNotAllowed, animated: true, completion: nil)
    }
    
    func calculateBloodAlcoholPercentage() -> Double{
        let hoursSinceFirstBeer = calculateHoursSinceLastbeer(firstBeerDate: self.firstBeerDateTime)
        let bloodAlcoholPercentage = (beerUnits*10)/(weight*bodyfluid) - (hoursSinceFirstBeer-0.5)*(weight*0.002)
        return bloodAlcoholPercentage
    }
    
    func calculateSecondsToDrivingAgain() -> Double{
        var hoursTillDrivingAgain = 0.5/(0.002*self.weight) * 3600
        hoursTillDrivingAgain = hoursTillDrivingAgain / 3000// for testing notification
        return hoursTillDrivingAgain
    }
    
    private func calculateHoursSinceLastbeer(firstBeerDate: Date) -> Double{
        let secondsSinceFirstBeer = firstBeerDate.timeIntervalSinceNow
        let hoursSinceFirstBeer = secondsSinceFirstBeer / 3600
        return hoursSinceFirstBeer
    }
    
    func scheduleNotificationForDrivingAgain(timeInterval: Double){
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.notificationsNotAllowedAlert()
            }else{
                self.createNotificationRequest(notificationCenter: notificationCenter, timeInterval: timeInterval)
            }
        }
    }
    
    public func resetNotification(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["UYLocalBeerNotification"])
    }
    
    private func createNotificationRequest(notificationCenter: UNUserNotificationCenter, timeInterval: Double){
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
        let identifier = "UYLocalBeerNotification"
        
        content.title = "Hurray!"
        content.body = "You can drive again!"
        content.sound = UNNotificationSound.default()
        content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
}
