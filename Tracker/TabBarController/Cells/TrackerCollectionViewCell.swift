import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    // Элементы интерфейса ячейки (эмодзи, название, цвет и т.д.)
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.backgroundColor = .ypBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dayCountLabel: UILabel = {
        let label = UILabel()
        label.text = "4"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ID трекера для обработки нажатия
    var trackerId: UUID?
    
    // Настройка действия для кнопки
    var completeAction: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(nameLabel)
        contentView.addSubview(completeButton)
        contentView.addSubview(dayCountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            completeButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            dayCountLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            dayCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func completeButtonTapped() {
        completeAction?(true)
    }
    
    func configure(tracker: Tracker) {
        trackerId = tracker.id
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        containerView.backgroundColor = tracker.color
        completeButton.backgroundColor = tracker.color
       // dayCountLabel.text = String.localizedStringWithFormat("", completedDays)
        
        // Настройка внешнего вида кнопки в зависимости от состояния
//        if isCompleted {
//            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
//            completeButton.backgroundColor = tracker.color
//        } else {
//            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
//            completeButton.backgroundColor = .clear
//            completeButton.layer.borderWidth = 1
//            completeButton.layer.borderColor = tracker.color.cgColor
//        }
    }
}

