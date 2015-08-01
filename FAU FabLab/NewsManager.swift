import UIKit
import SwiftyJSON
import Foundation.NSURL

typealias NewsLoadFinished = (NSError?) -> Void;

var newsMgr: NewsManager = NewsManager()

struct newsEntry {
    var title: String
    var description: String
    var imageLink: String?
}

class NewsManager: NSObject {

    let resource = "/news";

    var news = [newsEntry]()
    var isLoading = false;
    var newsLoaded = false;

    override init() {
        super.init()
    }

    func getCount() -> Int {
        return news.count;
    }

    func getNews(#onCompletion: NewsLoadFinished) {
        if (!isLoading && !newsLoaded) {
            isLoading = true;

            RestManager.sharedInstance.makeJsonRequest(resource, onCompletion: {
                json, err in
                if (err != nil) {
                    println("ERROR! ", err);
                    onCompletion(err)
                }
                for (index: String, subJson: JSON) in json {
                    //Decode html
                    let htmlText = subJson["description"].string!.dataUsingEncoding(NSUTF8StringEncoding)!
                    let attributedOptions: [String:AnyObject] = [
                            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
                    ]
                    let attributedString = NSAttributedString(data: htmlText, options: attributedOptions, documentAttributes: nil, error: nil)!
                    let decodedString = attributedString.string

                    self.addNews(subJson["title"].string!, desc: decodedString, imageLink: subJson["linkToPreviewImage"].string)
                }
                onCompletion(nil);
                self.isLoading = false;
                self.newsLoaded = true;
            })
        }
    }

    func addNews(title: String, desc: String, imageLink: String?) {
        news.append(newsEntry(title: title, description: desc, imageLink: imageLink))
    }

}

