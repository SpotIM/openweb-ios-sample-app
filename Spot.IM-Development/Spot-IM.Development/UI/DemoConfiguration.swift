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
    case focus = "im.spot.focus"
    case marketWatch = "im.spot.market.watch"
    case aol = "im.spot.aol"
    case express = "im.spot.express"
    case skySports = "im.spot.sky.sports"
    case unknown = "unknown"
}

class DemoConfiguration {
    public let spotId: String
    public private(set) var articles = [Post]()
    public let spotColor: UIColor
    public let spotFontName: String

    public static let shared = DemoConfiguration()

    // swiftlint:disable line_length
    // swiftlint:disable function_body_length
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
        case .focus:
            spotId = "sp_E6XN2auy"
            spotFontName = "roboto"
            spotColor = UIColor(hexString: "#c4291e")

            let article1 = Article(url: "https://www.focus.de/finanzen/boerse/aktien/geheimverhandlungen-mit-der-stadt-bis-zu-600-millionen-teuer-siemens-plant-in-berlin-ein-innovationszentrum_id_11460880.html", title: "Siemens plant jetzt in Berlin größtes Investitions-Projekt der Firmengeschichte", width: 1200, height: 627, description: "Der Siemens-Konzern hat Großes vor in Berlin: Das Unternehmen plant einen Innovationscampus in der Bundeshauptstadt. Es handelt sich um das größte Investitions-Projekt der Firmengeschichte.", thumbnailUrl: "https://images.spot.im/v1/production/dlvhu70zxg2lm1ku54hg")

            let post1 = Post(spotId: spotId, conversationId: spotId + "_focus1", publishedAt: "", extractData: article1)
            articles.append(post1)

        case .marketWatch:
            spotId = "sp_E6XN2auy"
            spotFontName = "roboto"
            spotColor = .darkGray

            let article1 = Article(url: "https://www.marketwatch.com/story/stock-futures-point-to-higher-start-buoyed-by-preliminary-us-china-trade-deal-2019-12-16",
                                   title: "Stock futures point to higher start, buoyed by preliminary U.S.-China trade deal",
                                   width: 742,
                                   height: 1320,
                                   description: "Stock-index futures point higher Monday, with the upbeat tone tied to a preliminary U.S.-China trade deal, though questions remain over the details of the...",
                                   thumbnailUrl: "https://images.spot.im/v1/production/c7q7zt1rerql6mokdspw")
            let post1 = Post(spotId: spotId,
                             conversationId: spotId + "_marketwatch1",
                             publishedAt: "",
                             extractData: article1)

            let article2 = Article(url: "https://www.marketwatch.com/story/best-investments-for-2020-and-the-next-decade-according-to-a-top-us-financial-advisor-2019-12-16",
                                   title: "Best investments for 2020 and the next decade, according to a top U.S. financial advisor",
                                   width: 742,
                                   height: 1320,
                                   description: "Double-digit percentage gains for stock markets aren’t just limited to the U.S., with Europe and parts of emerging and Asian markets also having enjoyed a...",
                                   thumbnailUrl: "https://images.spot.im/v1/production/ppp9zm2b0ayut6rvzx7w")
            let post2 = Post(spotId: spotId,
                             conversationId: spotId + "_marketwatch2",
                             publishedAt: "",
                             extractData: article2)

            let article3 = Article(url: "https://www.marketwatch.com/story/how-to-get-disney-apple-tv-amazon-prime-video-or-netflix-for-free-and-what-to-know-before-you-sign-up-2019-12-16",
                                   title: "How to get Disney+, Apple TV+, Amazon Prime Video or Netflix for ‘free’ — and what to know before you sign up",
                                   width: 742,
                                   height: 1320,
                                   description: "Your cellphone plan or new TV could come with discounted or free video streaming.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/wfcgwamjlnlx1jqqppja")
            let post3 = Post(spotId: spotId,
                             conversationId: spotId + "_marketwatch3",
                             publishedAt: "",
                             extractData: article3)

