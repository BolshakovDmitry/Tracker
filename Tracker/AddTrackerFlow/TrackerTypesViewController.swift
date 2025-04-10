import UIKit

final class TrackerTypesViewController: UIViewController {
    
    // MARK: - Public fields
    
    weak var trackerViewControllerDelegate: habitCreationViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Заголовок в верхней части экрана
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Кнопка Привычка в центре экрана
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Кнопка Нерегулярное событие под первой кнопкой
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func habitButtonTapped() {
      
        // Создаем контроллер создания привычки
        let habitCreationVC = HabitCreationViewController()
        
        // Устанавливаем делегат из сохраненной ссылки
        habitCreationVC.delegate = trackerViewControllerDelegate
        
        // Настраиваем модальное представление
        habitCreationVC.modalPresentationStyle = .pageSheet
        
        // Показываем контроллер создания привычки
        present(habitCreationVC, animated: true, completion: nil)
    }
    
    @objc private func irregularEventButtonTapped() {
    
        // Создаем контроллер создания нерегулярного события
        let irregularEventVC = HabitCreationViewController()
        
        // Устанавливаем тип трекера как нерегулярное событие
        irregularEventVC.trackerType = .irregularEvent
        
        // Устанавливаем делегат из сохраненной ссылки
        irregularEventVC.delegate = trackerViewControllerDelegate
        
        // Настраиваем модальное представление
        irregularEventVC.modalPresentationStyle = .pageSheet
        
        // Показываем контроллер создания нерегулярного события
        present(irregularEventVC, animated: true, completion: nil)
    }
}
