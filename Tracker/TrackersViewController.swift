import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = UIColor(named: "YP Blue")
        return picker
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyTrackers") // Добавьте изображение в ассеты
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        
        // Показываем заглушку, так как список трекеров пуст
        showEmptyState(true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем заглушку
        setupEmptyStateView()
        
        // Настраиваем обработчик выбора даты
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        // Настраиваем заголовок
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Добавляем кнопку "+" слева
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem = addButton
        
        // Добавляем DatePicker справа
        let datePickerButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    private func setupEmptyStateView() {
        // Добавляем view для заглушки
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyTitleLabel)
        
        // Настраиваем констрейнты для элементов заглушки
        NSLayoutConstraint.activate([
            // Констрейнты для контейнера заглушки
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
            
            // Констрейнты для изображения
            emptyImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Констрейнты для текста
            emptyTitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        print("Нажата кнопка добавления трекера")
        // Здесь будет логика для добавления новых трекеров в следующих уроках
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        print("Выбрана дата: \(selectedDate)")
        
        // Здесь будет логика фильтрации трекеров по дате
    }
    
    // MARK: - Helpers
    
    private func showEmptyState(_ show: Bool) {
        emptyStateView.isHidden = !show
    }
}