            let article4 = Article(url: "https://www.marketwatch.com/story/the-hottest-housing-markets-of-2020-are-far-from-the-coasts-2019-12-12",
                                   title: "The hottest housing markets of 2020 are far from the coasts",
                                   width: 742,
                                   height: 1320,
                                   description: "Home buyers next year are expected to flock to smaller, more affordable cities, according to Realtor.com.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/hatkbq0dconrueby81x8")
            let post4 = Post(spotId: spotId,
                             conversationId: spotId + "_marketwatch4",
                             publishedAt: "",
                             extractData: article4)

            let article5 = Article(url: "https://www.marketwatch.com/story/heres-proof-that-401k-plans-are-not-working-for-most-americans-can-you-guess-who-they-are-working-for-2019-12-12",
                                   title: "Here’s proof that 401(k) plans are not working for most Americans — can you guess who they ARE working for?",
                                   width: 742,
                                   height: 1320,
                                   description: "The country’s in the midst of a savings crisis as families use every penny to cover rising home costs, nosebleed student loan debt and everything in between....",
                                   thumbnailUrl: "https://images.spot.im/v1/production/kwvdihmuoxo8lqxmq9yu")
            let post5 = Post(spotId: spotId,
                             conversationId: spotId + "_marketwatch5",
                             publishedAt: "",
                             extractData: article5)

            articles.append(post1)
            articles.append(post2)
            articles.append(post3)
            articles.append(post4)
            articles.append(post5)

        case .aol:
            spotId = "sp_E6XN2auy"
            spotFontName = "roboto"
            spotColor = UIColor(hexString: "#3399ff")

            let article1 = Article(url: "https://www.aol.com/article/news/2020/03/07/chinese-hotel-used-to-observe-virus-contacts-collapses/23943274/",
                                   title: "Hotel used for coronavirus quarantine falls in China",
                                   width: 742,
                                   height: 1320,
                                   description: "Dozens of people are trapped after a hotel being used as a coronavirus quarantine facility in eastern China falls.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/mieunoa91a4cnof67oyy")
            let post1 = Post(spotId: spotId,
                             conversationId: spotId + "_aol1",
                             publishedAt: "",
                             extractData: article1)

            let article2 = Article(url: "https://www.aol.com/article/lifestyle/2020/03/07/meghan-markle-and-prince-harry-hold-hands-receive-standing-ovation-at-british-music-festival/23943413/",
                                   title: "Meghan Markle and Prince Harry hold hands, receive 'standing ovation' at British music festival",
                                   width: 742,
                                   height: 1320,
                                   description: "Megan Markle and Prince Harry are one-upping their iconic “rain photo” this week by holding hands at a London music festival.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/rhed1l87ugmjrycjcbgx")
            let post2 = Post(spotId: spotId,
                             conversationId: spotId + "_aol2",
                             publishedAt: "",
                             extractData: article2)

            let article3 = Article(url: "https://www.aol.com/article/news/2020/03/07/new-york-gov-andrew-cuomo-declares-a-state-of-emergency-and-confirms-76-cases-of-coronavirus-in-the-state/23943266/",
                                   title: "New York Gov. Andrew Cuomo declares a state of emergency",
                                   width: 742,
                                   height: 1320,
                                   description: "New York Gov. Andrew Cuomo declared a state of emergency on Saturday as the number of novel coronavirus cases surge across the US.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/rcpmwkag8lfnygp9bfuu")
            let post3 = Post(spotId: spotId,
                             conversationId: spotId + "_aol3",
                             publishedAt: "",
                             extractData: article3)

            let article4 = Article(url: "https://www.aol.com/article/news/2020/03/07/us-sending-military-police-to-two-border-crossings/23943306/",
                                   title: "U.S. sending military police to two border crossings",
                                   width: 742,
                                   height: 1320,
                                   description: "The U.S. government says it is sending 160 military police and engineers to two official border crossings to deal with asylum seekers.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/hatkbq0dconrueby81x8")
            let post4 = Post(spotId: spotId,
                             conversationId: spotId + "_aol4",
                             publishedAt: "",
                             extractData: article4)

