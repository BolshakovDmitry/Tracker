import UIKit

final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Настраиваем заголовок
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
