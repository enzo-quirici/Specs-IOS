import UIKit

class BatteryViewController: UIViewController {
    
    private let batteryCard = UIView()
    private let levelBarBackground = UIView()
    private let levelBar = UIView()
    private let stateLabel = UILabel()
    private let uptimeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        title = "Batterie"
        
        setupBatteryCard()
        setupInfoLabels()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBattery),
                                               name: .systemRefreshTick,
                                               object: nil)
        updateBattery()
    }
    
    private func setupBatteryCard() {
        batteryCard.backgroundColor = .white
        batteryCard.layer.cornerRadius = 16
        batteryCard.layer.shadowColor = UIColor.black.cgColor
        batteryCard.layer.shadowOpacity = 0.1
        batteryCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        batteryCard.layer.shadowRadius = 8
        batteryCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(batteryCard)
        
        levelBarBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        levelBarBackground.layer.cornerRadius = 12
        levelBarBackground.translatesAutoresizingMaskIntoConstraints = false
        batteryCard.addSubview(levelBarBackground)
        
        levelBar.layer.cornerRadius = 12
        levelBar.translatesAutoresizingMaskIntoConstraints = false
        levelBarBackground.addSubview(levelBar)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                batteryCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                batteryCard.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                batteryCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                batteryCard.heightAnchor.constraint(equalToConstant: 120)
                ])
        } else {
            NSLayoutConstraint.activate([
                batteryCard.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 32),
                batteryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                batteryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                batteryCard.heightAnchor.constraint(equalToConstant: 120)
                ])
        }
        
        NSLayoutConstraint.activate([
            levelBarBackground.leadingAnchor.constraint(equalTo: batteryCard.leadingAnchor, constant: 16),
            levelBarBackground.trailingAnchor.constraint(equalTo: batteryCard.trailingAnchor, constant: -16),
            levelBarBackground.centerYAnchor.constraint(equalTo: batteryCard.centerYAnchor),
            levelBarBackground.heightAnchor.constraint(equalToConstant: 30),
            
            levelBar.leadingAnchor.constraint(equalTo: levelBarBackground.leadingAnchor),
            levelBar.topAnchor.constraint(equalTo: levelBarBackground.topAnchor),
            levelBar.bottomAnchor.constraint(equalTo: levelBarBackground.bottomAnchor),
            levelBar.widthAnchor.constraint(equalToConstant: 0)
            ])
    }
    
    private func setupInfoLabels() {
        stateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        stateLabel.textAlignment = .center
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        uptimeLabel.font = UIFont.systemFont(ofSize: 16)
        uptimeLabel.textAlignment = .center
        uptimeLabel.textColor = .darkGray
        uptimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stateLabel)
        view.addSubview(uptimeLabel)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                stateLabel.topAnchor.constraint(equalTo: batteryCard.bottomAnchor, constant: 24),
                stateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                stateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                
                uptimeLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 12),
                uptimeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                uptimeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                ])
        } else {
            NSLayoutConstraint.activate([
                stateLabel.topAnchor.constraint(equalTo: batteryCard.bottomAnchor, constant: 24),
                stateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                stateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                uptimeLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 12),
                uptimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                uptimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
        }
    }
    
    @objc private func updateBattery() {
        let info = SystemUtils.batteryStateAndLevel()
        let level = info.level >= 0 ? CGFloat(info.level) : 0
        let stateStr: String
        switch info.state {
        case .charging: stateStr = "In Charge"
        case .full: stateStr = "Full"
        case .unplugged: stateStr = "Unplugged"
        default: stateStr = "Unknown"
        }
        stateLabel.text = "State : \(stateStr)"
        
        // Dégradé couleur niveau
        let color: UIColor
        if level > 0.5 {
            color = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1) // vert
        } else if level > 0.2 {
            color = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1) // orange
        } else {
            color = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1) // rouge
        }
        levelBar.backgroundColor = color
        
        // Animer largeur barre
        let maxWidth = levelBarBackground.frame.width
        let newWidth = maxWidth * level
        UIView.animate(withDuration: 0.3) {
            self.levelBar.frame.size.width = newWidth
        }
        
        // Uptime
        let uptime = ProcessInfo.processInfo.systemUptime
        let hours = Int(uptime / 3600)
        let minutes = Int((uptime.truncatingRemainder(dividingBy: 3600)) / 60)
        uptimeLabel.text = "Aproximate Usage Time : \(hours)h \(minutes)m"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
