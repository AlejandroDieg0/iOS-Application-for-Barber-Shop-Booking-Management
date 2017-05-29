

import UIKit
import Nuke
import Firebase

class ShopDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var barber : Shop?
    
    @IBOutlet weak var cvGallery: UICollectionView!
    @IBOutlet weak var imageBarberShop: UIImageView!
    @IBOutlet weak var labelBarberName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    @IBOutlet weak var labelHours: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonFavourite: UIButton!
    
    let reuseIdentifier = "imageCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cvGallery.delegate = self
        cvGallery.dataSource = self
        self.view.addSubview(cvGallery)
        
        labelBarberName.text = barber?.name
        labelDescription.text = barber?.desc
        labelAddress.text = barber?.address
        labelPhone.text = barber?.phone
        
        if barber?.logo != nil { Nuke.loadImage(with: (barber?.logo)!, into: imageBarberShop) }
        
        
        buttonFavourite.setTitle(Funcs.flagFavBarber == 0 ? "Set Favourite!" : "Remove Favourite!", for: .normal)

        // labelHours.text = "Opening Hours: \((barber?.hours[0][0])!/60):00"
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GalleryCollectionViewCell
        
        let imageURL = Storage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("barbers/gallery/\(barber!.ID)/\(indexPath.row).jpg")
        
        imageURL.downloadURL(completion: { (url, error) in
            
            print(imageURL)
            
            if url != nil { Nuke.loadImage(with: url!, into: cell.img) }
            
            
        })

        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondVC = segue.destination as? UserReservationViewController{
            secondVC.selectedShop = barber!
        }
    }
    
    @IBAction func setFavourite(_ sender: Any) {
        if (Funcs.flagFavBarber > -1) {
            buttonFavourite.setTitle("Set Favourite!", for: .normal)
            buttonFavourite.setImage(#imageLiteral(resourceName: "heartnotpress"), for: .normal)
            Funcs.setFavourite(-1)
        } else {
            buttonFavourite.setTitle("Remove Favourite!", for: .normal)
            buttonFavourite.setImage(#imageLiteral(resourceName: "heartpress"), for: .normal)
            Funcs.setFavourite(barber!.ID)
        }
    }
}
