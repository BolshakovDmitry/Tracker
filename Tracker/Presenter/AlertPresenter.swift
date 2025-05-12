import UIKit

final class AlertPresenter {
    
    static let shared = AlertPresenter()
    
    private init() {}
    
    /// Показывает стандартный алерт с кнопкой "ОК"
    func showAlert(with title: String, with text: String, show vc: UIViewController, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: preferredStyle
        )
        
        let okAction = UIAlertAction(
            title: "ОК",
            style: .default,
            handler: nil
        )
        
        alert.addAction(okAction)
        
        // Если это Action Sheet, добавляем кнопку "Отменить"
        if preferredStyle == .actionSheet {
            let cancelAction = UIAlertAction(
                title: "Отменить",
                style: .cancel,
                handler: nil
            )
            alert.addAction(cancelAction)
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    /// Показывает алерт с пользовательскими действиями
    func showAlert(with title: String, with text: String,
                   show vc: UIViewController,
                   preferredStyle: UIAlertController.Style = .alert,
                   with actions: [UIAlertAction]? = nil) {
        
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: preferredStyle
        )
        
        if let actions = actions, !actions.isEmpty {
            actions.forEach{ alert.addAction($0)}
            
            // Для Action Sheet убедимся, что есть кнопка "Отменить"
            if preferredStyle == .actionSheet && !actions.contains(where: { $0.style == .cancel }) {
                let cancelAction = UIAlertAction(
                    title: "Отменить",
                    style: .cancel,
                    handler: nil
                )
                alert.addAction(cancelAction)
            }
        } else {
            let okAction = UIAlertAction(
                title: "ОК",
                style: .default,
                handler: nil
            )
            alert.addAction(okAction)
            
            // Если это Action Sheet, добавляем кнопку "Отменить"
            if preferredStyle == .actionSheet {
                let cancelAction = UIAlertAction(
                    title: "Отменить",
                    style: .cancel,
                    handler: nil
                )
                alert.addAction(cancelAction)
            }
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    /// Специальный метод для отображения Action Sheet с кнопками "Удалить" и "Отменить"
    func showDeleteAlert(title: String, message: String?, show vc: UIViewController, deleteHandler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { _ in
            deleteHandler()
        }
        
        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        vc.present(alert, animated: true)
    }
}
