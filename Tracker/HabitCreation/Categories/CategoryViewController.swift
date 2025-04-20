import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

protocol CategoryViewControllerDelegate: AnyObject {
    func addCategory(with category: TrackerCategory)
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategory?
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    var delegateCoreData: CategoryViewControllerDelegate?
    weak var delegate: CategorySelectionDelegate?
    private var dataManager = DataManager.shared
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.backgroundColor = .ypBlack
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupActions()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        
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
            
            //  Кнопка
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
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
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategory()
        newCategoryVC.delegate = self
        newCategoryVC.modalPresentationStyle = .pageSheet
        present(newCategoryVC, animated: true)
    }
}

// MARK: - NewCategoryDelegate

extension CategoryViewController: NewCategoryDelegate {
    func didCreateCategory(_ categoryName: String) {
        
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        var updatedCategories = dataManager.categories
        updatedCategories.append(newCategory)
        dataManager.categories = updatedCategories
        
        // Обновляем таблицу
        tableView.reloadData()
    
        delegateCoreData?.addCategory(with: newCategory)
        
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegateCoreData?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        guard let record = delegateCoreData?.object(at: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = record.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedCategory = delegateCoreData?.object(at: indexPath)?.title else { return }
        
        // Передаем выбранную категорию делегату
        delegate?.didSelectCategory(selectedCategory)
        
        // Закрываем экран
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoryViewController: TrackerCategoryStoreDelegate {
    func didUpdate(category: TrackerCategoryUpdate) {
        tableView.performBatchUpdates {
            let insertedIndexPaths = category.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = category.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            tableView.deleteRows(at: deletedIndexPaths, with: .fade)
        }
    }
    

    
    
}
