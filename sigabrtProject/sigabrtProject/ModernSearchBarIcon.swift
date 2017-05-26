

import UIKit

public class ModernSearchBarIcon : NSObject {
    
    public enum Icon {
        case search
        case none
        
        public var image: UIImage {
            switch self {
            case .none: return UIImage()
            case .search: return getImageFromBundle(name: "search")
            }
        }
        
        private func getImageFromBundle(name: String) -> UIImage {
            let podBundle = Bundle(for: ModernSearchBarIcon.self)
            if let url = podBundle.url(forResource: "ModernSearchBar", withExtension: "bundle") {
                let bundle = Bundle(url: url)
                return UIImage(named: name, in: bundle, compatibleWith: nil)!
            }
            return UIImage()
        }
        
    }
}
