

import UIKit
import Firebase

class historyViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var currentUser : String!
    var myReservations:Prenotation!
    
    @IBOutlet weak var historyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = Auth.auth().currentUser?.uid
        self.loadHistory()
        // Do any additional setup after loading the view.
    }
    
    func loadHistory(){
        let ref = Database.database().reference().child("prenotations/3/17-06-01").queryEqual(toValue : currentUser, childKey: "user")
        print("sono qui")
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            for snap in snapshot.children {
                print((snap as! DataSnapshot).key)
            }
        })


    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! historyTableViewCell
        cell.servizi.text = "test"
        return cell
    }
}
