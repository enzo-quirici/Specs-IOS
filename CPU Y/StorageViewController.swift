import UIKit

class StorageViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let usageBarBackground = UIView()
    private let usageBar = UIView()
    private let usageLabel = UILabel()
    
    private var totalCard: UIView?
    private var usedCard: UIView?
    private var freeCard: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        title = "Storage"
        
        setupScrollView()
        setupUsageCard()
        setupStatCards()
        updateStorage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateStorage), name: .systemRefreshTick, object: nil)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
                ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
                ])
        }
    }
    
    private func setupUsageCard() {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        usageBarBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        usageBarBackground.layer.cornerRadius = 12
        usageBarBackground.translatesAutoresizingMaskIntoConstraints = false
        
        usageBar.layer.cornerRadius = 12
        usageBar.translatesAutoresizingMaskIntoConstraints = false
        
        usageLabel.font = UIFont.boldSystemFont(ofSize: 16)
        usageLabel.textColor = .darkText
        usageLabel.textAlignment = .center
        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(usageBarBackground)
        usageBarBackground.addSubview(usageBar)
        card.addSubview(usageLabel)
        
        NSLayoutConstraint.activate([
            usageBarBackground.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            usageBarBackground.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            usageBarBackground.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            usageBarBackground.heightAnchor.constraint(equalToConstant: 30),
            
            usageBar.leadingAnchor.constraint(equalTo: usageBarBackground.leadingAnchor),
            usageBar.topAnchor.constraint(equalTo: usageBarBackground.topAnchor),
            usageBar.bottomAnchor.constraint(equalTo: usageBarBackground.bottomAnchor),
            usageBar.widthAnchor.constraint(equalToConstant: 0),
            
            usageLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            usageLabel.bottomAnchor.constraint(equalTo: usageBarBackground.topAnchor, constant: -8)
            ])
        
        stackView.addArrangedSubview(card)
    }
    
    private func setupStatCards() {
        totalCard = createStatCard(title: "Total", value: "0 GB", color: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1))
        usedCard = createStatCard(title: "Used", value: "0 GB", color: UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1))
        freeCard = createStatCard(title: "Free", value: "0 GB", color: UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1))
        
        if let totalCard = totalCard, let usedCard = usedCard, let freeCard = freeCard {
            stackView.addArrangedSubview(totalCard)
            stackView.addArrangedSubview(usedCard)
            stackView.addArrangedSubview(freeCard)
        }
    }
    
    @objc private func updateStorage() {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
            let totalNum = attrs[.systemSize] as? NSNumber,
            let freeNum = attrs[.systemFreeSize] as? NSNumber else {
                return
        }
        
        let totalGB = Double(totalNum.uint64Value) / 1024 / 1024 / 1024
        let freeGB = Double(freeNum.uint64Value) / 1024 / 1024 / 1024
        let usedGB = totalGB - freeGB
        
        // Mettre à jour la carte graphique
        usageLabel.text = String(format: "Usage : %.1f%%", (usedGB / totalGB * 100))
        let usageRatio = CGFloat(usedGB / totalGB)
        let maxWidth = usageBarBackground.frame.width
        let newWidth = maxWidth * usageRatio
        
        let color: UIColor
        switch usageRatio {
        case 0..<0.5: color = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        case 0.5..<0.8: color = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        default: color = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        }
        usageBar.backgroundColor = color
        
        UIView.animate(withDuration: 0.3) {
            self.usageBar.frame.size.width = newWidth
        }
        
        // Mettre à jour les cartes
        updateCard(card: totalCard, value: String(format: "%.1f GB", totalGB))
        updateCard(card: usedCard, value: String(format: "%.1f GB", usedGB))
        updateCard(card: freeCard, value: String(format: "%.1f GB", freeGB))
    }
    
    private func createStatCard(title: String, value: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = title
        titleLabel.textColor = .darkText
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 24)
        valueLabel.textColor = color
        valueLabel.text = value
        valueLabel.tag = 101 // identifier pour update
        
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
    
    private func updateCard(card: UIView?, value: String) {
        guard let card = card else { return }
        if let valueLabel = card.viewWithTag(101) as? UILabel {
            valueLabel.text = value
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
