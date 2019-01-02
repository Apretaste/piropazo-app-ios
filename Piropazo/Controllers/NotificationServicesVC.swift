//
//  NotificationServicesVC.swift
//  Apretaste
//
//  Created by reinaldo requena on 06/12/2018.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class NotificationServicesVC: ServicesVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if TEMPManager.shared.metaNotification.notificationsCount >= 0 {
            
            self.tabBarItem.badgeValue = nil
            
        }
        
        self.reloadServices()
        
      
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