            let article5 = Article(url: "https://www.aol.com/article/lifestyle/2020/03/07/how-gyms-yoga-studios-responding-coronavirus/23943225/",
                                   title: "How gyms and yoga studios are responding to coronavirus",
                                   width: 742,
                                   height: 1320,
                                   description: "With mounting concerns of a coronavirus outbreak preying on Americans’ minds the industry is looking to reassure gym-goers and step up standards.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/busxtxfegpqqz1rtxant")
            let post5 = Post(spotId: spotId,
                             conversationId: spotId + "_aol5",
                             publishedAt: "",
                             extractData: article5)

            articles.append(post1)
            articles.append(post2)
            articles.append(post3)
            articles.append(post4)
            articles.append(post5)

        case .express:
            spotId = "sp_E6XN2auy"
            spotFontName = "roboto"
            spotColor = UIColor(hexString: "#bb1a00")

            let article1 = Article(url: "https://www.express.co.uk/news/politics/1252244/boris-johnson-nigel-farage-jeremy-corbyn-brexit-news-uk-flooding",
                                   title: "I agree with Jeremy! Boris Johnson is NOT the leader Britain deserves, says NIGEL FARAGE",
                                   width: 742,
                                   height: 1320,
                                   description: "IN TIMES of trouble, leaders must lead. But doubts are growing in my mind when it comes to Boris Johnson's ability to steer the nation through tricky waters.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/gczghtu8idrruhgex00u")
            let post1 = Post(spotId: spotId,
                             conversationId: spotId + "_express1",
                             publishedAt: "",
                             extractData: article1)

            let article2 = Article(url: "https://www.express.co.uk/news/uk/1252331/coronavirus-latest-news-UK-coronavirus-outbreak-italy-lockdown-coronavirus",
                                   title: "Coronavirus map LIVE: Italians FLEE red zone seconds before lockdown begin - VIDEO",
                                   width: 742,
                                   height: 1320,
                                   description: "ITALIANS desperate to escape the coronavirus outbreak in the north of the country were filmed racing towards trains last night, just hours before a huge lockdown began.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/itnsndwdw05bqgsxl1wg")
            let post2 = Post(spotId: spotId,
                             conversationId: spotId + "_express2",
                             publishedAt: "",
                             extractData: article2)

            let article3 = Article(url: "https://www.express.co.uk/news/uk/1251533/eu-news-fisheries-panic-fear-death-loss-uk-waters-brexit-talks-france-spt",
                                   title: "EU fisheries panic: French fishermen 'fear death' over loss of UK waters in Brexit talks",
                                   width: 742,
                                   height: 1320,
                                   description: "THE EUROPEAN UNION is demanding access to British waters in Brexit talks - but as Boris Johnson holds firm, French fishermen are fearing the worst.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/gr0tpmkdr1bxl04ffcl6")
            let post3 = Post(spotId: spotId,
                             conversationId: spotId + "_express3",
                             publishedAt: "",
                             extractData: article3)

            let article4 = Article(url: "https://www.express.co.uk/news/royal/1252321/Meghan-Markle-Duchess-of-Sussex-Prince-Harry-Royal-Family-Dagenham-school-speech-news",
                                   title: "Meghan Markle SNUB: Did Duchess hit back at Royal Family in first speech since split?",
                                   width: 742,
                                   height: 1320,
                                   description: "MEGHAN MARKLE may have been sending a message to the Royal Family as she stood up on a stage and urged schoolchildren in Dagenham to ‘stand up for your rights' on Saturday.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/vhnptz1fogonohtnzrlw")
            let post4 = Post(spotId: spotId,
                             conversationId: spotId + "_express4",
                             publishedAt: "",
                             extractData: article4)

            let article5 = Article(url: "https://www.express.co.uk/news/politics/1251870/brexit-news-fishing-boris-johnson-uk-eu-trade-deal-latest-conservative-party-majority",
                                   title: "Fishing FURY: Boris issued dire warning over Brexit gamble - ‘It would ENRAGE public’",
                                   width: 742,
                                   height: 1320,
                                   description: "BORIS JOHNSON has been warned British voters will turn on him if he sacrifices UK fishing for a favourable post-Brexit trade deal with the European Union.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/u0xqndj818lkbtk2a2tz")
            let post5 = Post(spotId: spotId,
                             conversationId: spotId + "_express5",
                             publishedAt: "",
                             extractData: article5)

