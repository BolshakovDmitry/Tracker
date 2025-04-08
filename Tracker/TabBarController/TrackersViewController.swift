import UIKit

protocol habitCreationViewControllerDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to categoryTitle: String)
}

final class TrackersViewController: UIViewController {
    
    // MARK: - public fields
    
    private var dataManager = DataManager.shared
    
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
    
    private var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyTrackers")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
        
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
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
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
        if dataManager.categories.isEmpty {
            placeholderImageView.isHidden = false
        }
    }
        
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем коллекцию на экран
        view.addSubview(trackersCollectionView)
        view.addSubview(searchTextField)
        view.addSubview(placeholderImageView)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
           // placeholderImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           // placeholderImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
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
        
        // Добавляем кнопку "+" слева
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
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
        let trackerTypesVC = TrackerTypesViewController()
        
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
        
        filterTrackers(by: chosenDay)
    }

    // Добавьте отдельный метод для фильтрации:
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

extension TrackersViewController: habitCreationViewControllerDelegate {
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
        
        print("Категории после добавления:", dataManager.visibleCategories)
    }
    
    // Метод для обновления интерфейса после изменения категорий
    private func updateUI() {
        if dataManager.visibleCategories.isEmpty {
            // Показываем заглушку, если категорий нет
            
            trackersCollectionView.isHidden = true
        } else {
            // Скрываем заглушку и показываем коллекцию
            print("in the updateUI in tracker condition")
            //showEmptyState(false)
            //trackersCollectionView.isHidden = false
            trackersCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataManager.visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        let tracker = dataManager.visibleCategories[indexPath.section].trackers[indexPath.item]

        
        let isCompleted = checkIsCompletedToday(id: tracker.id)
        
        cell.delegate = self
        
        let daysCompleted = completedTrackers.filter { currentTracker in
            currentTracker.id == tracker.id
        }.count
        
        cell.configure(tracker: tracker, isCompletedToday: isCompleted, indexPath: indexPath, daysCompleted: daysCompleted)
    
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
            
            headerView.configure(with: dataManager.visibleCategories[indexPath.section].title)
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
        
        filterTrackers(by: chosenDay, searchText: textField.text)
        return true
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func isDone(isComplete: Bool, id: UUID, with indexPath: IndexPath) {
        
        if isComplete {
            let newTracker = TrackerRecord(id: id, date: datePicker.date)
            completedTrackers.append(newTracker)
            trackersCollectionView.reloadItems(at: [indexPath])
        } else {
            completedTrackers.removeAll { trackerRecord in
                let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
                return trackerRecord.id == id && isSameDay
            }
            trackersCollectionView.reloadItems(at: [indexPath])
        }
        
    }
}


