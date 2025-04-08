import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Добавляем отдельный вью для рамки выделения
    private let selectionBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 1.0) // Цвет E6E8EB
        view.layer.cornerRadius = 12 // Немного больше, чем у ячейки
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем размер рамки выделения, чтобы она точно обрамляла ячейку
        selectionBackgroundView.frame = bounds.insetBy(dx: -4, dy: -4)
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        
        // Сначала добавляем фон для выделения, чтобы он был под ячейкой
        insertSubview(selectionBackgroundView, at: 0)
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    private func updateSelectedState() {
        selectionBackgroundView.isHidden = !isSelected
        
        // Позиционируем рамку выделения
        if isSelected {
            // Подгоняем размер и позицию вью выделения
            selectionBackgroundView.frame = bounds.insetBy(dx: -4, dy: -4)
            selectionBackgroundView.center = CGPoint(
                x: bounds.midX,
                y: bounds.midY
            )
            
            // Применяем трансформацию для добавления эффекта "находится под ячейкой"
            bringSubviewToFront(contentView)
        }
    }
}
