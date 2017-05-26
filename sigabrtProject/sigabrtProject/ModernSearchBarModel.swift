
import UIKit

public class ModernSearchBarModel: NSObject {
    
    public var title: String!
    public var url: URL!
    public var imgCache: UIImage!
    
    public init(title: String, url: URL) {
        super.init()
        self.title = title
        self.url = url
    }
    public init(title: String, link: String) {
        super.init()
        self.title = title
        if let newUrl = URL(string: link) {
            self.url = newUrl
        } else {
            print("ModernSearchBarModel: Seems url is not valid...")
            self.url = URL(string: "#")
        }
    }
    public init(title: String, image: UIImage) {
        super.init()
        self.title = title
        self.imgCache = image
    }

}
