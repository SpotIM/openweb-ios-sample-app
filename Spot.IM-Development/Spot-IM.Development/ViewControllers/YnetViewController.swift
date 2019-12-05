//
//  File.swift
//  YentSpot
//
//  Created by Rotem Itzhak on 26/11/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore
import UIKit

class YnetArticlesList: UITableViewController {
    let spotId : String = "sp_0ZYm1p8e"
    var data : [Post] = []
    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    
    init() {
        super.init(style: .plain)

        let article1 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631046,00.html", title: "התחבורה הציבורית בדרך ללא מוצא: מחסור חמור באוטובוסים ובנהגים", width: 640, height: 360, description: "יותר מ-2,000 אוטובוסים ו-3,000 נהגים חסרים, הרכש תקוע בסבך משפטי ומשרדי התחבורה והאוצר מגלגלים אחריות. בינתיים הפקקים מתארכים והפתרונות מחכים ליישום. יור ארגון נהגי האוטובוסים מזהיר כי הנהגים עובדים יותר והסכנה לתאונות גוברת. תמונת מצב מדאיגה", thumbnailUrl: "https://images.spot.im/v1/production/wjynavkm1tyevqmqdb5t")
        let post1 = Post(spotId: spotId, conversationId: spotId + "post1", publishedAt: "", extractData: article1)
        
        let article2 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631993,00.html", title: "סערה בוועדת הסל: אם מעשנים מוציאים הון על סיגריות, שיממנו מכיסם הבדיקה", width: 900, height: 551, description: "במהלך דיוני ועדת סל התרופות התעורר ויכוח על האפשרות להכניס בדיקת סקר לגילוי מוקדם של סרטן הריאה, הנפוץ בקרב מעשנים. המתנגדים ציינו כי אם הם מוציאים הון על סיגריות, שייקחו אחריות, ואילו היו כאלו שטענו כי חברי הוועדה לא באים לחנך אף אח", thumbnailUrl: "https://images.spot.im/v1/production/cadedpoandvqhlms12wl")
        let post2 = Post(spotId: spotId, conversationId: spotId + "post2", publishedAt: "", extractData: article2)
        
        let article3 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5632073,00.html", title: "הרב דרוקמן, אל תגיע להפגנה של נתניהו", width: 640, height: 360, description: "מחאה המגדירה כתב אישום כהפיכה שלטונית היא קריאה להחרבת הבניין בבחינת תמות נפשי עם פלישתים. למה שתלמידיך יישארו שומרי חוק?", thumbnailUrl: "https://images.spot.im/v1/production/kcs11qmxnkljh9hah4se")
        let post3 = Post(spotId: spotId, conversationId: spotId + "post3", publishedAt: "", extractData: article3)
        
        let article4 = Article(url: "http://www.ynet.co.il/digital/article/rkr00MZK2S", title: "יס פלוס: האם זה העתיד של חברת הלוויין?", width: 490, height: 290, description: "שירות האינטרנט החדש של חברת הלוויין משרטט מסלול ברור לעתיד שבו היא עוברת לשדר דרך הרשת בלבד, וכבדיקת היתכנות טכנולוגית מדובר בהצלחה כבירה. אבל בעידן ה-VOD, האם יש עדיין הצדקה לשידור ליניארי - במיוחד כזה שבו הגול מגיע בדיליי של 40 שניות?", thumbnailUrl: "https://images.spot.im/v1/production/gjli82cv4icvieivdk4e")
        let post4 = Post(spotId: spotId, conversationId: spotId + "post4", publishedAt: "", extractData: article4)
        
        let article5 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631453,00.html", title: "סרטן ריאה עם שינוי בגן ALK: הטיפולים החדשים", width: 640, height: 360, description: "סרטן הריאה הא אחת ממחלות הסרטן הנפוצות. מהו השינוי בגן, איך מאבחנים את המחלה ומהם הטיפולים היעילים? דר סיון שמאי מסבירה", thumbnailUrl: "https://images.spot.im/v1/production/tbbhdcrbhg4geyh3bixd")
        let post5 = Post(spotId: spotId, conversationId: spotId + "post5", publishedAt: "", extractData: article5)
        
        data.append(post1)
        data.append(post2)
        data.append(post3)
        data.append(post4)
        data.append(post5)
    }
    
    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)

        navigationController?.navigationBar.backgroundColor = UIColor.red
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let article1 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631046,00.html", title: "התחבורה הציבורית בדרך ללא מוצא: מחסור חמור באוטובוסים ובנהגים", width: 640, height: 360, description: "יותר מ-2,000 אוטובוסים ו-3,000 נהגים חסרים, הרכש תקוע בסבך משפטי ומשרדי התחבורה והאוצר מגלגלים אחריות. בינתיים הפקקים מתארכים והפתרונות מחכים ליישום. יור ארגון נהגי האוטובוסים מזהיר כי הנהגים עובדים יותר והסכנה לתאונות גוברת. תמונת מצב מדאיגה", thumbnailUrl: "https://images.spot.im/v1/production/wjynavkm1tyevqmqdb5t")
        let post1 = Post(spotId: spotId, conversationId: spotId + "_post1", publishedAt: "", extractData: article1)
        
        let article2 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631993,00.html", title: "סערה בוועדת הסל: אם מעשנים מוציאים הון על סיגריות, שיממנו מכיסם הבדיקה", width: 900, height: 551, description: "במהלך דיוני ועדת סל התרופות התעורר ויכוח על האפשרות להכניס בדיקת סקר לגילוי מוקדם של סרטן הריאה, הנפוץ בקרב מעשנים. המתנגדים ציינו כי אם הם מוציאים הון על סיגריות, שייקחו אחריות, ואילו היו כאלו שטענו כי חברי הוועדה לא באים לחנך אף אח", thumbnailUrl: "https://images.spot.im/v1/production/cadedpoandvqhlms12wl")
        let post2 = Post(spotId: spotId, conversationId: spotId + "_post2", publishedAt: "", extractData: article2)
        
        let article3 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5632073,00.html", title: "הרב דרוקמן, אל תגיע להפגנה של נתניהו", width: 640, height: 360, description: "מחאה המגדירה כתב אישום כהפיכה שלטונית היא קריאה להחרבת הבניין בבחינת תמות נפשי עם פלישתים. למה שתלמידיך יישארו שומרי חוק?", thumbnailUrl: "https://images.spot.im/v1/production/kcs11qmxnkljh9hah4se")
        let post3 = Post(spotId: spotId, conversationId: spotId + "_post3", publishedAt: "", extractData: article3)
        
        let article4 = Article(url: "http://www.ynet.co.il/digital/article/rkr00MZK2S", title: "יס פלוס: האם זה העתיד של חברת הלוויין?", width: 490, height: 290, description: "שירות האינטרנט החדש של חברת הלוויין משרטט מסלול ברור לעתיד שבו היא עוברת לשדר דרך הרשת בלבד, וכבדיקת היתכנות טכנולוגית מדובר בהצלחה כבירה. אבל בעידן ה-VOD, האם יש עדיין הצדקה לשידור ליניארי - במיוחד כזה שבו הגול מגיע בדיליי של 40 שניות?", thumbnailUrl: "https://images.spot.im/v1/production/gjli82cv4icvieivdk4e")
        let post4 = Post(spotId: spotId, conversationId: spotId + "_post4", publishedAt: "", extractData: article4)
        
        let article5 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631453,00.html", title: "סרטן ריאה עם שינוי בגן ALK: הטיפולים החדשים", width: 640, height: 360, description: "סרטן הריאה הא אחת ממחלות הסרטן הנפוצות. מהו השינוי בגן, איך מאבחנים את המחלה ומהם הטיפולים היעילים? דר סיון שמאי מסבירה", thumbnailUrl: "https://images.spot.im/v1/production/tbbhdcrbhg4geyh3bixd")
        let post5 = Post(spotId: spotId, conversationId: spotId + "_post5" + String(Int.random(in: 0 ..< 1000)), publishedAt: "", extractData: article5)
        
        data.append(post1)
        data.append(post2)
        data.append(post3)
        data.append(post4)
        data.append(post5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spotIMCoordinator = SpotImSDKFlowCoordinator(delegate: self)

        SPClientSettings.main.setup(spotKey: spotId)
        setup()
        setupNavigationBar()
        
        title = "Articles"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? ArticleTableViewCell else {
                                                        return UITableViewCell()
        }
        
        let item = data[indexPath.item]
        
        cell.post = item
        cell.delegate = self

        return cell
    }
}

