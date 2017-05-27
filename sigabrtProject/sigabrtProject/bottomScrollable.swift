
import UIKit

class bottomScrollable: UIViewController{


    @IBOutlet weak var tableView: UITableView!
        let map = MapViewController()
        let fullView: CGFloat = 150
        var partialView: CGFloat {
            return UIScreen.main.bounds.height - 115
        }

        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            print(UIScreen.main.bounds.height)
            UIView.animate(withDuration: 0.6, animations: { [weak self] in
                let frame = self?.view.frame
                let yComponent = self?.partialView
                self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height - 100)
            })
        }
    

    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        

        
        
//        func prepareBackgroundView(){
//            let blurEffect = UIBlurEffect.init(style: .dark)
//            let visualEffect = UIVisualEffectView.init(effect: blurEffect)
//            let bluredView = UIVisualEffectView.init(effect: blurEffect)
//            bluredView.contentView.addSubview(visualEffect)
//            visualEffect.frame = UIScreen.main.bounds
//            bluredView.frame = UIScreen.main.bounds
//            view.insertSubview(bluredView, at: 0)
//        }
    
    func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
//                    self.map.zoomMap()
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                }
                
            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
                    self?.tableView.isScrollEnabled = true
                }
            })
        }
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
//            prepareBackgroundView()
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "DefaultTableViewCell", bundle: nil), forCellReuseIdentifier: "default")
            
            let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(bottomScrollable.panGesture))
            gesture.delegate = self
            view.addGestureRecognizer(gesture)
        }
    

}

extension bottomScrollable: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shop", for: indexPath) as! nearShop
        cell.shopName.text = "prova"
        cell.distance.text = "7.8km"
        cell.imgShop.image = #imageLiteral(resourceName: "barbe")
        return cell
    }
}

extension bottomScrollable: UIGestureRecognizerDelegate {
  
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        
        return false
}
}
