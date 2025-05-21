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
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Скролл-вью для контейнера (чтобы прокручивать, если слишком много категорий)
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        return scrollView
    }()
    
    // Контентное представление для scrollView
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Контейнер для таблицы со скругленными углами
    private let tableContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        
        // Отключаем скроллинг таблицы
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    // Ограничение высоты таблицы, которое будем изменять при изменении данных
    private var tableHeightConstraint: NSLayoutConstraint?
    
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle(NSLocalizedString("add.category", comment: ""), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .systemBlue : .ypBlack
        }
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    
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
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    private var rowsCount = 0
    private let cellHeight: CGFloat = 75 // Высота одной ячейки
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
               
        setupUI()
        setupTableView()
        setupActions()
        updatePlaceholderVisibility()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Настраиваем стек с заглушкой
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(tableContainerView)
        tableContainerView.addSubview(tableView)
        contentView.addSubview(placeholderStackView)
        
        view.addSubview(addButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Заголовок в верхней части экрана
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // ScrollView для обеспечения прокрутки
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            // Content View внутри ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // Ширина равна scrollView
            
            // Контейнер таблицы
            tableContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            // Нижний констрейнт может быть гибким, если нужно добавить другие элементы в contentView
            
            // Таблица внутри контейнера
            tableView.topAnchor.constraint(equalTo: tableContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor),
            
            // Стек с заглушкой
            placeholderStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: tableContainerView.centerYAnchor),
            
            // Размеры для изображения
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Кнопка
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Создаем констрейнт для высоты таблицы, который будем обновлять динамически
        let tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint.isActive = true
        self.tableHeightConstraint = tableHeightConstraint
        
        // Добавляем констрейнт для высоты контейнера, равной высоте таблицы
        NSLayoutConstraint.activate([
            tableContainerView.heightAnchor.constraint(equalTo: tableView.heightAnchor),
            // Добавляем констрейнт, чтобы контейнер был привязан к низу contentView
            tableContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
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
            guard let self = self else { return }
            self.rowsCount = count
            print("Количество строк обновлено: \(count)")
            self.updateTableHeight()
        }
                
        // Подписываемся на обновления категорий
        viewModel.onCategoryUpdate = { [weak self] update in
            guard let self = self else { return }
            
            // Преобразуем IndexSet в массив для удобного вывода
            let insertedArray = Array(update.insertedIndexes)
            print("Контроллер получил обновление таблицы. Вставленные индексы: \(insertedArray), Количество строк: \(self.rowsCount)")

            self.tableView.performBatchUpdates {
                let insertedIndexPaths = self.indexPaths(from: update.insertedIndexes)
                print(insertedIndexPaths)
                self.tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            } completion: { _ in
                // После обновления таблицы обновляем высоту
                self.updateTableHeight()
                
                // Обновляем разделители всех ячеек
                //self.updateLastCellSeparator()
            }
            
//            tableView.reloadData()
//            self.updateTableHeight()
//            
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
        let hasCategories = viewModel.hasCategories()
        placeholderStackView.isHidden = hasCategories
        tableContainerView.isHidden = !hasCategories
    }
    
    // Метод для обновления высоты таблицы на основе количества ячеек
    private func updateTableHeight() {
        // Вычисляем высоту таблицы на основе количества строк
        let calculatedHeight = CGFloat(rowsCount) * cellHeight
        
        // Устанавливаем минимальную высоту, чтобы было видно пустой контейнер
        let minHeight: CGFloat = rowsCount > 0 ? calculatedHeight : 150
        
        // Обновляем констрейнт высоты таблицы
        tableHeightConstraint?.constant = minHeight
        
        // Обновляем contentSize scrollView, если она не обновляется автоматически
        scrollView.layoutIfNeeded()
        
        // Обновляем высоту contentView, если необходимо
        let contentHeight = tableContainerView.frame.maxY
        contentView.frame.size.height = max(contentHeight, scrollView.frame.height)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
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
        
        
        // Делаем фон ячейки прозрачным, чтобы был виден фон контейнера
        cell.backgroundColor = .clear
        
        // Настройка цвета выделения
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemGray5
        cell.selectedBackgroundView = selectedBackgroundView
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            
            let customSeparator = UIView(frame: CGRect(x: 16, y: cell.frame.height - 2, width: cell.frame.width - 32, height: 0.5))
            customSeparator.backgroundColor = UIColor(named: "YP Grey")
            cell.contentView.addSubview(customSeparator)
        }
        
        let previousIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
         if let previousCell = tableView.cellForRow(at: previousIndexPath) {
             // Добавляем новый разделитель
             let customSeparator = UIView(frame: CGRect(x: 16, y: previousCell.frame.height - 2, width: previousCell.frame.width - 32, height: 0.5))
             customSeparator.backgroundColor = UIColor(named: "YP Grey")
             previousCell.contentView.addSubview(customSeparator)
                        }
                        
   
                    

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
        return cellHeight
    }
}
