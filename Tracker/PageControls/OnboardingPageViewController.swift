
import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    private var pages: [UIViewController] = []
    
    lazy private var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.pageIndicatorTintColor = .systemGray4
        control.currentPageIndicatorTintColor = .black
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = SplashViewController()
        let vc2 = SplashViewController2()
        pages.append(vc1)
        pages.append(vc2)
        
        dataSource = self
        delegate = self
        
        guard let firstPage = pages.first else { return }
        setViewControllers([firstPage], direction: .forward, animated: true)
        
        setupUI()
    }
    
    private func setupUI() {
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168)
        ])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let prevIndex = currentIndex - 1
        
        if prevIndex < 0 {
            return nil
        }
        
        return pages[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = currentIndex + 1
        
        if nextIndex >= pages.count {
            return nil
        }
        
        return pages[nextIndex]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: visibleViewController) {
            pageControl.currentPage = index
        }
    }
}
