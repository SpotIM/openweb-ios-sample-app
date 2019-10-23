//
//  BaseViewController.swift
//  GoScore
//

import UIKit

internal class BaseViewController: UIViewController {
    
    var userRightBarItem: UIBarButtonItem?
    var userIcon: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.backgroundColor = .white
        button.makeViewRound()
        button.contentMode = .scaleAspectFill
        button.setImage(UIImage(spNamed: "userDefault"), for: .normal)
        
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = []
        view.backgroundColor = .white
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // disable dark mode until it's implemented
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        view.backgroundColor = .white
        edgesForExtendedLayout = []
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init is not implemented")
    }
    
}
