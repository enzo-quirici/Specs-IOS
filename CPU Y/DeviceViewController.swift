import UIKit

class DeviceViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        setupScrollView()
        displayDeviceCards()
        
        title = "Device"
        
        // Refresh automatique
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayDeviceCards),
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
    
    @objc private func displayDeviceCards() {
        // Vider les cartes existantes
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        let identifier = DeviceViewController.deviceIdentifier()
        let modelName = DeviceViewController.mapDeviceModel(identifier)
        let iosVersion = UIDevice.current.systemVersion
        
        // --- RAM totale ---
        var ramText = "Unknown"
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        if physicalMemory > 0 {
            let ramGB = Double(physicalMemory) / 1024 / 1024 / 1024
            if ramGB < 1 {
                ramText = "512 MB"
            } else {
                ramText = String(format: "%.0f Go", ramGB)
            }
        }
        
        // --- Stockage total ---
        var storageText = "Unknown"
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
            let total = attrs[.systemSize] as? NSNumber {
            let totalGB = Double(total.uint64Value) / 1024 / 1024 / 1024
            storageText = String(format: "%.1f Go", totalGB)
        }
        
        // Cartes à afficher
        let cards: [(String, String, UIColor)] = [
            ("Model", modelName, UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)),
            ("Indentifier", identifier, UIColor.darkGray),
            ("IOS", iosVersion, UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)),
            ("RAM", ramText, UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)),
            ("Total Storage", storageText, UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1))
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
    
    // MARK: - Nom du modèle
    static func mapDeviceModel(_ id: String) -> String {
        switch id {
        // --- iPhone ---
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE 1"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE 2"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,6": return "iPhone SE 3"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 15 Pro"
        case "iPhone15,3": return "iPhone 15 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 16"
        case "iPhone16,2": return "iPhone 16 Pro"
        case "iPhone16,3": return "iPhone 16 Plus"
        case "iPhone16,4": return "iPhone 16 Pro Max"
            
        // --- iPad ---
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad (3e gén.)"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4e gén.)"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad11,3", "iPad11,4": return "iPad Air (3e gén.)"
        case "iPad13,1", "iPad13,2": return "iPad Air (4e gén.)"
        case "iPad13,16", "iPad13,17": return "iPad Air (5e gén.)"
        case "iPad14,8", "iPad14,9": return "iPad Air M2 (6e gén.)"
            
        // --- iPad mini ---
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
        case "iPad5,1", "iPad5,2": return "iPad mini 4"
        case "iPad11,1", "iPad11,2": return "iPad mini (5e gén.)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6e gén.)"
            
        // --- iPad Pro ---
        case "iPad6,3", "iPad6,4": return "iPad Pro 9,7″"
        case "iPad6,7", "iPad6,8": return "iPad Pro 12,9″ (1re gén.)"
        case "iPad7,1", "iPad7,2": return "iPad Pro 12,9″ (2e gén.)"
        case "iPad7,3", "iPad7,4": return "iPad Pro 10,5″"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro 11″ (1re gén.)"
        case "iPad8,9", "iPad8,10": return "iPad Pro 11″ (2e gén.)"
        case "iPad8,11", "iPad8,12": return "iPad Pro 12,9″ (4e gén.)"
        case "iPad13,8", "iPad13,9": return "iPad Pro 12,9″ M2"
        case "iPad14,3", "iPad14,4": return "iPad Pro 11″ M4"
        case "iPad14,5", "iPad14,6": return "iPad Pro 13″ M4"
            
        // --- iPod ---
        case "iPod5,1": return "iPod touch (5e gén.)"
        case "iPod7,1": return "iPod touch (6e gén.)"
        case "iPod9,1": return "iPod touch (7e gén.)"
            
        default:
            return id
        }
    }
}
