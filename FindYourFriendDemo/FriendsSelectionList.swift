//
//  FriendsSelectionList.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 29/12/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase
class FriendsSelectionList: UITableViewController {

    var users = [User]()
    var databaseRef = FIRDatabase.database().reference()
    let CurrentUserID = FIRAuth.auth()?.currentUser?.uid

    var friendsDic = [NSDictionary?]()
    var friendsDicForCount = [NSDictionary?]()
    var selectedUser = [NSDictionary?]()
    var deneme = [Dictionary<String, Any>]()
    static var friendCounts: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveFriends()
        self.tableView.allowsMultipleSelection = true

        FriendSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsDicForCount.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let friendUser: NSDictionary?
        friendUser = friendsDic[indexPath.row]
        // Checkmark ile işaretleme
        if cell!.isSelected {
            cell!.isSelected = false
            if cell!.accessoryType == UITableViewCellAccessoryType.none {
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        // Tıklanan cell'de checkmark kontrolü
        if cell!.accessoryType == UITableViewCellAccessoryType.checkmark {
            // Seçili kullanıcı bilgileri
            let named = friendUser?["name"] as! String
            let urlImg = friendUser?["profileImageUrl"] as? String
            let id = friendUser?["id"] as! String
            let email = friendUser?["email"] as! String
            let dicc: [String: String?] = ["name": named, "email": email, "id": id, "profileImageUrl": urlImg]
            
            // Seçilen kullanıcıyı harita göstermesi için array'e eklendiği anda kullanıcının mevcut konumu haritada göstermesini tetikleyen komut
            databaseRef.child("selectedfriends").child(id).child(CurrentUserID!).setValue(true)
            
            //eğer checkmark varsa kullanıcı bilgisini array'ye ekle
            selectedUser.append(dicc as NSDictionary?)
            
            // eklenen kullanıcı bilgisi, kullanılmak üzere MapPage'e gonderilir.
            MapPage.selectedUsersInfo = selectedUser as! [NSDictionary]
            
            // eklenen kullanıcıları göster
            print("********CheckMark**********")
            print(selectedUser)
            print("********CheckMark**********")
            print("Eklenen : \(id)")

        }
    
        // Eğer checkmark yoksa dictionary'lerden olusan array'den çıkarma
        if cell!.accessoryType == UITableViewCellAccessoryType.none {
            
            //seçili kullanıcı id'si
            let id = friendUser?["id"] as! String
            
            // kullanıcıdan checkmark kaldırıldığında haritadan kaybolur.
            databaseRef.child("selectedfriends").child(id).child(CurrentUserID!).removeValue() //.setValue(false)
            
            //Kullanıcıyı çıkarmak için
            var i = 0
            for arr in selectedUser {
                for (key,val) in arr! {
                    if key as! String == "id" && "\(val)" == id {
                        selectedUser.remove(at: i)
                    }
                }
                i += 1
            }
            // Kullanıcı dictionary'den çıkarıldıktan sonraki hali MapPage'e gönderilir.
            MapPage.selectedUsersInfo = selectedUser as! [NSDictionary]
            print("Çıktıktan sonraki hali")
            print(MapPage.selectedUsersInfo)
            print("Çıktıktan sonraki hali")
            // MapPage'deki timer ile 5 saniyede bir mevcut kullanici dictionary degerlerini goster. // kullanici Eklenmis ya da cikarilmis olabilir
            
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Popover'da gösterilecek kullanıcı bilgileri (resim, isim).
        let friendUser: NSDictionary?
        friendUser = friendsDic[indexPath.row]
        
        cell.textLabel?.text = friendUser?["name"] as? String
        cell.textLabel?.textColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        
        cell.imageView?.image = UIImage(named: "emptyPhoto1.png")
        cell.imageView?.tintColor = UIColor.init(red: 255/255, green: 254/255, blue: 220/255, alpha: 1.0)
        cell.imageView?.layer.cornerRadius = 19
        cell.imageView?.clipsToBounds = true

        if friendUser?["profileImageUrl"] as? String != nil {
            cell.imageView?.loadImagesUsingCacheWithUrlString(urlString: friendUser?["profileImageUrl"] as! String)
        }

        return cell
        
    }
    
    func retrieveFriends() {
        
        // Kullanıcının arkadaş bilgileri popover'da gösterebilmek için çağırılır ve
        let id = FIRAuth.auth()?.currentUser?.uid
        databaseRef.child("users").child(id!).child("friends").observe(.value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: Any] {
                for (key, val) in dictionary {
                    self.databaseRef.child("users").child("\(key)").observe(.value, with: { (snapshot) in
                        let snap = snapshot.value as? NSDictionary
                        
                        let name = snap?["name"] as! String
                        let email = snap?["email"] as! String
                        let profileImageUrl = snap?["profileImageUrl"] as? String
                        
                        let idDic = ["id": "\(key)", "name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        // Bütün arkadaş bilgileri friendsDic'e gönderilir.
                        self.friendsDic.append(idDic as NSDictionary)
                        // Kullanıcının arkadaş sayısını gösterebilmek için oluşturulmuş dictionary
                        self.friendsDicForCount.append(dictionary as NSDictionary?)
                        
                        dictionary.removeAll()
                    })
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
