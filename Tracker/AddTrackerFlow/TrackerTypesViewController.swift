import UIKit

final class TrackerTypesViewController: UIViewController {
    
    private var delegateCoreData: TrackerStoreProtocol?
    
    init(delegate: TrackerStoreProtocol?) {
        self.delegateCoreData = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Public fields
    
    weak var trackerViewControllerDelegate: TrackerCreationViewControllerDelegate?
    
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.creation.type.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
            label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("habit.button.title", comment: ""), for: .normal)
        button.setTitleColor(UIColor(named: "BackGroundColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("event.button.title", comment: ""), for: .normal)
        button.setTitleColor(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                .black : .white
            }, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        
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
        
        let habitCreationVC = TrackerCreationViewController()
        habitCreationVC.delegate = trackerViewControllerDelegate
        habitCreationVC.delegateTrackerCoreData = delegateCoreData as? any TrackerCreationViewControllerDelegate
        habitCreationVC.modalPresentationStyle = .pageSheet
        
        present(habitCreationVC, animated: true, completion: nil)
    }
    
    @objc private func irregularEventButtonTapped() {
        print("Выбрано нерегулярное событие")
        let irregularEventVC = TrackerCreationViewController()
        irregularEventVC.trackerType = .irregularEvent
        irregularEventVC.delegate = trackerViewControllerDelegate
        irregularEventVC.delegateTrackerCoreData = delegateCoreData as? any TrackerCreationViewControllerDelegate
        irregularEventVC.modalPresentationStyle = .pageSheet
        present(irregularEventVC, animated: true, completion: nil)
    }
}
