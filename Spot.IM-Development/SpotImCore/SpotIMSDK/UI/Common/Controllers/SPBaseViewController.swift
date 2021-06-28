//
//  BaseViewController.swift
//  GoScore
//

import UIKit

internal class SPBaseViewController: UIViewController {
    
    weak var customUIDelegate: CustomUIDelegate?
    
    var userRightBarItem: UIBarButtonItem?
    var userIcon: BaseButton = {
        let button = BaseButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.backgroundColor = .white
        button.makeViewRound()
        button.contentMode = .scaleAspectFill
        button.setImage(UIImage(spNamed: "userIcon"), for: .normal)
        
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)

        view.semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
        ?? view.semanticContentAttribute
        overrideInterfaceStyleIfNeeded()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .spBackground0

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    func updateColorsAccordingToStyle() {
        let navigationItemTitleView = self.navigationItem.titleView as? UITextView

        if #available(iOS 13.0, *), self.navigationController?.view.tag == SPOTIM_NAV_CONTROL_TAG {
            // back button
            if let backButton = self.navigationItem.leftBarButtonItem?.customView as? UIButton {
                backButton.setImage(UIImage(spNamed: "backButton"), for: .normal)
            }
            
            // title view
            navigationItemTitleView?.textColor = UIColor.spForeground0
        
            // nav bar
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.spForeground0]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.spForeground0]
            navBarAppearance.backgroundColor = .spBackground0
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        if let navigationItemTitleView = navigationItemTitleView {
            customUIDelegate?.customizeNavigationItemTitle(textView: navigationItemTitleView)
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init is not implemented")
    }

    private func overrideInterfaceStyleIfNeeded() {
        guard #available(iOS 13.0, *), let style = SpotIm.overrideUserInterfaceStyle else { return }
        overrideUserInterfaceStyle = style.nativeValue
    }
}
