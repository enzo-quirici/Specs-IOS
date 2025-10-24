import UIKit

class CPUViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        title = "CPU"
        
        setupScrollView()
        displayCPUInfoCards()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayCPUInfoCards),
                                               name: .systemRefreshTick,
                                               object: nil)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        }
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
            ])
    }
    
    @objc private func displayCPUInfoCards() {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        let deviceCode = CPUViewController.deviceIdentifier()
        let cpuName = mapDeviceToCPU(deviceCode)
        let architecture = MemoryLayout<Int>.size == 8 ? "64 bit" : "32 bit"
        let cores = "\(ProcessInfo.processInfo.processorCount)"
        
        let cards: [(String, String, UIColor)] = [
            ("CPU", cpuName, UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)),
            ("Architecture", architecture, UIColor.darkGray),
            ("Cores", cores, UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1))
        ]
        
        for (title, value, color) in cards {
            stackView.addArrangedSubview(createCard(title: title, value: value, color: color))
        }
    }
    
    private func createCard(title: String, value: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkText
        titleLabel.text = title
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 24)
        valueLabel.textColor = color
        valueLabel.text = value
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
            ])
        
        return card
    }
    
    // MARK: - Identifiant interne
    static func deviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }
    
    func mapDeviceToCPU(_ code: String) -> String {
        switch code {
        // --- iPhone ---
        case "iPhone4,1": return "Apple A5"
        case "iPhone5,1", "iPhone5,2": return "Apple A6"
        case "iPhone5,3", "iPhone5,4": return "Apple A6"
        case "iPhone6,1", "iPhone6,2": return "Apple A7"
        case "iPhone7,2": return "Apple A8"
        case "iPhone7,1": return "Apple A8"
        case "iPhone8,1": return "Apple A9"
        case "iPhone8,2": return "Apple A9"
        case "iPhone8,4": return "Apple A9"
        case "iPhone9,1", "iPhone9,3": return ""
        case "iPhone9,2", "iPhone9,4": return "Apple A10 Fusion"
        case "iPhone10,1", "iPhone10,4": return "Apple A11 Bionic"
        case "iPhone10,2", "iPhone10,5": return "Apple A11 Bionic"
        case "iPhone10,3", "iPhone10,6": return "Apple A11 Bionic"
        case "iPhone11,2": return "Apple A12 Bionic"
        case "iPhone11,4", "iPhone11,6": return "Apple A12 Bionic"
        case "iPhone11,8": return "Apple A12 Bionic"
        case "iPhone12,1": return "Apple A13 Bionic"
        case "iPhone12,3": return "Apple A13 Bionic"
        case "iPhone12,5": return "Apple A13 Bionic"
        case "iPhone12,8": return "Apple A13 Bionic"
        case "iPhone13,1": return "Apple A14 Bionic"
        case "iPhone13,2": return "Apple A14 Bionic"
        case "iPhone13,3": return "Apple A14 Bionic"
        case "iPhone13,4": return "Apple A14 Bionic"
        case "iPhone14,4": return "Apple A15 Bionic"
        case "iPhone14,5": return "Apple A15 Bionic"
        case "iPhone14,2": return "Apple A15 Bionic"
        case "iPhone14,3": return "Apple A15 Bionic"
        case "iPhone14,6": return "Apple A15 Bionic"
        case "iPhone15,2": return "Apple A16 Bionic"
        case "iPhone15,3": return "Apple A16 Bionic"
        case "iPhone15,4": return "Apple A15 Bionic"
        case "iPhone15,5": return "Apple A15 Bionic"
        case "iPhone16,1", "iPhone16,2": return "Apple A17 Pro)"
        case "iPhone17,1", "iPhone17,2": return "Apple A18 Pro"
        case "iPhone17,3", "iPhone17,4": return "Apple A18"
            
        // --- iPad ---
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "Apple A5"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "Apple A5X"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "Apple A6X"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "Apple A7"
        case "iPad5,3", "iPad5,4": return "Apple A8X"
        case "iPad6,11", "iPad6,12": return "Apple A9"
        case "iPad7,5", "iPad7,6": return "Apple A10 Fusion"
        case "iPad7,11", "iPad7,12": return "Apple A10 Fusion"
        case "iPad11,6", "iPad11,7": return "Apple A12 Bionic"
        case "iPad12,1", "iPad12,2": return "Apple A13 Bionic"
        case "iPad13,18", "iPad13,19": return "Apple A14 Bionic"
            
        // --- iPad mini ---
        case "iPad2,5", "iPad2,6", "iPad2,7": return "Apple A5"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "Apple A7"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "Apple A7"
        case "iPad5,1", "iPad5,2": return "Apple A8"
        case "iPad11,1", "iPad11,2": return "Apple A12 Bionic"
        case "iPad14,1", "iPad14,2": return "Apple A15 Bionic"
            
        // --- iPad Pro ---
        case "iPad6,7", "iPad6,8": return "Apple A9X"
        case "iPad6,3", "iPad6,4": return "Apple A9X"
        case "iPad7,1", "iPad7,2": return "Apple A10X Fusion"
        case "iPad7,3", "iPad7,4": return "Apple A10X Fusion"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "Apple A12X Bionic"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "Apple A12X Bionic"
        case "iPad8,9", "iPad8,10": return "Apple A12Z Bionic"
        case "iPad8,11", "iPad8,12": return "Apple A12Z Bionic"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "Apple M1"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "Apple M1"
        case "iPad14,3", "iPad14,4": return "Apple M2"
        case "iPad14,5", "iPad14,6": return "Apple M2"
        case "iPad16,3", "iPad16,4": return "Apple M4"
        case "iPad16,5", "iPad16,6": return "Apple M4"
            
        // --- iPod touch ---
        case "iPod5,1": return "Apple A5"
        case "iPod7,1": return "Apple A8"
        case "iPod9,1": return "Apple A10 Fusion"
            
        default: return "Unkonown CPU / Unlisted CPU"
        }
    }
}
