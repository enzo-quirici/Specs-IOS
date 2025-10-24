import UIKit

class RAMViewController: UIViewController {
    
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        title = "RAM"
        
        setupStackView()
        updateRAM()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRAM),
                                               name: .systemRefreshTick,
                                               object: nil)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
        } else {
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
        }
    }
    
    @objc private func updateRAM() {
        guard let mem = SystemUtils.memoryInfo() else { return }
        
        func fmt(_ v: UInt64) -> String {
            return String(format: "%.1f MB", Double(v) / 1024.0 / 1024.0)
        }
        
        let usedRatio = CGFloat(mem.used) / CGFloat(mem.total)
        
        // Vider les cartes existantes
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // --- Carte globale avec graphique total ---
        stackView.addArrangedSubview(createGlobalRAMCard(usage: usedRatio))
        
        // --- Cartes séparées ---
        let info: [(String, UInt64, UIColor)] = [
            ("Total", mem.total, UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)),
            ("Used", mem.used, UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)),
            ("Free", mem.total - mem.used, UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1))
            
        ]
        
        for (title, value, color) in info {
            stackView.addArrangedSubview(createCard(title: title, value: fmt(value), color: color, usage: CGFloat(value) / CGFloat(mem.total)))
        }
    }
    
    private func createGlobalRAMCard(usage: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Total RAM"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkText
        
        let barBackground = UIView()
        barBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        barBackground.layer.cornerRadius = 10
        barBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let bar = UIView()
        bar.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        bar.layer.cornerRadius = 10
        bar.translatesAutoresizingMaskIntoConstraints = false
        barBackground.addSubview(bar)
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, barBackground])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            bar.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
            bar.topAnchor.constraint(equalTo: barBackground.topAnchor),
            bar.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor),
            bar.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: usage)
            ])
        
        return card
    }
    
    private func createCard(title: String, value: String, color: UIColor, usage: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkText
        titleLabel.text = title
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 20)
        valueLabel.textColor = color
        valueLabel.text = value
        
        let barBackground = UIView()
        barBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        barBackground.layer.cornerRadius = 6
        barBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let bar = UIView()
        bar.backgroundColor = color
        bar.layer.cornerRadius = 6
        bar.translatesAutoresizingMaskIntoConstraints = false
        barBackground.addSubview(bar)
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, barBackground])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            bar.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
            bar.topAnchor.constraint(equalTo: barBackground.topAnchor),
            bar.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor),
            bar.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: usage)
            ])
        
        return card
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
