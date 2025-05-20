import UIKit
import CoreData

final class StatisticsViewController: UIViewController {
    
    // MARK: - Types
    
    // Модель данных для статистики
    struct StatisticItem {
        let title: String
        let value: Int
    }
    
    // MARK: - Properties
    
    private var trackerRecordStore: TrackerRecordStoreProtocol?
    private var statistics: [StatisticItem] = []
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistic.button.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.textColor = .label // Адаптивный цвет для темной темы
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // Placeholder для пустого экрана
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
        imageView.image = UIImage(named: "noStatisticData")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label // Адаптивный цвет для темной темы
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем цвет фона для темной темы
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupTableView()
        configureStores()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Обновляем статистику при каждом появлении экрана
        updateStatistics()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        // Настраиваем заглушку для пустого экрана
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        view.addSubview(placeholderStackView)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Таблица со статистикой
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Заглушка для пустого экрана
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: "StatisticsCell")
    }
    
    private func configureStores() {
        // Инициализируем хранилище записей трекеров
        let trackerRecordStore = TrackerRecordStore(delegate: self)
        self.trackerRecordStore = trackerRecordStore
    }
    
    private func updateStatistics() {
        // Получаем статистику трекеров
        let completedCount = trackerRecordStore?.getCompletedTrackersCount() ?? 0
        
        // Создаем массив с элементами статистики
        statistics = [
            StatisticItem(title: String.localizedStringWithFormat(
                NSLocalizedString("statistics", comment: "Pluralized form of trackers count")),
                          value: completedCount)
        ]
        // Обновляем таблицу
        tableView.reloadData()
        
        // Показываем или скрываем заглушку
        let hasStatistics = completedCount > 0
        placeholderStackView.isHidden = hasStatistics
        tableView.isHidden = !hasStatistics
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsCell", for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        
        let item = statistics[indexPath.row]
        cell.configure(with: item.value, title: item.title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // Высота ячейки
    }
}

// MARK: - TrackerRecordStoreDelegate

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func didUpdate() {
        // Вызывается при обновлении данных в хранилище
        updateStatistics()
    }
}
