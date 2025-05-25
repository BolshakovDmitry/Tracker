import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    // Контейнер для градиента
    private let gradientView = GradientBorderView()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        // Базовые настройки ячейки
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Настройка градиентного представления
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradientView)
        
        // Добавляем элементы на градиентное представление
        gradientView.contentView.addSubview(valueLabel)
        gradientView.contentView.addSubview(titleLabel)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Градиентная рамка занимает всю ячейку с отступами
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Значение внутри карточки
            valueLabel.topAnchor.constraint(equalTo: gradientView.contentView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: gradientView.contentView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: gradientView.contentView.trailingAnchor, constant: -12),
            
            // Заголовок внутри карточки
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: gradientView.contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: gradientView.contentView.trailingAnchor, constant: -12),
        ])
    }
    
    // MARK: - Public methods
    
    func configure(with statisticValue: Int, descriptionText: String) {
        valueLabel.text = "\(statisticValue)"
        titleLabel.text = descriptionText
        
        // Принудительно вызываем layoutIfNeeded для обновления размеров
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // Обновление при смене темы
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            // Обновляем внешний вид при смене темы
            gradientView.updateForCurrentTraitCollection()
        }
    }
    
    // Подготовка к переиспользованию
    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.text = nil
        titleLabel.text = nil
    }
}

// Отдельный класс для градиентной рамки
final class GradientBorderView: UIView {
    
    // Внутреннее представление с фоном
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Слой для градиента
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Настройка слоя градиента
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        layer.addSublayer(gradientLayer)
        
        // Добавляем внутреннее представление
        addSubview(contentView)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // Метод для обновления при смене темы
    func updateForCurrentTraitCollection() {
        contentView.backgroundColor = .systemBackground
        setNeedsDisplay()
    }
}
