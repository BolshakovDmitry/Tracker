import UIKit

class AlertPresenter {
    
    static let shared = AlertPresenter()
    
    private init() {}
    
    func showAlert(with title: String, with text: String, show vc: UIViewController) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "ОК",
            style: .default,
            handler: nil
        )
        
        alert.addAction(okAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(with title: String, with text: String,
                   show vc: UIViewController,
                   with actions: [UIAlertAction]? = nil) {
        
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )
        
        if let actions = actions, !actions.isEmpty {
            actions.forEach{ alert.addAction($0)}
        } else {
            let okAction = UIAlertAction(
                title: title,
                style: .default,
                handler: nil
            )
            alert.addAction(okAction)
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}
