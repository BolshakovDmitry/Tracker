import UIKit

// MARK: - ColorCollectionViewCell

final class ColorCollectionViewCell: UICollectionViewCell {
    
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
        layer.cornerRadius = 8
    }
    
    func configure(with color: UIColor) {
        backgroundColor = color
    }
    
    private func updateSelectedState() {
        if isSelected {
            // Удаляем стандартную границу
            layer.borderWidth = 0
            
            // Настраиваем тень для создания эффекта окружающей рамки
            layer.shadowColor = UIColor(red: 0.0, green: 0.8, blue: 0.5, alpha: 1.0).cgColor // Светло-зеленый цвет
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowRadius = 6.0
            layer.shadowOpacity = 0.7
            layer.masksToBounds = false // Важно! Разрешает тени выходить за границы view
        } else {
            // Сбрасываем тень при отмене выделения
            layer.shadowOpacity = 0
        }
    }
}
