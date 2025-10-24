import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var refreshTimer: Timer?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Création des controllers avec navigation
        let deviceVC = UINavigationController(rootViewController: DeviceViewController())
        deviceVC.tabBarItem = UITabBarItem(title: "iPhone", image: UIImage(named: "device_icon"), tag: 0)
        
        let cpuVC = UINavigationController(rootViewController: CPUViewController())
        cpuVC.tabBarItem = UITabBarItem(title: "CPU", image: UIImage(named: "cpu_icon"), tag: 1)
        
        let ramVC = UINavigationController(rootViewController: RAMViewController())
        ramVC.tabBarItem = UITabBarItem(title: "RAM", image: UIImage(named: "ram_icon"), tag: 2)
        
        let batteryVC = UINavigationController(rootViewController: BatteryViewController())
        batteryVC.tabBarItem = UITabBarItem(title: "Batterie", image: UIImage(named: "battery_icon"), tag: 3)
        
        let storageVC = UINavigationController(rootViewController: StorageViewController())
        storageVC.tabBarItem = UITabBarItem(title: "Stockage", image: UIImage(named: "storage_icon"), tag: 4)
        
        let otherVC = UINavigationController(rootViewController: OtherViewController())
        otherVC.tabBarItem = UITabBarItem(title: "Autre", image: UIImage(named: "other_icon"), tag: 5)
        
        let tab = UITabBarController()
        tab.viewControllers = [deviceVC, cpuVC, ramVC, batteryVC, storageVC, otherVC]
        
        // Style de la tab bar
        tab.tabBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        tab.tabBar.barTintColor = UIColor.white
        tab.tabBar.isTranslucent = false
        
        window?.rootViewController = tab
        window?.makeKeyAndVisible()
        
        // Timer de refresh
        refreshTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                            target: self,
                                            selector: #selector(tick),
                                            userInfo: nil,
                                            repeats: true)
        
        return true
    }
    
    @objc func tick() {
        NotificationCenter.default.post(name: .systemRefreshTick, object: nil)
    }
}

extension Notification.Name {
    static let systemRefreshTick = Notification.Name("systemRefreshTick")
}
