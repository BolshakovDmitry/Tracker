import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
           // updateSelectedState()
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
        backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        layer.cornerRadius = 8
        
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
        if isSelected {
            layer.borderWidth = 3
            layer.borderColor = UIColor.black.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
}
