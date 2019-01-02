
//
//  TabBarMenuVC.swift
//  declareItSupport
//
//  Created by IOS Developer on 4/3/18.
//  Copyright © 2018 Technifiser. All rights reserved.
//

import UIKit

class TabBarMenuVC: UITabBarController {
    
    //MARK: - vars
    var urlHtml:URL!
    
    var observers = [NSKeyValueObservation]()

    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabs()
        self.setupView()
        self.observeModel()
        
    }
    
    
    //MARK: - setups
    
    private func setupTabs(){
        
        
        
        // set style //
        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.lightGray
        } else {
            // Fallback on earlier versions
        }
        self.tabBar.tintColor = UIColor.white
        
        //MARK: configure root view controllers //
        
   
        
        
        let servicesVC = NotificationServicesVC(command: "PIROPAZO")
        let navigationServices = PrincipalNavigation.init(rootViewController: servicesVC)
        navigationServices.isNavigationBarHidden = true
        
        let homeBarItem = UITabBarItem(title: "Citas", image: UIImage.init(named: "genteBarMenu")!, tag: 0)
        servicesVC.tabBarItem = homeBarItem
        
        
        let notificationVC = NotificationServicesVC(command: "PIROPAZO NOTIFICACIONES")
        let notificationBarItem =  UITabBarItem(title: "Alertas", image: UIImage.init(named: "alertasBarMenu")!, tag: 0)
        notificationVC.tabBarItem = notificationBarItem
        let navigationNotificationVC = PrincipalNavigation(rootViewController: notificationVC)
        navigationNotificationVC.isNavigationBarHidden = true
        notificationVC.title = "Notificaciones"
        
        let optionsVC = UIStoryboard(name: "options", bundle: nil).instantiateInitialViewController()!
        let optionsBarItem =   UITabBarItem(title: "Menu", image: UIImage.init(named: "opcionesBarMenu")!, tag: 0)
        optionsVC.tabBarItem = optionsBarItem
        
        let coupleVC = NotificationServicesVC(command: "PIROPAZO PAREJAS")
        let coupleBarItem =  UITabBarItem(title: "Parejas", image: UIImage.init(named: "pareja")!, tag: 0)
        coupleVC.tabBarItem = coupleBarItem
        let navigationCoupleVC = PrincipalNavigation(rootViewController: coupleVC)
        navigationCoupleVC.isNavigationBarHidden = true
        
        self.viewControllers = [navigationServices,navigationCoupleVC,navigationNotificationVC,optionsVC]
        
        //MARK: set root tab
        
        self.selectedIndex = 0
        
        
    }
    
    private func setupView(){
        
        //MARK: set styles //
        
        self.tabBar.tintColor = UIColor.white
        self.tabBar.barTintColor = UIColor.greenApp
        self.tabBar.isTranslucent = false

        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.darkGray
        }
        // set navigation bar style //
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    func observeModel() {
        
        self.observers = [
            
            TEMPManager.shared.metaNotification.observe(\.notificationsCount, options: [.initial]) { (model, change) in
                
                let badge: String? = TEMPManager.shared.metaNotification.notificationsCount == 0 ? nil :  String(TEMPManager.shared.metaNotification.notificationsCount)
               
                self.tabBar.items![2].badgeValue = badge
                
            },
            
        
            TEMPManager.shared.metaNotification.observe(\.notificationTapped, options: [.initial]) { (model, change) in
                
                if model.notificationTapped{
                    
                    self.selectedIndex = 2

                }
                
            }]
        
        
    }
    
    //MARK: - override tabBar methods
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        tabBar.tintColor = UIColor.white
        
    }
    
    
}
