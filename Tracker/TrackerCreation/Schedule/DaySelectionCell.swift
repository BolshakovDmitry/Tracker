import UIKit
// Класс ячейки для выбора дня недели
final class DaySelectionCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    // Метка для отображения названия дня недели
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Переключатель для выбора дня
    private let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isUserInteractionEnabled = false // Отключаем взаимодействие с самим переключателем, так как выбор происходит нажатием на всю ячейку
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.onTintColor = .systemBlue // Системный синий цвет, который адаптируется к теме
        return switchControl
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    // Настройка интерфейса ячейки
    private func setupUI() {
        selectionStyle = .none // Убираем стиль выделения при нажатии
        backgroundColor = .clear
        
        // Добавляем элементы на ячейку
        contentView.addSubview(dayLabel)
        contentView.addSubview(switchControl)
        
        // Настраиваем ограничения (constraints)
        NSLayoutConstraint.activate([
            // Название дня слева
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Переключатель справа
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    // Метод для настройки ячейки с поддержкой темной темы
    func configure(with dayName: String, isSelected: Bool, isDarkTheme: Bool = false) {
        dayLabel.text = dayName
        switchControl.isOn = isSelected
        
        // Настройка цвета текста в зависимости от темы
        dayLabel.textColor = isDarkTheme ? .white : .black
        
        // Настройка цвета переключателя в зависимости от темы
        switchControl.onTintColor = isDarkTheme ? .systemBlue : .ypBlue
        
        // Настройка цвета фона ячейки (если нужно)
        backgroundColor = isDarkTheme ?
            UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) : // Темно-серый для темной темы
            .clear // Прозрачный для светлой темы
    }
}
