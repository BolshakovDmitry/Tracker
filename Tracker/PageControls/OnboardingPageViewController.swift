import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    // Массив контроллеров страниц
    private var pages: [UIViewController] = []
    
    // Page Control для отображения индикаторов страниц
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 2
        control.currentPage = 0
        control.pageIndicatorTintColor = .systemGray4
        control.currentPageIndicatorTintColor = .black
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаем страницы
        let firstPage = SplashViewController()
        let secondPage = SplashViewController2()
        
        // Добавляем страницы в массив
        pages = [firstPage, secondPage]
        
        // Настраиваем UIPageViewController
        dataSource = self
        delegate = self
        
        // Устанавливаем начальную страницу
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        // Добавляем pageControl
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
        
        // Добавляем наблюдателя за изменениями страницы
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let targetPage = pages[currentPage]
        setViewControllers([targetPage], direction: currentPage > (pageControl.currentPage) ? .forward : .reverse, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: visibleViewController) {
            pageControl.currentPage = index
        }
    }
}
