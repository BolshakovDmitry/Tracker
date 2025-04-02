import UIKit

// MARK: - ColorCollectionViewCell

class ColorCollectionViewCell: UICollectionViewCell {
    
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
            layer.borderWidth = 3
            layer.borderColor = UIColor.black.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
}
