import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ schedule: [WeekDay])
}

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func didCreateTracker(tracker: Tracker, category: String)
    func updateTracker(tracker: Tracker, category: String) -> Bool
}

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Types
    
    // Типы настроек в таблице
    private enum SettingsType: Int, CaseIterable {
        case category
        case schedule
        
        var title: String {
            switch self {
            case .category:
                return  NSLocalizedString("category.tableview.button", comment: "")
            case .schedule:
                return NSLocalizedString("schedule.tableview.button", comment: "")
            }
        }
    }
    
    // MARK: - public methods and fields
    
    func setSchedule(selectedSchedule: [WeekDay]) {
        self.selectedSchedule = selectedSchedule
    }
    
    func setCategory(category: String){
        self.selectedCategory = category
    }
    
    var delegate: TrackerCreationViewControllerDelegate?
    var delegateTrackerCoreData: TrackerCreationViewControllerDelegate?
    var trackerType: TrackerType = .habit
    var tracker: Tracker?
    var categoryName: String?
    var completedDaysCount: Int = 0
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let labelEditMode: UILabel = {  // лейбл если страница в режиме редактирования
        let label = UILabel()
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder =  NSLocalizedString("event.name.placeholder", comment: "")
        textField.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        textField.backgroundColor = UIColor(named: "CustomBackgroundDay")
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Заменяем отдельные кнопки на TableView
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        tableView.separatorStyle = .none // Убираем стандартные разделители
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .systemBackground : .white
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("cancel.alert.button", comment: ""), for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .systemBackground : .white
        }
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("create.creation.tracker.button", comment: ""), for: .normal)
        button.setTitleColor(UIColor(named: "BackGroundColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .lightGray // Изначально серый
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // Изначально неактивна
        return button
    }()
    
    // MARK: - Properties
    
    private let emojis = ["🙂", "😻", "🐶", "😱", "😇", "😡", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "🚀", "🏆", "🎯", "🧠"]
    
    private let colors: [UIColor] = [
        UIColor(red: 0.20, green: 0.81, blue: 0.41, alpha: 1.0), // #33CF69
        UIColor(red: 1.00, green: 0.40, blue: 0.30, alpha: 1.0), // #FF674D
        UIColor(red: 0.55, green: 0.45, blue: 0.90, alpha: 1.0), // #8D72E6
        UIColor(red: 0.90, green: 0.43, blue: 0.83, alpha: 1.0), // #E66DD4
        UIColor(red: 1.00, green: 0.60, blue: 0.80, alpha: 1.0), // #FF99CC
        UIColor(red: 0.18, green: 0.82, blue: 0.35, alpha: 1.0), // #2FD058
        UIColor(red: 0.43, green: 0.27, blue: 1.00, alpha: 1.0), // #6E44FE
        UIColor(red: 0.21, green: 0.20, blue: 0.49, alpha: 1.0), // #35347C
        UIColor(red: 0.68, green: 0.34, blue: 0.85, alpha: 1.0), // #AD56DA
        UIColor(red: 0.00, green: 0.48, blue: 0.98, alpha: 1.0), // #007BFA
        UIColor(red: 0.27, green: 0.90, blue: 0.62, alpha: 1.0), // #46E69D
        UIColor(red: 0.51, green: 0.17, blue: 0.94, alpha: 1.0), // #832CF1
        UIColor(red: 1.00, green: 0.53, blue: 0.12, alpha: 1.0), // #FF881E
        UIColor(red: 0.20, green: 0.65, blue: 1.00, alpha: 1.0), // #34A7FE
        UIColor(red: 0.47, green: 0.58, blue: 0.96, alpha: 1.0), // #7994F5
        UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1.0), // #FD4C49
        UIColor(red: 0.98, green: 0.83, blue: 0.83, alpha: 1.0), // #F9D4D4
        UIColor(red: 0.96, green: 0.77, blue: 0.55, alpha: 1.0)  // #F6C48B
    ]
    
    private var selectedEmojiIndex: IndexPath?
    private var previousSelectedEmojiIndex: IndexPath? = nil
    private var selectedColorIndex: IndexPath?
    private var selectedCategory: String?
    private var selectedSchedule: [WeekDay] = []
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Устанавливаем заголовок в зависимости от типа трекера
        if trackerType == .edit {
            titleLabel.text = "Редактирование привычки"
            nameTextField.text = tracker?.name
        }  else {
            titleLabel.text = trackerType == .habit ?  NSLocalizedString("new.habit.vc.title", comment: "") : NSLocalizedString("event.button.title", comment: "")
        }
        setupUI()
        setupTableView()
        setupCollectionView()
        setupButtons()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        
        if trackerType == .edit {
            view.addSubview(labelEditMode)
            // Использование локализованной строки с форматированием для множественного числа
            labelEditMode.text = String.localizedStringWithFormat(
                NSLocalizedString("number.of.days", comment: "Pluralized form of days count"),
                completedDaysCount
            )
        }
    
        view.addSubview(nameTextField)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        // Настраиваем констрейнты
        
        // Заголовок в верхней части экрана
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        // Добавим констрейнты для меток количества дней только в режиме редактирования
        if trackerType == .edit {
            NSLayoutConstraint.activate([
                labelEditMode.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                labelEditMode.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                nameTextField.topAnchor.constraint(equalToSystemSpacingBelow: labelEditMode.bottomAnchor, multiplier: 8)
            ])
        } else {
            NSLayoutConstraint.activate([
                // Текстовое поле идет сразу после заголовка
                nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            ])
        }
        NSLayoutConstraint.activate([
            // Текстовое поле
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // TableView для категории и расписания
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: (trackerType == .habit || trackerType == .edit) ? 150 : 75),
            
            // CollectionView
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            // Кнопка отмены
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            
            // Кнопка создания
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Регистрируем ячейку
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.separatorColor = UIColor(named: "CustomGrey")?.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 16 // Добавляем скругление углов
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Регистрируем ячейки и заголовки
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
    }
    
    private func setupButtons() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Начальное состояние - неактивное
        updateCreateButtonState()
        
        // Добавляем наблюдателя для изменения текста в поле ввода
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // Метод для проверки всех полей и обновления состояния кнопки
    private func updateCreateButtonState() {
        let isTextValid = (nameTextField.text?.count ?? 0) >= 4
        let isCategorySelected = selectedCategory != nil
        
        let isScheduleSelected = trackerType == .irregularEvent || !selectedSchedule.isEmpty
        let isEmojiSelected = selectedEmojiIndex != nil
        let isColorSelected = selectedColorIndex != nil
        
        let isFormValid = isTextValid && isCategorySelected && isScheduleSelected && isEmojiSelected && isColorSelected
        
        let backgroundColorForButton = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        createButton.isEnabled = isFormValid
        //createButton.backgroundColor = isFormValid ? .black : .lightGray
        createButton.backgroundColor = isFormValid ?  UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        } : .lightGray
        
    }
    
    // Обработчик изменения текста
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    // метод для форматирования строки с количеством дней
    private func formatDaysString(with count: Int) -> String {
        let remainder = count % 10
        switch remainder {
        case 1:
            return "день"
        case 2,3,4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    // MARK: - Actions + Создание привычки
    
    @objc private func createButtonTapped() {
        guard
            let text = nameTextField.text, !text.isEmpty,
            let emojiIndex = selectedEmojiIndex?.item,
            let colorIndex = selectedColorIndex?.item
        else {
            AlertPresenter.shared.showAlert(with: NSLocalizedString("error", comment: ""), with: NSLocalizedString("must.have.all.fiedls", comment: ""), show: self)
            return
        }
        
        let selectedEmoji = emojis[emojiIndex]
        let selectedColor = colors[colorIndex]
        let trackerID = tracker?.id ?? UUID()
        
        // Для нерегулярного события устанавливаем пустое расписание
        let schedule = trackerType == .habit || trackerType == .edit ? selectedSchedule : WeekDay.allCases
        
        //        // Создаем новую привычку с выбранным расписанием
        //        let newTracker = Tracker(name: text, color: selectedColor, emoji: selectedEmoji, schedule: schedule, type: trackerType)
        
        if trackerType == .edit {
            let updatedTracker = Tracker(id: trackerID, name: text, color: selectedColor, emoji: selectedEmoji, schedule: schedule,
                                         type: tracker?.type ?? .habit)
            print("Updated Tracker -", updatedTracker)
            _ = delegateTrackerCoreData?.updateTracker(tracker: updatedTracker, category: selectedCategory ?? "No category")
        } else {
            // Создаем новую привычку с выбранным расписанием
            let newTracker = Tracker(name: text, color: selectedColor, emoji: selectedEmoji, schedule: schedule, type: trackerType)
            print("Создан новый трекер: \(newTracker)")
            delegateTrackerCoreData?.didCreateTracker(tracker: newTracker, category: selectedCategory ?? "No category")
        }
        
        let previousVC = self.presentingViewController
        
        // Закрываем оба экрана
        dismiss(animated: true) {
            if self.trackerType != .edit {
                // После закрытия HabitCreationViewController закрываем и TrackerTypesViewController
                previousVC?.dismiss(animated: true)
            }
        }
    }
    
    // Метод для форматирования дней недели для отображения на кнопке
    private func formattedSchedule(_ weekDays: [WeekDay]) -> String {
        // Если выбраны все 7 дней, показываем "Каждый день"
        if weekDays.count == 7 {
            return "Каждый день"
        }
        
        // Сортируем дни по порядку и формируем строку с сокращенными названиями
        let sortedDays = weekDays.sorted { $0.rawValue < $1.rawValue }
        let shortNames = sortedDays.map { shortName(for: $0) }
        return shortNames.joined(separator: ", ")
    }
    
    // Метод для получения сокращенных названий дней недели
    private func shortName(for weekDay: WeekDay) -> String {
        switch weekDay {
        case .monday: return NSLocalizedString("weekday.monday.short", comment: "")
        case .tuesday: return NSLocalizedString("weekday.tuesday.short", comment: "")
        case .wednesday: return NSLocalizedString("weekday.wednesday.short", comment: "")
        case .thursday: return NSLocalizedString("weekday.thursday.short", comment: "")
        case .friday: return NSLocalizedString("weekday.friday.short", comment: "")
        case .saturday: return NSLocalizedString("weekday.saturday.short", comment: "")
        case .sunday: return NSLocalizedString("weekday.sunday.short", comment: "")
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // Обработчик нажатия на ячейку категории
    private func showCategoryViewController() {
        
        let viewModel = CategoriesViewModel()
        let categoryVC = CategoriesViewController(viewModel: viewModel)
        let trackerCategoryStore = TrackerCategoryStore(delegate: viewModel)
        
        viewModel.model = trackerCategoryStore
        categoryVC.delegate = self
        
        categoryVC.modalPresentationStyle = .pageSheet
        
        present(categoryVC, animated: true)
    }
    
    // Обработчик нажатия на ячейку расписания
    private func showScheduleViewController() {
        
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        
        // Создаем navigation controller с scheduleVC в качестве корневого
        let navController = UINavigationController(rootViewController: scheduleVC)
        
        // Настраиваем presentation style (можно использовать .pageSheet или .formSheet)
        navController.modalPresentationStyle = .pageSheet
        
        // Презентуем navigation controller
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TrackerCreationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if trackerType == .edit {
            return 2
        } else {
            return trackerType == .habit ? SettingsType.allCases.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsTableViewCell
        
        // Для нерегулярного события всегда показываем только категорию
        
        let settingsTypeIndex = (trackerType == .habit || trackerType == .edit)  ? indexPath.row : SettingsType.category.rawValue
        
        guard let settingsType = SettingsType(rawValue: settingsTypeIndex), let cell = cell else {
            return UITableViewCell()
        }
        
        var value: String?
        
        if trackerType == .edit {
            switch settingsType {
            case .category:
                value = selectedCategory
            case .schedule:
                value = selectedSchedule.isEmpty ? nil : formattedSchedule(selectedSchedule)
            }
        } else {
            switch settingsType {
            case .category:
                value = selectedCategory
            case .schedule:
                value = selectedSchedule.isEmpty ? nil : formattedSchedule(selectedSchedule)
            }
        }
        
        let isLast: Bool = false
        
        // Настраиваем сепаратор
        if indexPath.row == (trackerType == .habit || trackerType == .edit ? SettingsType.allCases.count - 1 : 0) {
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            
            let customSeparator = UIView(frame: CGRect(x: 16, y: cell.frame.height - 2, width: cell.frame.width - 32, height: 0.5))
            customSeparator.backgroundColor = UIColor(named: "YP Grey")
            cell.contentView.addSubview(customSeparator)
        }
        
        
        // Настраиваем ячейку через метод configure
        
        cell.configure(with: settingsType.title, value: value, isLast: isLast)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Для нерегулярного события всегда обрабатываем как категорию
        let settingsTypeIndex = trackerType == .habit || trackerType == .edit ? indexPath.row : SettingsType.category.rawValue
        
        guard let settingsType = SettingsType(rawValue: settingsTypeIndex) else {
            return
        }
        
        switch settingsType {
        case .category:
            showCategoryViewController()
        case .schedule:
            showScheduleViewController()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Высота каждой ячейки
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Убираем сепаратор у последней ячейки
        if indexPath.row == SettingsType.allCases.count - 1 || trackerType == .irregularEvent {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension TrackerCreationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: emojis[indexPath.item])
            cell.isSelected = false
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: colors[indexPath.item])
            cell.isSelected = indexPath == selectedColorIndex
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            // Выбран эмодзи
            
            if previousSelectedEmojiIndex == nil {
                
                // кривая реализация чтобы сохронялись выделения обеих секций
                let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
                cell?.isSelected = true
                selectedEmojiIndex = indexPath
                previousSelectedEmojiIndex = indexPath
            } else {
                guard let previousSI = previousSelectedEmojiIndex else { return }
                let cell = collectionView.cellForItem(at: previousSI) as? EmojiCollectionViewCell
                cell?.isSelected = false
                previousSelectedEmojiIndex = indexPath
                selectedEmojiIndex = indexPath
            }
        } else {
            // Выбран цвет
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.isSelected = true
            selectedColorIndex = indexPath
            guard let index2 = selectedEmojiIndex else { return }
            let cell2 = collectionView.cellForItem(at: index2) as? EmojiCollectionViewCell
            cell2?.isSelected = true
            
        }
        
        // Проверяем состояние формы после выбора
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath
            ) as? TrackerHeaderView else {
                return UICollectionReusableView()
            }
            
            let title = indexPath.section == 0 ? "Emoji" : NSLocalizedString("color.collection.title", comment: "")
            headerView.configure(with: title)
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    
    // Константы для расчета размеров и отступов
    private struct LayoutConstants {
        static let itemSize: CGFloat = 52
        static let interitemSpacing: CGFloat = 5
        static let lineSpacing: CGFloat = 0
        static let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        static let headerHeight: CGFloat = 40
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: LayoutConstants.itemSize, height: LayoutConstants.itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return LayoutConstants.interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LayoutConstants.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return LayoutConstants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: LayoutConstants.headerHeight)
    }
}

// MARK: - CategorySelectionDelegate

extension TrackerCreationViewController: CategoriesSelectionDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        // Обновляем отображение в таблице
        tableView.reloadRows(at: [IndexPath(row: SettingsType.category.rawValue, section: 0)], with: .none)
        updateCreateButtonState()
    }
}

extension TrackerCreationViewController: ScheduleSelectionDelegate {
    func didSelectSchedule(_ schedule: [WeekDay]) {
        // Сохраняем выбранное расписание
        selectedSchedule = schedule
        
        // Обновляем отображение в таблице
        tableView.reloadRows(at: [IndexPath(row: SettingsType.schedule.rawValue, section: 0)], with: .none)
        
        updateCreateButtonState()
    }
}

