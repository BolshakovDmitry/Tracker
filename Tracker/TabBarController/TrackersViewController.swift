import UIKit

protocol habitCreationVCDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to categoryTitle: String)
}

final class TrackersViewController: UIViewController {
    
    // MARK: - public fields
    
    private var dataManager = DataManager.shared
    var delegateCoreData: TrackerStoreProtocol?
    var delegateCellCoreData: TrackerRecordStoreProtocol?
    
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
    
    private let placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyTrackers")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textfield = UISearchTextField()
        textfield.backgroundColor = UIColor(named: "#7676801F")
        textfield.textColor = .black
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.cornerRadius = 16
        textfield.heightAnchor.constraint(equalToConstant: 36).isActive = true
        textfield.delegate = self
        textfield.isUserInteractionEnabled = true
        
        // Настройка плейсхолдера
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypGrey
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes
        )
        textfield.attributedPlaceholder = attributedPlaceholder
        
        // UISearchTextField уже имеет встроенную иконку поиска
        
        return textfield
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 9
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HeaderView"
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        reloadTableWithActualDayTrackers()
        searchTextField.becomeFirstResponder()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы в стек
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Добавляем элементы на экран
        view.addSubview(trackersCollectionView)
        view.addSubview(searchTextField)
        view.addSubview(placeholderStackView)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Констрейнты для стека с заглушкой
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Задаем размеры для изображения
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    private func reloadTableWithActualDayTrackers() {
        dateChanged(datePicker)
    }
    
    private func setupNavigationBar() {
        // Настраиваем заголовок
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Создаем кастомную кнопку с жирным плюсом
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = addButton
        
        // Добавляем DatePicker справа
        let datePickerButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        // Создаем новый экран выбора типа трекера
        let trackerTypesVC = TrackerTypesViewController(delegate: delegateCoreData)
        
        // Устанавливаем себя в качестве делегата для нового экрана
        trackerTypesVC.trackerViewControllerDelegate = self
        
        // Настраиваем модальное представление
        trackerTypesVC.modalPresentationStyle = .pageSheet
        
        // Показать модально
        present(trackerTypesVC, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        let chosenDay = calendar.component(.weekday, from: datePicker.date)
        
        delegateCoreData?.filterCategories(by: chosenDay, searchText: nil)
    }
    
    
    private func updatePlaceholderVisibility() {
        if let numberOfSections = delegateCoreData?.numberOfSections, numberOfSections > 0 {
            placeholderStackView.isHidden = true
        } else {
            placeholderStackView.isHidden = false
        }
    }
    
    
    private func filterTrackers(by weekday: Int, searchText: String? = nil) {
        
        if searchText == nil {
            // Фильтруем по дням недели
            let filteredCategories = dataManager.categories.map { category in
                TrackerCategory(title: category.title,
                                trackers: category.trackers.filter { tracker in
                    tracker.schedule.contains { weekDay in
                        weekDay.numberValue == weekday
                    }
                })
            }.filter { !$0.trackers.isEmpty }
            dataManager.visibleCategories = filteredCategories
        } else {
            
            // Дополнительная фильтрация по тексту, если он предоставлен
            if let text = searchText, !text.isEmpty {
                let filteredCategoriesByDateAndTextField = dataManager.categories.map { category in
                    TrackerCategory(title: category.title,
                                    trackers: category.trackers.filter { tracker in
                        tracker.name.lowercased().contains(text.lowercased()) && tracker.schedule.contains { weekDay in
                            weekDay.numberValue == weekday
                        }
                    })
                }.filter { !$0.trackers.isEmpty }
                dataManager.visibleCategories = filteredCategoriesByDateAndTextField
            }
            
        }
        
        
        // Анимируем изменение прозрачности
        UIView.animate(withDuration: 0.3, animations: {
            self.trackersCollectionView.alpha = 0
        }, completion: { _ in
            self.trackersCollectionView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.trackersCollectionView.alpha = 1
            }
        })
    }
    
}


// MARK: - habitCreationViewControllerDelegate

extension TrackersViewController: habitCreationVCDelegate {
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        var newCategories = [TrackerCategory]()
        var categoryExists = false
        
        for category in dataManager.visibleCategories {
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
        
        // обновляем массивы в датаменеджер
        dataManager.updateCategories(with: newCategories)
        
        // Обновляем интерфейс
        trackersCollectionView.reloadData()
        
    }
    
    
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegateCoreData?.numberOfSections ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegateCoreData?.numberOfRowsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell
        else { return UICollectionViewCell() }
        
        if let tracker = delegateCoreData?.object(at: indexPath) {
            
            
            // Проверяем, выполнен ли трекер сегодня
            let isCompleted = delegateCellCoreData?.isTrackerCompletedToday(id: tracker.id, date: datePicker.date) ?? false
            
            cell.delegate = self
            
            // Подсчитываем количество выполненных дней
            let daysCompleted = delegateCellCoreData?.countCompletedDays(id: tracker.id) ?? 0
            
            cell.configure(tracker: tracker, isCompletedToday: isCompleted, indexPath: indexPath, daysCompleted: daysCompleted)
        }
        
        return cell
    }
    
    private func checkIsCompletedToday(id: UUID) -> Bool {
        
        
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath
            ) as! TrackerHeaderView
            
            // Получаем название секции из delegateCoreData
            if let sectionTitle = delegateCoreData?.sectionTitle(for: indexPath.section) {
                headerView.configure(with: sectionTitle)
            } else {
                // Запасной вариант, если метод не реализован или вернул nil
                headerView.configure(with: "Секция \(indexPath.section + 1)")
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 9) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - UITextFieldSearchDelegate

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let calendar = Calendar.current
        let chosenDay = calendar.component(.weekday, from: datePicker.date)
        
        delegateCoreData?.filterCategories(by: chosenDay, searchText: textField.text)
        return true
    }
}

// MARK: - Cell Delegate

extension TrackersViewController: TrackerCellDelegate {
    func isDone(isComplete: Bool, id: UUID, with indexPath: IndexPath, type: TrackerType) {
        // Проверяем, что выбранная дата не находится в будущем, сравнивая только даты без учета времени
        let calendar = Calendar.current
        let today = Date()
        
        // Сравниваем даты с помощью Calendar
        // Результат: -1 если datePicker.date раньше today, 0 если равны, 1 если datePicker.date позже today
        let comparison = calendar.compare(datePicker.date, to: today, toGranularity: .day)
        
        if comparison == .orderedDescending {
            
            AlertPresenter.shared.showAlert(with: "Ошибка", with: "Нельзя отмечать привычки для будущих дат", show: self)
            // Если дата в будущем, показываем предупреждение и отменяем действие
            
            return
        }
        
        let tracker = TrackerRecord(id: id, date: datePicker.date)
        
        if isComplete {
            delegateCellCoreData?.isDoneTapped(tracker: tracker, trackerType: type)
        } else {
            delegateCellCoreData?.unDoneTapped(tracker: tracker, trackerType: type)
        }
        
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(category: TrackerUpdate) {
        trackersCollectionView.reloadData()
    }
    
}


extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdate() {
        delegateCoreData?.loadAllCategories()
        delegateCoreData?.filterVisibleCategories()
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    
}

