import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        // Установим прозрачный фон по умолчанию
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionBackgroundView: UIView = {
        let view = UIView()
        // Динамический цвет для темной темы
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : 
                UIColor(named: "CustomLightGrey") ?? UIColor.lightGray.withAlphaComponent(0.3) // Светло-серый для светлой темы
        }
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Храним текущую тему для корректной обработки изменений
    private var isDarkTheme: Bool = false
    
    override var isSelected: Bool {
        didSet {
            updateSelectedState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Прозрачный фон ячейки для корректного отображения selectionBackgroundView
        backgroundColor = .clear
        layer.cornerRadius = 8
    
        // Сначала добавляем selectionBackgroundView как подвид основного представления
        addSubview(selectionBackgroundView)
        // Затем добавляем emojiLabel как подвид contentView
        contentView.addSubview(emojiLabel)
    
        NSLayoutConstraint.activate([
            selectionBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            selectionBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Убедимся, что selectionBackgroundView находится за emojiLabel
        sendSubviewToBack(selectionBackgroundView)
    }
    
    // Обновленный метод configure для поддержки темной темы
    func configure(with emoji: String, isDarkTheme: Bool = false) {
        emojiLabel.text = emoji
        self.isDarkTheme = isDarkTheme
        
        // Обновляем фон и цвета в зависимости от текущей темы
        updateSelectedState()
    }
    
    // Метод для обновления состояния выделения
    private func updateSelectedState() {
        // Показываем/скрываем фон выделения
        selectionBackgroundView.isHidden = !isSelected
    }
    
    // Для обработки повторного использования ячеек
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        selectionBackgroundView.isHidden = true
    }
}
