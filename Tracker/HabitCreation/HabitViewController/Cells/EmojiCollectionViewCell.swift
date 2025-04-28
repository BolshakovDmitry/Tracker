import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "CustomLightGrey")
        view.layer.cornerRadius = 16
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
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
    
        addSubview(selectionBackgroundView)
        contentView.addSubview(emojiLabel)
    
        NSLayoutConstraint.activate([
            selectionBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            selectionBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        sendSubviewToBack(selectionBackgroundView)
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    private func updateSelectedState() {
        selectionBackgroundView.isHidden = !isSelected
    }
}
