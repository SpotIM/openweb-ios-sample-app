//
//  BaseViewController.swift
//  GoScore
//

import UIKit

internal class SPBaseViewController: UIViewController {
    
    internal weak var customUIDelegate: OWCustomUIDelegate?
    
    var userRightBarItem: UIBarButtonItem?
    var userIcon: OWBaseButton = {
        let button = OWBaseButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.backgroundColor = .white
        button.makeViewRound()
        button.contentMode = .scaleAspectFill
        button.setImage(UIImage(spNamed: "userIcon", supportDarkMode: true), for: .normal)
        
        return button
    }()
    
    init(customUIDelegate: OWCustomUIDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.customUIDelegate = customUIDelegate
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
        
        NotificationCenter.default.addObserver(
                   self,
                   selector: #selector(overrideUserInterfaceStyleDidChange),
                   name: Notification.Name(SpotIm.OVERRIDE_USER_INTERFACE_STYLE_NOTIFICATION),
                   object: nil)
    }
    
    @objc func overrideUserInterfaceStyleDidChange() {
        self.updateColorsAccordingToStyle()
    }
    
    override func viewWillLayoutSubviews() {
        self.updateViewWindowFrameIfChanged()
    }

    func updateColorsAccordingToStyle() {
        let navigationItemTitleView = self.navigationItem.titleView as? UITextView

        if #available(iOS 13.0, *), self.navigationController?.view.tag == SPOTIM_NAV_CONTROL_TAG {
            // back button
            if let backButton = self.navigationItem.leftBarButtonItem?.customView as? UIButton {
                backButton.setImage(UIImage(spNamed: "backButton", supportDarkMode: true), for: .normal)
            }
            
            // title view
            navigationItemTitleView?.textColor = UIColor.spForeground0
            navigationItemTitleView?.isScrollEnabled = false
        
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.updateViewWindowFrameIfChanged()
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
    
    private func updateViewWindowFrameIfChanged() {
        guard let frame = self.view.window?.frame else { return }
        if frame != SPUIWindow.frame {
            SPUIWindow.frame = frame
            viewDidChangeWindowSize()
        }
    }
    
    internal func viewDidChangeWindowSize() {
        // To implement in subclasses
    }
}
