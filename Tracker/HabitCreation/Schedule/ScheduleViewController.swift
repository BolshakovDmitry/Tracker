import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: ScheduleSelectionDelegate?
    
    private var selectedDays: Set<WeekDay> = []
    
    // Заголовок экрана
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Таблица для отображения дней недели
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // Кнопка "Готово" внизу экрана
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
    }
    
    // Настройка пользовательского интерфейса
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на основной вид
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        // Настраиваем ограничения (constraints) для элементов интерфейса
        NSLayoutConstraint.activate([
            // Заголовок вверху экрана
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Таблица под заголовком
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Кнопка "Готово" внизу экрана
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // Настройка таблицы для отображения дней недели
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DaySelectionCell.self, forCellReuseIdentifier: "DaySelectionCell")
    }
    
    // Настройка действий для кнопок
    private func setupActions(){
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectSchedule(selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DaySelectionCell", for: indexPath) as! DaySelectionCell
        
        // Получаем день недели для текущей строки
        let weekDay = WeekDay.allCases[indexPath.row]
        // Проверяем, выбран ли этот день
        let isSelected = selectedDays.contains(weekDay)
        
        // Настраиваем ячейку с названием дня и состоянием переключателя
        cell.configure(with: weekDay.localizedName, isSelected: isSelected)
        
        return cell
    }
    
    // Обработка нажатия на строку таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Получаем выбранный день недели
        let weekDay = WeekDay.allCases[indexPath.row]
        
        // Если день уже был выбран - убираем его из списка, иначе добавляем
        if selectedDays.contains(weekDay) {
            selectedDays.remove(weekDay)
        } else {
            selectedDays.insert(weekDay)
        }
        
        // Обновляем вид ячейки
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // Высота строки в таблице
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

