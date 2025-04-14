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
        switchControl.onTintColor = .black
        switchControl.isUserInteractionEnabled = false // Отключаем взаимодействие с самим переключателем, так как выбор происходит нажатием на всю ячейку
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.onTintColor = .ypBlue
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
    
    // Метод для настройки ячейки
    func configure(with dayName: String, isSelected: Bool) {
        dayLabel.text = dayName
        switchControl.isOn = isSelected
    }
}
