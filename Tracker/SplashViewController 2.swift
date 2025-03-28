
import UIKit

class SplashViewController2: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "backgroundPink") 
        imageView.contentMode = .scaleAspectFill // Заполняет весь экран
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabelCenter: UILabel = {
        let textLabelCenter = UILabel()
        textLabelCenter.text = "Даже если это \nне литры воды и йога"
        textLabelCenter.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabelCenter.textColor = .ypBlack
        textLabelCenter.numberOfLines = 2
        textLabelCenter.textAlignment = .center
        textLabelCenter.translatesAutoresizingMaskIntoConstraints = false
        return textLabelCenter
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Добавляем и настраиваем фоновое изображение и текст
        setup()
        
        // Добавляем обработчик нажатия
            actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
       @objc private func buttonTapped() {
        print("Кнопка нажата!")
           var mainTabBarController = MainTabBarController()
           mainTabBarController.modalPresentationStyle = .fullScreen
           self.present(mainTabBarController, animated: true)
    }
    
    private func setup() {
        // Добавляем изображение на задний план
        view.addSubview(backgroundImageView)
        view.addSubview(textLabelCenter)
        view.addSubview(actionButton)
        
        // Растягиваем изображение на весь экран
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Центрируем текст на экране
        NSLayoutConstraint.activate([
            textLabelCenter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabelCenter.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // кнопка
        NSLayoutConstraint.activate([
                   actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
                   actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
               ])
        
    }
    
}