            articles.append(post1)
            articles.append(post2)
            articles.append(post3)
            articles.append(post4)
            articles.append(post5)

        case .skySports:
            spotId = "sp_E6XN2auy"
            spotFontName = "roboto"
            spotColor = UIColor(hexString: "#307FE2")

            let article1 = Article(url: "https://www.skysports.com/football/news/11938/11951093/west-ham-boss-david-moyes-wants-league-cup-replaced-with-british-cup",
                                   title: "West Ham boss David Moyes wants League Cup replaced with British Cup",
                                   width: 742,
                                   height: 1320,
                                   description: "West Ham manager David Moyes has proposed a British Cup following calls from UEFA president Aleksander Ceferin to scrap the League Cup.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/htmbktmgihczs1qqnex6")
            let post1 = Post(spotId: spotId,
                             conversationId: spotId + "_skysports1",
                             publishedAt: "",
                             extractData: article1)

            let article2 = Article(url: "https://www.skysports.com/football/news/11667/11951099/manchester-united-is-ole-gunnar-solskjaer-close-to-success",
                                   title: "Manchester United: Is Ole Gunnar Solskjaer close to success?",
                                   width: 742,
                                   height: 1320,
                                   description: "There's an old joke about the lower league manager who insists his team are only two players away from challenging for honours - Lionel Messi and Cristiano Ronaldo.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/j4uhtg8ivhazywjvriq6")
            let post2 = Post(spotId: spotId,
                             conversationId: spotId + "_skysports2",
                             publishedAt: "",
                             extractData: article2)

            let article3 = Article(url: "https://www.skysports.com/football/news/11668/11949449/frank-lampard-deserves-more-credit-for-work-at-chelsea",
                                   title: "Frank Lampard deserves more credit for work at Chelsea",
                                   width: 742,
                                   height: 1320,
                                   description: "Frank Lampard's reunion with Carlo Ancelotti on Super Sunday will stir memories of Chelsea's glorious past. The pair won a Premier League and FA Cup double together at Stamford Bridge in 2010, bringing more success to a club which was becoming accustomed to it.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/n5ygeh1foikdlo8yqzpj")
            let post3 = Post(spotId: spotId,
                             conversationId: spotId + "_skysports3",
                             publishedAt: "",
                             extractData: article3)

            let article4 = Article(url: "https://www.skysports.com/football/news/11095/11949768/bruno-fernandes-personality-and-fire-convinced-me-to-sign-him-for-man-utd-says-ole-gunnar-solskjaer",
                                   title: "Bruno Fernandes' 'personality and fire' convinced me to sign him for Man Utd, says Ole Gunnar Solskjaer",
                                   width: 742,
                                   height: 1320,
                                   description: "Manchester United manager Ole Gunnar Solskjaer has revealed how a scouting trip to Portugal to scout Bruno Fernandes ultimately convinced him to bring him to Old Trafford.",
                                   thumbnailUrl: "https://images.spot.im/v1/production/n8baitmgarsdok6ktfwt")
            let post4 = Post(spotId: spotId,
                             conversationId: spotId + "_skysports4",
                             publishedAt: "",
                             extractData: article4)

            let article5 = Article(url: "https://www.skysports.com/football/news/11095/11947875/ref-watch-should-evertons-manchester-united-winner-have-stood",
                                   title: "Ref Watch: Should Everton's Manchester United 'winner' have stood?",
                                   width: 742,
                                   height: 1320,
                                   description: "Why did Dominic Calvert-Lewin's Everton winner get ruled out? Why did no one spot a big mistake in the Carabao Cup final? As always, Dermot Gallagher is here with the answers...",
                                   thumbnailUrl: "https://images.spot.im/v1/production/w5raxf6gu72bwhwx93wu")
            let post5 = Post(spotId: spotId,
                             conversationId: spotId + "_skysports5",
                             publishedAt: "",
                             extractData: article5)

            articles.append(post1)
            articles.append(post2)
            articles.append(post3)
            articles.append(post4)
            articles.append(post5)
        default:
            spotId = ""
            spotColor = .blue
            spotFontName = "roboto"
        }
    }
    // swiftlint:enable function_body_lenght
    // swiftlint:enable line_lenght
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
