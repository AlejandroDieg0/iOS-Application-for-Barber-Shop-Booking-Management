//
//  bottomScrollable.swift
//  sigabrtProject
//
//  Created by Luigi Faticoso on 25/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class bottomScrollable: UIViewController{

    
    @IBOutlet weak var tableView: UITableView!
        
        let fullView: CGFloat = 100
        var partialView: CGFloat {
            return UIScreen.main.bounds.height - 150
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
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
        
        

        
        
        func prepareBackgroundView(){
            let blurEffect = UIBlurEffect.init(style: .dark)
            let visualEffect = UIVisualEffectView.init(effect: blurEffect)
            let bluredView = UIVisualEffectView.init(effect: blurEffect)
            bluredView.contentView.addSubview(visualEffect)
            visualEffect.frame = UIScreen.main.bounds
            bluredView.frame = UIScreen.main.bounds
            view.insertSubview(bluredView, at: 0)
        }
        
        func panGesture(recognizer: UIPanGestureRecognizer) {
            let translation = recognizer.translation(in: self.view)
            let y = self.view.frame.minY
            self.view.frame = CGRect(x: 0,y: y + translation.y,width: view.frame.width,height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            prepareBackgroundView()
            
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "shop")
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
