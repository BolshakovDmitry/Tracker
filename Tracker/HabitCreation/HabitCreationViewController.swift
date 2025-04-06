import UIKit

protocol HabitCreationViewControllerProtocol: AnyObject {
    var delegate: habitCreationViewControllerDelegate? { get set }
}

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ schedule: Set<WeekDay>)
}

final class HabitCreationViewController: UIViewController {

    // MARK: - public fields
    
    var delegate: habitCreationViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название привычки"
        textField.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        button.layer.cornerRadius = 10
        
        // Добавляем иконку ">"
        let chevronImage = UIImage(systemName: "chevron.right")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .gray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        button.layer.cornerRadius = 10
        
        // Добавляем иконку ">"
        let chevronImage = UIImage(systemName: "chevron.right")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .gray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
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
    private var selectedColorIndex: IndexPath?
    private var selectedCategory: String?
    private var selectedSchedule: Set<WeekDay> = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupButtons()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(categoryButton)
        view.addSubview(scheduleButton)
        view.addSubview(collectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Заголовок в верхней части экрана
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Текстовое поле
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // Категория
            categoryButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            // Расписание
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 1),
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            
            // CollectionView
            collectionView.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 32),
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
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Регистрируем ячейки и заголовки
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
    }
    
    private func setupButtons() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func createButtonTapped() {
        // Проверяем что все поля заполнены
        // Проверяем, что все поля заполнены
                guard
                    let text = nameTextField.text, !text.isEmpty,
                    let emojiIndex = selectedEmojiIndex?.item,
                    let colorIndex = selectedColorIndex?.item,
                    !selectedSchedule.isEmpty // Проверяем, что расписание выбрано
                else {
                    // Здесь можно показать алерт с ошибкой
                    print("Необходимо заполнить все поля")
                    return
                }
                
                let selectedEmoji = emojis[emojiIndex]
                let selectedColor = colors[colorIndex]

                // Создаем новую привычку с выбранным расписанием
                let newTracker = Tracker(name: text, color: selectedColor, emoji: selectedEmoji, schedule: selectedSchedule, type: .habit)
                
                // Здесь будет логика сохранения новой привычки
                print("Создана новая привычка: \(newTracker)")
                
                // Используем категорию или "Общее", если категория не выбрана
                delegate?.addTracker(newTracker, to: selectedCategory ?? "Общее")
        
        let previousVC = self.presentingViewController
        
        // Закрываем оба экрана
           dismiss(animated: true) {
               // После закрытия HabitCreationViewController закрываем и TrackerTypesViewController
               previousVC?.dismiss(animated: true)
           }
    }
    
    // Добавьте метод для форматирования дней недели для отображения на кнопке
        private func formattedSchedule(_ weekDays: Set<WeekDay>) -> String {
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
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            }
        }
    
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        print("Переход к выбору категории")
        let categoryVC = CategoryViewController()
        
        categoryVC.delegate = self
        
        categoryVC.modalPresentationStyle = .pageSheet
        
        present(categoryVC, animated: true)
        
    }
    
    @objc private func scheduleButtonTapped() {
        print("Переход к настройке расписания")
        // Создаем экземпляр нового контроллера
                let scheduleVC = ScheduleViewController()
                // Устанавливаем текущий класс как делегат
                scheduleVC.delegate = self
                // Задаем стиль представления
                scheduleVC.modalPresentationStyle = .pageSheet
                // Показываем экран выбора расписания
                present(scheduleVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HabitCreationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCollectionViewCell
            cell.configure(with: emojis[indexPath.item])
            cell.isSelected = indexPath == selectedEmojiIndex
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
            cell.configure(with: colors[indexPath.item])
            cell.isSelected = indexPath == selectedColorIndex
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // Выбран эмодзи
            if let previousSelectedIndex = selectedEmojiIndex {
                // Снимаем выделение с предыдущей ячейки
                let cell = collectionView.cellForItem(at: previousSelectedIndex) as? EmojiCollectionViewCell
                cell?.isSelected = false
            }
            // Устанавливаем выделение на новую ячейку
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.isSelected = true
            selectedEmojiIndex = indexPath
        } else {
            // Выбран цвет
            if let previousSelectedIndex = selectedColorIndex {
                // Снимаем выделение с предыдущей ячейки
                let cell = collectionView.cellForItem(at: previousSelectedIndex) as? ColorCollectionViewCell
                cell?.isSelected = false
            }
            // Устанавливаем выделение на новую ячейку
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.isSelected = true
            selectedColorIndex = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath
            ) as! HeaderView
            
            let title = indexPath.section == 0 ? "Emoji" : "Цвет"
            headerView.configure(with: title)
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Рассчитываем размер ячейки (6 ячеек в ряду с отступами)
        let width = (collectionView.frame.width - 15 * 5) / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
}

// MARK: - CategorySelectionDelegate

extension HabitCreationViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: String) {
        categoryButton.setTitle(category, for: .normal)
        selectedCategory = category
    }
}

extension HabitCreationViewController: ScheduleSelectionDelegate {
    func didSelectSchedule(_ schedule: Set<WeekDay>) {
            // Сохраняем выбранное расписание
            selectedSchedule = schedule
            
            // Обновляем текст на кнопке расписания
            if !schedule.isEmpty {
                // Показываем выбранные дни в компактном формате
                scheduleButton.setTitle(formattedSchedule(schedule), for: .normal)
            } else {
                // Возвращаем стандартный текст, если ничего не выбрано
                scheduleButton.setTitle("Расписание", for: .normal)
            }
        }
}
