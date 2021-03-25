//
//  BaseViewController.swift
//  GoScore
//

import UIKit

internal class BaseViewController: UIViewController {
    
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
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init is not implemented")
    }

    private func overrideInterfaceStyleIfNeeded() {
        guard #available(iOS 13.0, *), let style = SpotIm.overrideUserInterfaceStyle else { return }
        overrideUserInterfaceStyle = style.nativeValue
    }
}
