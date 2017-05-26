
import UIKit

@objc public protocol ModernSearchBarDelegate: UISearchBarDelegate {
    @objc optional func onClickShadowView(shadowView: UIView)
    @objc optional func onClickItemSuggestionsView(item: String)
    @objc optional func onClickItemWithUrlSuggestionsView(item: ModernSearchBarModel)    
}
