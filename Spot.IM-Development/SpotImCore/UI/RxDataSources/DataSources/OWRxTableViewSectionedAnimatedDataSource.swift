//
//  OWRxTableViewSectionedAnimatedDataSource.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWRxTableViewSectionedAnimatedDataSource<Section: OWAnimatableSectionModelType>: OWTableViewSectionedDataSource<Section>
    , RxTableViewDataSourceType {
    typealias OWElement = [Section]
    typealias OWDecideViewTransition = (OWTableViewSectionedDataSource<Section>, UITableView, [OWChangeset<Section>]) -> OWViewTransition

    /// Animation configuration for data source
    var animationConfiguration: OWAnimationConfiguration

    /// Calculates view transition depending on type of changes
    var decideViewTransition: OWDecideViewTransition

        init(animationConfiguration: OWAnimationConfiguration = OWAnimationConfiguration(),
                decideViewTransition: @escaping OWDecideViewTransition = { _, _, _ in .animated },
                configureCell: @escaping OWConfigureCell,
                titleForHeaderInSection: @escaping  OWTitleForHeaderInSection = { _, _ in nil },
                titleForFooterInSection: @escaping OWTitleForFooterInSection = { _, _ in nil },
                canEditRowAtIndexPath: @escaping OWCanEditRowAtIndexPath = { _, _ in false },
                canMoveRowAtIndexPath: @escaping OWCanMoveRowAtIndexPath = { _, _ in false },
                sectionIndexTitles: @escaping OWSectionIndexTitles = { _ in nil },
                sectionForSectionIndexTitle: @escaping OWSectionForSectionIndexTitle = { _, _, index in index }
            ) {
            self.animationConfiguration = animationConfiguration
            self.decideViewTransition = decideViewTransition
            super.init(
                configureCell: configureCell,
               titleForHeaderInSection: titleForHeaderInSection,
               titleForFooterInSection: titleForFooterInSection,
               canEditRowAtIndexPath: canEditRowAtIndexPath,
               canMoveRowAtIndexPath: canMoveRowAtIndexPath,
               sectionIndexTitles: sectionIndexTitles,
               sectionForSectionIndexTitle: sectionForSectionIndexTitle
            )
        }

    var dataSet = false

    func tableView(_ tableView: UITableView, observedEvent: Event<OWElement>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
                dataSource._dataSourceBound = true
            #endif
            if !dataSource.dataSet {
                dataSource.dataSet = true
                dataSource.setSections(newSections)
                tableView.reloadData()
            }
            else {
                // if view is not in view hierarchy, performing batch updates will crash the app
                if tableView.window == nil {
                    dataSource.setSections(newSections)
                    tableView.reloadData()
                    return
                }
                let oldSections = dataSource.sectionModels
                do {
                    let differences = try OWDiff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    
                    switch dataSource.decideViewTransition(dataSource, tableView, differences) {
                    case .animated:
                        // each difference must be run in a separate 'performBatchUpdates', otherwise it crashes.
                        // this is a limitation of Diff tool
                        for difference in differences {
                            let updateBlock = {
                                // sections must be set within updateBlock in 'performBatchUpdates'
                                dataSource.setSections(difference.finalSections)
                                tableView.batchUpdates(difference, animationConfiguration: dataSource.animationConfiguration)
                            }
                            if #available(iOS 11, *) {
                                tableView.performBatchUpdates(updateBlock, completion: nil)
                            } else {
                                tableView.beginUpdates()
                                updateBlock()
                                tableView.endUpdates()
                            }
                        }
                        
                    case .reload:
                        dataSource.setSections(newSections)
                        tableView.reloadData()
                        return
                    }
                }
                catch let e {
                    rxDebugFatalError(e)
                    dataSource.setSections(newSections)
                    tableView.reloadData()
                }
            }
        }.on(observedEvent)
    }
}
