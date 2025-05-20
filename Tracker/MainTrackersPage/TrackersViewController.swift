import UIKit

protocol habitCreationVCDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to categoryTitle: String)
}

final class TrackersViewController: UIViewController, TrackerCreationViewControllerDelegate {
    func updateTracker(tracker: Tracker, category: String) -> Bool {
        true
    }
    
    func didCreateTracker(tracker: Tracker, category: String) {
    }
    
    
    // MARK: - public fields
    
    var delegateCoreData: TrackerStoreProtocol?
    var delegateCellCoreData: TrackerRecordStoreProtocol?
    // MARK: - UI Elements
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.tintColor = .ypBlue
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
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
        label.text = NSLocalizedString("emptyState.trackers.title", comment: "")
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
        collectionView.backgroundColor = UIColor(named: "BackGroundColor")
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
    
    private lazy var filterButton: UIButton = {
        let filterButton =  UIButton()
        filterButton.setTitle(NSLocalizedString("filters.button", comment: ""), for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        filterButton.backgroundColor = .systemBlue
        filterButton.layer.cornerRadius = 16
        filterButton.isHidden = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        return filterButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(named: "BackGroundColor")
        
        updateFilterBackGroundColor()
        
        setupUI()
        setupNavigationBar()
        reloadTableWithActualDayTrackers()
        searchTextField.becomeFirstResponder()
        updatePlaceholderVisibility()
        setupActions()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        
        // Добавляем элементы в стек
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Добавляем элементы на экран
        view.addSubview(trackersCollectionView)
        view.addSubview(searchTextField)
        view.addSubview(placeholderStackView)
        view.addSubview(filterButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Констрейнты для стека с заглушкой
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
        
    }
    
    private func setupActions(){
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        filterButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
    }
    
    @objc private func filterButtonPressed(){
        
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "filter")
        
        // Получаем сохраненное значение фильтра (строку)
        let selectedFilterString = Storage.shared.chosenFilter ?? FilterType.today.rawValue
        
        // Находим индекс фильтра в перечислении по его строковому значению
        let selectedFilterIndex = FilterType.allCases.firstIndex { $0.rawValue == selectedFilterString } ?? 1
        
        let calendar = Calendar.current
        let chosenDay = calendar.component(.weekday, from: datePicker.date)
        
        let filtersVC = FiltersViewController(delegate: self.delegateCoreData, selectedFilterIndex: selectedFilterIndex, date: chosenDay)
        
        // Устанавливаем замыкание
        filtersVC.onFilterUpdated = { [weak self] in
            self?.updateFilterBackGroundColor()
        }
        
        self.present(filtersVC, animated: true)
    }
    
    private func reloadTableWithActualDayTrackers() {
        dateChanged(datePicker)
    }
    
    func updateFilterBackGroundColor() {
        
        guard let backGroundcolor = Storage.shared.chosenFilter else {
            filterButton.backgroundColor = .blue
            return }
        
        print(" ---------------------------------\(backGroundcolor)")
        
        if backGroundcolor != "Трекеры на сегодня" {
            filterButton.backgroundColor = .red
        } else { filterButton.backgroundColor = .blue }
    }
    
    private func setupNavigationBar() {
        // Настраиваем заголовок
        title = NSLocalizedString("trackers.button.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Создаем кастомную кнопку с жирным плюсом
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        navigationItem.leftBarButtonItem = addButton
        
        // Добавляем DatePicker справа
        let datePickerButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "add_track")
        
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
        
        delegateCoreData?.filterCategories(by: chosenDay, searchText: nil, filterQuery: .all)
    }
    
    
    private func updatePlaceholderVisibility() {
        if let numberOfSections = delegateCoreData?.numberOfSections, numberOfSections > 0 {
            placeholderStackView.isHidden = true
            filterButton.isHidden = false
            
        } else {
            placeholderStackView.isHidden = false
            filterButton.isHidden = true
        }
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
            
            let isPinned = delegateCoreData?.getCategory(at: indexPath) ?? "No category"
            // Проверяем, выполнен ли трекер сегодня
            let isCompleted = delegateCellCoreData?.isTrackerCompletedToday(id: tracker.id, date: datePicker.date) ?? false
            
            cell.delegate = self
            
            // Подсчитываем количество выполненных дней
            let daysCompleted = delegateCellCoreData?.countCompletedDays(id: tracker.id) ?? 0
            
            cell.configure(tracker: tracker, isCompletedToday: isCompleted, indexPath: indexPath, daysCompleted: daysCompleted, isPinned: isPinned)
            
        }
        
        return cell
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
        
        
        let storageFilterString = Storage.shared.chosenFilter ?? FilterType.all.rawValue
        
        // Находим соответствующий тип фильтра из сохраненного значения
        let filterType = FilterType.allCases.first { filterType in
            filterType.rawValue == storageFilterString
        } ?? .all // Значение по умолчанию, если не найдено
        
        print("!!!!!!!!!!!!!!", filterType)
        
        delegateCoreData?.filterCategories(by: chosenDay, searchText: textField.text, filterQuery: filterType)
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
            
            AlertPresenter.shared.showAlert(with: NSLocalizedString("error", comment: ""), with: NSLocalizedString("cannot.mark.future.trackers", comment: ""), show: self)
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

extension TrackersViewController: TrackerRecordStoreDelegate & TrackerStoreDelegate {
    func didUpdate() {
        delegateCoreData?.loadAllCategories()
        delegateCoreData?.filterVisibleCategories()
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
}

extension TrackersViewController {
   
    func previewForContextMenu(for cell: TrackerCollectionViewCell?) -> UIViewController {
        // Simply delegate to the cell's existing method
        return cell?.previewForContextMenu() ?? UIViewController()
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPaths.count > 0,
              let indexPath = indexPaths.first,
              let choosenTracker = delegateCoreData?.object(at: indexPath),
              let categoryName = delegateCoreData?.getCategory(at: indexPath),
              let daysDone = delegateCoreData?.getCompletedDaysCount(for: choosenTracker.id),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        else {
            return nil }
        
        
        // Проверяем, закреплен ли трекер (находится ли он в категории "Закрепленные")
        let isPinned = categoryName == NSLocalizedString("pinned", comment: "")
        
        print(choosenTracker.id)
        
        return UIContextMenuConfiguration(         identifier: indexPath as NSCopying,
                                                   previewProvider: { [weak self, weak cell] in
            return self?.previewForContextMenu(for: cell)
        },
                                                   
                                                   actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: isPinned ? NSLocalizedString("unpin.tracker.button", comment: "") : NSLocalizedString("pin.tracker.button", comment: "")) { _ in
                    _ = self.delegateCoreData?.pinTracker(tracker: choosenTracker, isPinned: !isPinned)
                },
                UIAction(title: NSLocalizedString("edit.button", comment: "")) { [weak self] _ in
                    guard let self else { return }
                    let trackerCreationVC = TrackerCreationViewController()
                    let trackerStore = TrackerStore(delegate: self)
                    trackerCreationVC.trackerType = .edit
                    trackerCreationVC.delegateTrackerCoreData = trackerStore
                    trackerCreationVC.tracker = choosenTracker
                    trackerCreationVC.categoryName = categoryName
                    trackerCreationVC.setSchedule(selectedSchedule: choosenTracker.schedule)
                    trackerCreationVC.setCategory(category: categoryName)
                    trackerCreationVC.completedDaysCount = daysDone
                    trackerCreationVC.modalPresentationStyle = .pageSheet
                    
                    AnalyticsService.shared.report(event: "click", screen: "Main", item: "edit")
                    
                    self.present(trackerCreationVC, animated: true, completion: nil)
                },
                UIAction(title: NSLocalizedString("delete.button", comment: ""), attributes: .destructive) { _ in
                    AlertPresenter.shared.showAlert(
                        with: NSLocalizedString("delete.tracker.alert", comment: ""),
                        with: "",
                        show: self,
                        preferredStyle: .actionSheet,
                        with: [
                            UIAlertAction(title: NSLocalizedString("delete.button", comment: ""), style: .destructive) { _ in
                                _ = self.delegateCoreData?.deleteTracker(at: indexPath)
                                // Здесь можно также добавить обработку результата, если нужно
                            },
                            UIAlertAction(title: NSLocalizedString("cancel.alert.button", comment: ""), style: .cancel)
                        ]
                    )
                    AnalyticsService.shared.report(event: "click", screen: "Main", item: "delete")
                }
            ])
        })
        
    }
}


