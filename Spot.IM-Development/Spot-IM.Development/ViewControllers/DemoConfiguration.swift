//
//  DemoConfiguration.swift
//  Spot-IM.Development
//
//  Created by Rotem Itzhak on 08/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore

enum DemoAppsIds: String {
    case ynet = "im.spot.ynet"
    case dailyCaller = "im.spot.dailycaller"
    case unknown = "unknown"
}

class DemoConfiguration {
    public let spotId: String
    public private(set) var articles = [Post]()
    public let spotColor: UIColor
    public let spotFontName: String
    
    public static let shared = DemoConfiguration()
    
    private init() {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let bundleIdEnum: DemoAppsIds = DemoAppsIds(rawValue: bundleId) ?? .unknown
        switch bundleIdEnum {
        case .ynet:
            spotFontName = "OpenSansHebrew"
            spotId = "sp_0ZYm1p8e"
            spotColor = UIColor(hexString: "#C82F23")
            let article1 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631046,00.html", title: "התחבורה הציבורית בדרך ללא מוצא: מחסור חמור באוטובוסים ובנהגים", width: 640, height: 360, description: "יותר מ-2,000 אוטובוסים ו-3,000 נהגים חסרים, הרכש תקוע בסבך משפטי ומשרדי התחבורה והאוצר מגלגלים אחריות. בינתיים הפקקים מתארכים והפתרונות מחכים ליישום. יור ארגון נהגי האוטובוסים מזהיר כי הנהגים עובדים יותר והסכנה לתאונות גוברת. תמונת מצב מדאיגה", thumbnailUrl: "https://images.spot.im/v1/production/wjynavkm1tyevqmqdb5t")
            let post1 = Post(spotId: spotId, conversationId: spotId + "_post1", publishedAt: "", extractData: article1)
            
            let article2 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631993,00.html", title: "סערה בוועדת הסל: אם מעשנים מוציאים הון על סיגריות, שיממנו מכיסם הבדיקה", width: 900, height: 551, description: "במהלך דיוני ועדת סל התרופות התעורר ויכוח על האפשרות להכניס בדיקת סקר לגילוי מוקדם של סרטן הריאה, הנפוץ בקרב מעשנים. המתנגדים ציינו כי אם הם מוציאים הון על סיגריות, שייקחו אחריות, ואילו היו כאלו שטענו כי חברי הוועדה לא באים לחנך אף אח", thumbnailUrl: "https://images.spot.im/v1/production/cadedpoandvqhlms12wl")
            let post2 = Post(spotId: spotId, conversationId: spotId + "_post2", publishedAt: "", extractData: article2)
            
            let article3 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5632073,00.html", title: "הרב דרוקמן, אל תגיע להפגנה של נתניהו", width: 640, height: 360, description: "מחאה המגדירה כתב אישום כהפיכה שלטונית היא קריאה להחרבת הבניין בבחינת תמות נפשי עם פלישתים. למה שתלמידיך יישארו שומרי חוק?", thumbnailUrl: "https://images.spot.im/v1/production/kcs11qmxnkljh9hah4se")
            let post3 = Post(spotId: spotId, conversationId: spotId + "_post3", publishedAt: "", extractData: article3)
            
            let article4 = Article(url: "http://www.ynet.co.il/digital/article/rkr00MZK2S", title: "יס פלוס: האם זה העתיד של חברת הלוויין?", width: 490, height: 290, description: "שירות האינטרנט החדש של חברת הלוויין משרטט מסלול ברור לעתיד שבו היא עוברת לשדר דרך הרשת בלבד, וכבדיקת היתכנות טכנולוגית מדובר בהצלחה כבירה. אבל בעידן ה-VOD, האם יש עדיין הצדקה לשידור ליניארי - במיוחד כזה שבו הגול מגיע בדיליי של 40 שניות?", thumbnailUrl: "https://images.spot.im/v1/production/gjli82cv4icvieivdk4e")
            let post4 = Post(spotId: spotId, conversationId: spotId + "_post4", publishedAt: "", extractData: article4)
            
            let article5 = Article(url: "https://www.ynet.co.il/articles/0,7340,L-5631453,00.html", title: "סרטן ריאה עם שינוי בגן ALK: הטיפולים החדשים", width: 640, height: 360, description: "סרטן הריאה הא אחת ממחלות הסרטן הנפוצות. מהו השינוי בגן, איך מאבחנים את המחלה ומהם הטיפולים היעילים? דר סיון שמאי מסבירה", thumbnailUrl: "https://images.spot.im/v1/production/tbbhdcrbhg4geyh3bixd")
            let post5 = Post(spotId: spotId, conversationId: spotId + "_post5", publishedAt: "", extractData: article5)
            
            articles.append(post1)
            articles.append(post2)
            articles.append(post3)
            articles.append(post4)
            articles.append(post5)
        case .dailyCaller:
            spotFontName = "roboto"
            spotId = "sp_E6XN2auy"
            spotColor = UIColor(hexString: "#F42626")
            let article1 = Article(url: "https://dailycaller.com/2019/08/05/he-doesnt-know-how-volatile-this-issue-is-pro-gun-group-responds-to-trump-gun-control/", title: "'He Doesn't Know How Volatile This Issue Is': Pro-Gun Group Responds To Trump Gun Control", width: 4706, height: 3136, description: "A gun rights group warned President Donald Trump Monday not to underestimate the volatile effect proposing gun control legislation could have on his base.", thumbnailUrl: "https://images.spot.im/v1/production/vtbnok9nqxxkpnhz7rru")
            let post1 = Post(spotId: spotId, conversationId: spotId + "_post1", publishedAt: "", extractData: article1)
            
            let article2 = Article(url: "https://dailycaller.com/2019/08/06/takala-google-news/", title: "TAKALA: Think Google Controls The News? It's Worse Than You Think, Experts Say", width: 4400, height: 1889, description: "You're going to have a hard time finding negative information about Google in Axios or the Washington Post", thumbnailUrl: "https://images.spot.im/v1/production/d0aibkn9pyfeza52lz8a")
            let post2 = Post(spotId: spotId, conversationId: spotId + "_post2", publishedAt: "", extractData: article2)
            
            let article3 = Article(url: "https://dailycaller.com/2019/08/09/woke-companies-brands-liberal-50", title: "The Woke Capitalism List: 50 Times Huge Companies Sided With The Social Justice Warriors", width: 3591, height: 2160, description: "Your favorite brands may not share your values.", thumbnailUrl: "https://images.spot.im/v1/production/zxulnck3tsjf77yb5qqe")
            let post3 = Post(spotId: spotId, conversationId: spotId + "_post3", publishedAt: "", extractData: article3)
            
            let article4 = Article(url: "https://dailycaller.com/2019/08/12/trump-trudeau-strange-hand-crafted-notes-conflicted-relationship/", title: "Report: Trump And Trudeau Exchanged Strange Handwritten Notes That Might Define Their Conflicted Relationship", width: 1500, height: 643, description: "President Donald Trump and Canadian Prime Minister Justin Trudeau have exchanged some hand-written correspondence that defy the usual diplomatic exchanges.", thumbnailUrl: "https://images.spot.im/v1/production/xcfai4taf7sxe9wowfcb")
            let post4 = Post(spotId: spotId, conversationId: spotId + "_post4", publishedAt: "", extractData: article4)
            
            let article5 = Article(url: "https://dailycaller.com/2019/08/12/william-barr-jeffrey-epstein-co-conspirators/", title: "William Barr Has A Message For Jeffrey Epstein's Co-Conspirators", width: 4550, height: 3009, description: "William Barr said he was \"appalled\" by Jeffrey Epstein's apparent suicide, but urged that the millionaire pedophile's co-conspirators \"should not rest easy.\"", thumbnailUrl: "https://images.spot.im/v1/production/cohzeb1d4fmvo687hyck")
            let post5 = Post(spotId: spotId, conversationId: spotId + "_post5", publishedAt: "", extractData: article5)
            
            let article6 = Article(url: "https://dailycaller.com/2019/08/21/border-patrol-protects-the-us-on-southern-border/", title: "How The Border Patrol Protects The US On The Southern Border", width: 1920, height: 1080, description: "Agents of the United States Customs and Border Patrol risk their lives on a daily basis to protect the US southern border from illegal migration.", thumbnailUrl: "https://images.spot.im/v1/production/jhh9ttsynu694tfsbjvt")
            let post6 = Post(spotId: spotId, conversationId: spotId + "_post6", publishedAt: "", extractData: article6)
            
            articles.append(post1)
            articles.append(post2)
            articles.append(post3)
            articles.append(post4)
            articles.append(post5)
            articles.append(post6)
        default:
            spotId = ""
            spotColor = .blue
            spotFontName = "roboto"
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
