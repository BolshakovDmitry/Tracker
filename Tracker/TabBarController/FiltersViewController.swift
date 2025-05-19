import UIKit

enum FilterType: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case uncompleted = "Не завершенные"
}


final class FiltersViewController: UIViewController {
    
    init(delegate: TrackerStoreProtocol?, selectedFilterIndex: Int, date: Int){
        self.delegate = delegate
        self.selectedFilterIndex = selectedFilterIndex
        self.currentDate = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var delegate: TrackerStoreProtocol?
    private let storage = Storage.shared
    private var selectedFilterIndex = 0
    private let currentDate: Int
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Фильтры"
        title.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        } // Светло-серый цвет как на скриншоте
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Выделяем ячейку по умолчанию при первом отображении
        let indexPath = IndexPath(row: selectedFilterIndex, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300) // Примерная высота для 4 ячеек с отступами
        ])
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let filterType = FilterType.allCases[indexPath.row]
        cell.textLabel?.text = filterType.rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
            UIColor.systemGray5 : .customLightGrey
        }
        cell.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        if selectedFilterIndex == indexPath.row {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Обновляем выбранный индекс
               selectedFilterIndex = indexPath.row
        let selectedFilter = FilterType.allCases[indexPath.row]
        
               
               // Сохраняем выбранный фильтр
               storage.store(with: selectedFilter.rawValue)
        
        
        delegate?.filterCategories(by: currentDate, searchText: nil, filterQuery: selectedFilter)
               
               // Обновляем отображение чекмарков
               tableView.reloadData()
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
