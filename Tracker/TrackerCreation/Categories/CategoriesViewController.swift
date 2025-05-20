import UIKit

protocol CategoriesSelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

protocol CategoriesViewControllerDelegate: AnyObject {
    func addCategory(with category: TrackerCategory)
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategory?
}

final class CategoriesViewController: UIViewController {
    
    init(viewModel: CategoriesViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var delegate: CategoriesSelectionDelegate?
    private var viewModel: CategoriesViewModel
    
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text =  NSLocalizedString("category.tableview.button", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        // Используем системный цвет для автоматической адаптации
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        // Используем системный цвет фона вместо белого
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle(NSLocalizedString("add.category", comment: ""), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        // Используем системный цвет или динамический цвет
        addButton.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .systemBlue : .ypBlack // Используйте .systemBlue для темной темы или другой контрастный цвет
        }
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    
    // Добавленный стек для заглушки
    private let placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyTrackers")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("category.view.placeholder", comment: "")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        // Используем системный цвет текста
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    private var rowsCount = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Обновляем цвет фона на системный
        view.backgroundColor = .systemBackground
               
        setupUI()
        setupTableView()
        setupActions()
        updatePlaceholderVisibility()
        setupBindings()
    }
    
    // Добавляем метод для отслеживания изменения темы
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            // Если нужно обновить какие-то элементы, специфичные для смены темы
            tableView.reloadData() // Перезагружаем таблицу для обновления цветов
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Настраиваем стек с заглушкой
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(placeholderStackView)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Заголовок в верхней части экрана
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Таблица
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            // Кнопка
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Стек с заглушкой
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            // Размеры для изображения
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
    }
    
    private func indexPaths(from indexes: IndexSet) -> [IndexPath] {
        indexes.map { IndexPath(row: $0, section: 0) }
    }
    
    private func setupBindings() {
        // Подписываемся на изменение количества строк
        viewModel.rowsBinding = { [weak self] count in
            guard let self else { return }
            self.rowsCount = count
            print("Количество строк обновлено: \(count)")
        }
                
        // Подписываемся на обновления категорий
        viewModel.onCategoryUpdate = { [weak self] update in
            guard let self else { return }
            
            // Преобразуем IndexSet в массив для удобного вывода
            let insertedArray = Array(update.insertedIndexes)
            print("Контроллер получил обновление таблицы. Вставленные индексы: \(insertedArray), Количество строк: \(self.rowsCount)")

            self.tableView.performBatchUpdates {
                let insertedIndexPaths = self.indexPaths(from: update.insertedIndexes)
                print(insertedIndexPaths)
                self.tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            }
     
            // Обновляем видимость заглушки после изменений
            self.updatePlaceholderVisibility()
        }
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = viewModel
        newCategoryVC.modalPresentationStyle = .pageSheet
        present(newCategoryVC, animated: true)
    }
    
    // MARK: - Helpers
    
    private func updatePlaceholderVisibility() {
        placeholderStackView.isHidden = viewModel.hasCategories()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let record = viewModel.getObject(indexPath: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Настройка цвета текста ячейки для поддержки темной темы
        cell.textLabel?.text = record.title
        cell.textLabel?.textColor = .label
        
        // Настройка фона ячейки
        cell.backgroundColor = .secondarySystemBackground
        
        // Настройка цвета выделения
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemGray5
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedCategory = viewModel.getObject(indexPath: indexPath)?.title else { return }
        
        // Передаем выбранную категорию делегату
        delegate?.didSelectCategory(selectedCategory)
        
        // Закрываем экран
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
           }
       }
