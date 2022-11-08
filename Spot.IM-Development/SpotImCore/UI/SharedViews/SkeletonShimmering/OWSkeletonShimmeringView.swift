//
//  OWSkeletonShimmeringView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

/*
 - Basically everything is done almost automatically!
 - All you need to do is create a view which inherits from OWSkeletonShimmeringView.
   Inside that view, add all the subviews which you would like - they can look however you want.
 - The skeleton shimmering service and protocols will take care of everything related to the UI colors and etc.
 - Once you would like to show the skeleton simmering, call .addSkeletonShimmering() on the main view which inherits from OWSkeletonShimmeringView.
 - When you would like to end the shimmering effect, just call .removeSkeletonShimmering() on this view.
 - .removeSkeletonShimmering() function will be called automatically when the view is removed from the UI hierarchy - so in case the whole view purpose is only for showing skeleton shimmering, all you will need to do is to call .addSkeletonShimmering().
 
 - Example:
 fileprivate lazy var mainSkeletonShimmeringView: OWSkeletonShimmeringView = {
         let view = OWSkeletonShimmeringView()

        // Add subviews to this view
         
         return view
 }()

 // Start shimmering effect later on inside the code
 mainSkeletonShimmeringView.addSkeletonShimmering()
 */

class OWSkeletonShimmeringView: UIView, OWSkeletonShimmeringProtocol {
    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSkeletonShimmeringFrame()
    }
    
    deinit {
        // Stop shimmering effect
        self.removeSkeletonShimmering()
    }
}
