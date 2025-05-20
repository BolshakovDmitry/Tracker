import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: CategoriesViewModelProtocol?
    private let minCategoryNameLength = 4
    private let alertPresenter = AlertPresenter.shared
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("new.category.button.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = UIColor(named: "CustomBackgroundDay")
        textfield.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.cornerRadius = 16
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textfield.frame.height))
        textfield.leftViewMode = .always
        textfield.delegate = self
        textfield.isUserInteractionEnabled = true
        textfield.placeholder = NSLocalizedString("new.category.name.placeholder", comment: "")
        textfield.clearButtonMode = .whileEditing
        textfield.returnKeyType = .done
        return textfield
    }()
    
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle(NSLocalizedString("done.black.button", comment: ""), for: .normal)
        addButton.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .black : .white
        }, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                .white : .black
        }
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.isEnabled = false
        return addButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryNameTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(categoryNameTextField)
        view.addSubview(addButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            // Заголовок в верхней части экрана
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            //  TextField
            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            //  Кнопка
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func updateAddButtonState() {
        let isCategoryNameValid = (categoryNameTextField.text?.count ?? 0) >= minCategoryNameLength
        
        addButton.isEnabled = isCategoryNameValid
        addButton.backgroundColor = isCategoryNameValid ? .ypBlack : .lightGray
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else {
            return
        }
        
        guard let existingCategories = delegate?.isSameName(with: categoryName) else { return }
        
        if existingCategories {
            alertPresenter.showAlert(with: "Ошибка", with: "Данная категория уже есть", show: self)
            return
        }
        
        // Если категории с таким названием нет, создаем новую категорию
        delegate?.didCreateCategory(categoryName)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Получаем новый текст после изменения
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Проверяем длину имени категории и обновляем состояние кнопки
        let isCategoryNameValid = updatedText.count >= minCategoryNameLength
        
        addButton.isEnabled = isCategoryNameValid
        addButton.backgroundColor = isCategoryNameValid ? .ypBlack : .lightGray
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if addButton.isEnabled {
            addButtonTapped()
        }
        return true
    }
}