extension YnetArticlesList : ArticleTableViewCellDelegate {
    func articleCellTapped(cell: ArticleTableViewCell, withPost post: Post?) {
        guard let post = post, let postId = postId(post: post) else { return }
        
        let articleViewController = ArticleWebViewController(spotId: spotId, postId:postId, url: post.extractData.url, authenticationControllerId: "")
        spotIMCoordinator?.setLayoutDelegate(delegate: articleViewController)
        articleViewController.spotIMCoordinator = spotIMCoordinator
        self.navigationController?.pushViewController(articleViewController, animated: true)
    }
}

extension YnetArticlesList {
    
    @objc
    func reloadData() {
        self.tableView.reloadData()
    }
    
    private func postId(post: Post?) -> String? {
        guard let post = post else { return nil }
        
        return post.conversationId.replacingOccurrences(of: "\(post.spotId)_", with: "")
    }
}

extension YnetArticlesList {
    func setup() {
        self.setupTableView()
    }
    
    func setupTableView() {
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        setupRefresh()
    }
    
    func setupRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refresh
    }
}

extension YnetArticlesList: SpotImSDKNavigationDelegate {

    func controllerForSSOFlow() -> UIViewController & SSOAuthenticatable {
        let storyboard = UIStoryboard(name: "Ynet", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "YnetAuthVC")
        return controller as! UIViewController & SSOAuthenticatable
    }

}
