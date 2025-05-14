import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectionBorderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(selectionBorderView)
        selectionBorderView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            selectionBorderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBorderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBorderView.widthAnchor.constraint(equalToConstant: 52),
            selectionBorderView.heightAnchor.constraint(equalToConstant: 52),
            
            colorView.centerXAnchor.constraint(equalTo: selectionBorderView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: selectionBorderView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                if let originalColor = colorView.backgroundColor {
                    let colorA = originalColor.withAlphaComponent(0.3)
                    selectionBorderView.layer.borderColor = colorA.cgColor
                }
            } else {
                selectionBorderView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}
