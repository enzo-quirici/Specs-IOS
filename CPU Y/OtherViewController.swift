import UIKit

class OtherViewController: UIViewController {
    private let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Other"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "À compléter…"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
}
