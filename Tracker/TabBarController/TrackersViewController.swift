import UIKit


protocol habitCreationViewControllerDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to categoryTitle: String)
}

final class TrackersViewController: UIViewController {
    
    // MARK: - public fields
    
    // Категории с трекерами
    var categories: [TrackerCategory] = []
    
    // Выполненные трекеры
    var completedTrackers: [TrackerRecord] = []
    
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
        imageView.image = UIImage(named: "emptyTrackers") 
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
    

    // Метод для отметки трекера как выполненного
    func completeTracker(id: UUID, date: Date) {
        let record = TrackerRecord(id: id, date: date)
        
        // Проверяем, не был ли трекер уже отмечен в эту дату
        if !completedTrackers.contains(record) {
            // Создаем новый массив с добавленной записью
            completedTrackers = completedTrackers + [record]
        }
    }
    
    // Метод для отмены отметки трекера как выполненного
    func uncompleteTracker(id: UUID, date: Date) {
        let record = TrackerRecord(id: id, date: date)
        
        // Создаем новый массив без этой записи
        completedTrackers = completedTrackers.filter { $0 != record }
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
        // Создаем новый экран выбора типа трекера
        let trackerTypesVC = TrackerTypesViewController()
        
        // Устанавливаем себя в качестве делегата для нового экрана
        trackerTypesVC.trackerViewControllerDelegate = self
        
        // Настраиваем модальное представление
        trackerTypesVC.modalPresentationStyle = .pageSheet
        
        // Показать модально
        present(trackerTypesVC, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
            let formattedDate = dateFormatter.string(from: selectedDate)
            print("Выбранная дата: \(formattedDate)")
        
        // Здесь будет логика фильтрации трекеров по дате
    }
    
    // MARK: - Helpers
    
    private func showEmptyState(_ show: Bool) {
        emptyStateView.isHidden = !show
    }
}

// MARK: - habitCreationViewControllerDelegate

extension TrackersViewController: habitCreationViewControllerDelegate {     // Метод для добавления трекера в категорию
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        var newCategories = [TrackerCategory]()
        var categoryExists = false
        
        for category in categories {
            if category.title == categoryTitle {
                // Создаем новый массив трекеров с добавленным трекером
                let newTrackers = category.trackers + [tracker]
                // Создаем новую категорию с обновленным массивом
                let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                newCategories.append(newCategory)
                categoryExists = true
            } else {
                // Оставляем категорию без изменений
                newCategories.append(category)
            }
        }
        
        // Если категории не существует, создаем новую
        if !categoryExists {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
        }
        
        // Присваиваем новый массив категорий
        categories = newCategories
        print(categories)
    }
}
