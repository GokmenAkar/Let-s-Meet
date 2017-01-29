//
//  MapPage.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 09/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class MapPage: UIViewController, CLLocationManagerDelegate, UITabBarControllerDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //
    
    @IBOutlet weak var mapView: MKMapView!
    
    var profilePageController: ProfilePage?
    
    var image = UIImage()

    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var annotationViewww: MKAnnotationView?

    var ref = FIRDatabase.database().reference()
    let userID = FIRAuth.auth()?.currentUser?.uid

    static var selectedUsersInfo = [NSDictionary?]()
    static var userProfileUrl: String!
    var dic = [String]()
    
    var timer : Timer!
    var timerr : Timer!
    var counter = 0 

    var customPoint = MKPointAnnotation()
    var pressedPinIcon: MKAnnotationView! = nil

    var annotation = MKPointAnnotation()
    var annotationLat = CLLocationDegrees()
    var annotationLong = CLLocationDegrees()
    let request = MKDirectionsRequest()
    var polylines: [MKPolyline]?
    var mkroute: [MKRoute]?
    
    var amISelected = false
    
    let uyari = "*********************************"

    // -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if userID == nil {
            print("kullanici yok")
        } else {
            print("\(userID!)")
        }
        mapView.showsTraffic = false
        mapView.delegate = self
        
        self.locationManager?.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()
        }
        let lat = self.locationManager?.location?.coordinate.latitude
        let long = self.locationManager?.location?.coordinate.longitude
       
        if lat == nil && long == nil {
            
        } else {
            self.screenZoom(lat: lat!, long: long!)
            
        }
        observeLocations()
        
//        dic.append("\(self.locationManager!.location!.coordinate.latitude)")
        
        self.badgeCountForRequest()
        
        _ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { timer in
            self.justForFriendUserDirection()
        })
        // (I) Mevcut kullanici bilgileri Firebase'e gonderilir
        // (II) amISelected() Eger mevcut kullanici karsidaki kullaniciyi tableview'de secmisse, karsidaki kullanicida mevcut kullanicinin yerini belirt.
        // (III) Secili kullanicilar harita'ya eklenir
        // (IV) Kullanici lokasyonu etrafindaki yuvarlak
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.observeLocations()
            self.amIselectedFunc()
            self.lokasyonDagit()
            // self.circleFunc()
        }
        // Status bar icin koyu arkaplan.
        customizeAppearance()
    }
    // -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func customizeAppearance() {
                let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
                view.backgroundColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0)
                self.view.addSubview(view)
    }
    
    func pinEkle(_ name:String, lat:CLLocationDegrees, long:CLLocationDegrees) {
        
        let point = MKPointAnnotation()
        
        point.coordinate = CLLocationCoordinate2DMake(lat, long)
        point.title = name

        mapView.addAnnotation(point)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.mapView.removeAnnotation(point)
        })
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MyAnnotationView?

        let size = CGSize(width: 27, height: 27)
        let sizePin = CGSize(width: 46, height: 46)
        
        // Mevcut lokasyonu gosteren mavi pin yerine kullanici resmi atandi
        if annotation is MKUserLocation {
            let annotationIdentifier = "UserLocation"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MyAnnotationView
            
            if annotationView == nil {
                annotationView = MyAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                if userID == nil {
                    print("userID yok")
                    annotationView?.image = UIImage(named: "emptyPhoto1.png")?.resized(to: size)
                    
                } else {
                ref.child("users").child(userID!).observe(.value, with: { (snapshot) in
                let snap = snapshot.value as? [String: Any]
                let profileImageUrl = snap?["profileImageUrl"] as? String
                    
                    if profileImageUrl != nil {
                        let imageUrl = URL(string: profileImageUrl!)
                        annotationView?.image = try! UIImage.init(withContentsOfUrl: imageUrl!)?.resized(to: size)
                        
                        annotationView?.layer.masksToBounds = true
                        annotationView?.layer.cornerRadius = annotationView!.image!.size.height/2
                        } else {
                        annotationView?.image = UIImage(named: "emptyPhoto1.png")?.resized(to: size)
                        }
                })
            }
            } else {
                annotationView?.annotation = annotation
            }
                
            return annotationView
        }
        
        // Standart pin yerine atanmis bir resim.
        let annotationIdentifier = "AnnotationIdentifier"
        
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MyAnnotationView
        if annotationView == nil {
            annotationView = MyAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "friendLocation1.png")?.resized(to: sizePin)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.task?.cancel()
            annotationView?.annotation = annotation
        }
        
        if let t = annotation.title, t == "Let's meet up!" {
            let ident = "pressIcon"
            pressedPinIcon = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
            
            if pressedPinIcon == nil {
                pressedPinIcon = MKAnnotationView(annotation: annotation, reuseIdentifier: ident)
                pressedPinIcon.image = UIImage(named: "destinationIcon.png")?.resized(to: sizePin)
                pressedPinIcon.canShowCallout = true
                pressedPinIcon.centerOffset = CGPoint(x: 0, y: -20)
            } else {
                    pressedPinIcon?.annotation = annotation
            }
            
            return pressedPinIcon
        }
        
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func deneme() {
        print("kullanici resmine basildi")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        deneme()
    }
    // -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //  -- // -- //
    // funcs
    
    var user = [User]()
    
    func observeLocations() {
        
        guard let id = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let lat = self.locationManager?.location?.coordinate.latitude
        let long = self.locationManager?.location?.coordinate.longitude
        var locValues = [String: Any]()
        if lat == nil && long == nil {

        }else {
            locValues = ["latitude": lat!, "longitude": long!] as [String: Any]
        }
        let dataRef = FIRDatabase.database().reference()
        
        //If there is no userLocation with ID!
        dataRef.child("locations").child(id).observe(.value, with: { (refIDSnapshot) in
            let dicID = refIDSnapshot.value as? [String: Any]
            
            if dicID == nil {
                dataRef.child("locations").child(id).childByAutoId().setValue(locValues)
            }
            
        })
        
        // If there is a location with userID!
        dataRef.child("locations").child(id).setValue(locValues)
    }
    
    func badgeCountForRequest() {
        //Badge Editing for SearchVC
        if userID == nil {
            
        } else {
        ref.child("users").child(userID!).child("requests").observe(.value, with: { (snapshot) in
            let snap = snapshot.value as? NSDictionary
            
            if snap != nil {
                SearchVC.badgeCount = "\(snap!.count)"
            } else {
                
            }
        })
        
        { (error) in
            print(error.localizedDescription)
        }
        }
    }
    func screenZoom(lat:CLLocationDegrees, long:CLLocationDegrees) {
        let latDelta:CLLocationDegrees = 0.05
        let logDelta:CLLocationDegrees = 0.05
        let aSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: logDelta)
        let center = CLLocationCoordinate2DMake(lat, long)
        let region = MKCoordinateRegionMake(center, aSpan)
        self.mapView.setRegion(region, animated: true)
    }
    // Popover Methods
    @IBOutlet weak var friendSelectImg: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            let vc = segue.destination
            vc.popoverPresentationController?.delegate = self
            vc.preferredContentSize = CGSize(width: self.view.frame.width / 1.7, height: 135)
            vc.popoverPresentationController?.sourceView = friendSelectImg
            vc.popoverPresentationController?.sourceRect = friendSelectImg.bounds
            
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func lokasyonDagit() {
        
        //Secili kullanicilari haritada goster
         for item in MapPage.selectedUsersInfo {
            let dic = item as! [String : Any]
            let id = dic["id"] as! String // secili kullanici id'si.
            ref.child("locations").child("\(id)").observe(.value, with: { (snapshot) in
                
                let snap = snapshot.value as? [String: Any]
                
                self.pinEkle(dic["name"] as! String, lat: snap?["latitude"] as! CLLocationDegrees, long: snap?["longitude"] as! CLLocationDegrees)
                
            })
        }
    }
    func amIselectedFunc() {
        if userID != nil {
            self.amISelected = true
        ref.child("selectedfriends").child(userID!).observe(.value, with: { (snapshot) in
            let snap = snapshot.value as? [String: Bool]
            if snap != nil {
                for (key, val) in snap! {
                    if val == true  {
                        self.ref.child("locations").child(key).observe(.value, with: { (locSnap) in
                            let locationSnap = locSnap.value as? [String: Any]
                            let latitudeLoc = locationSnap?["latitude"] as? CLLocationDegrees
                            let longitudeLoc = locationSnap?["longitude"] as? CLLocationDegrees
                            
                            self.ref.child("users").child(key).observe(.value, with: { (forNameSnap) in
                                let nameSnap = forNameSnap.value as? [String: Any]
                                let name = nameSnap?["name"] as! String
                                if (latitudeLoc != nil) && (longitudeLoc != nil) {
                                    self.pinEkle(name, lat: latitudeLoc!, long: longitudeLoc!)
                                }
                            })
                        })
//                        print("Kullanici secim yapmis, lokasyon diger kullanicinin haritasinda beliricek")
                    }
                }
            } else {
            }
        })
    }
}
    
    func gestureFunc() {
        print("direction'a basildi")
    }
    
    func justForFriendUserDirection() {
        // Mevcut kullanici lokasyonu
        let latitude = self.locationManager?.location?.coordinate.latitude
        let longitude = self.locationManager?.location?.coordinate.longitude
        
        if latitude != nil && longitude != nil {
            
            self.request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), addressDictionary: nil))
            
                ref.child("selectedfriends").child(userID!).observe(.value, with: { (snapshot) in
                    
                    let snap = snapshot.value as? [String: Bool]
                    if snap == nil {
                    } else {
                    for (key, _) in snap! {
                        
                        self.ref.child("users").child(key).child("selectedLocation").observe(.value, with: { (forSelectedLocationSnap) in
                            
                            let snapForSelectedLoc = forSelectedLocationSnap.value as? [String: Any]
                            let selectedLatitude = snapForSelectedLoc?["latitude"] as! CLLocationDegrees
                            let selectedLongitude = snapForSelectedLoc?["longitude"] as! CLLocationDegrees
                            
                            self.pinEkle("Let's meet up!", lat: selectedLatitude, long: selectedLongitude)
                            
                            self.request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongitude)))
                            
                            self.ref.child("locations").child(key).observe(.value, with: { (snapshot) in
                                
                                let snap = snapshot.value as? [String: Any]
                                //Arkadas ekraninda mevcut kullanici guzergahi
                                let latitude = snap?["latitude"] as! CLLocationDegrees
                                let longitude = snap?["longitude"] as! CLLocationDegrees
                                
                                if latitude != nil && longitude != nil {
                                    
                                    self.request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), addressDictionary: nil))
                                    
                                    self.request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongitude), addressDictionary: nil))
                                    self.request.requestsAlternateRoutes = false
                                    self.request.transportType = .any
                                    
                                    let directions = MKDirections(request: self.request)
                                    let mapov = self.mapView.overlays
                                    directions.calculate { response, error in
                                        guard let unwrappedResponse = response else { return }
                                        self.mapView.removeOverlays(mapov)
                                        
                                        for route in unwrappedResponse.routes {
                                            
                                            if route.polyline != nil {
                                                self.mapView.remove(route.polyline)
                                            }
                                            
                                            self.mapView.add(route.polyline)
                                            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                        }
                                    }
                                }
                            })
                        })
                    }
                   }
                })
            
            self.request.requestsAlternateRoutes = false
            self.request.transportType = .any
            
            let directions = MKDirections(request: self.request)
            let mapov = self.mapView.overlays
            directions.calculate { response, error in
                guard let unwrappedResponse = response else { return }
                self.mapView.removeOverlays(mapov)
                
                for route in unwrappedResponse.routes {
                    
                    if route.polyline != nil {
                        self.mapView.remove(route.polyline)
                    }
                    
                    self.mapView.add(route.polyline)
                    
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    
    func justForUserDirection() {
        // Mevcut kullanici lokasyonu
        let latitude = self.locationManager?.location?.coordinate.latitude
        let longitude = self.locationManager?.location?.coordinate.longitude
        
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        
        if latitude != nil && longitude != nil {
            
            self.request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), addressDictionary: nil))
            
            if amISelected == false {
            self.request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), addressDictionary: nil))
            } else {
                 ref.child("selectedfriends").child(userID!).observe(.value, with: { (snapshot) in
                    
                    let snap = snapshot.value as? [String: Bool]
                    if snap == nil {
                        print("Snap yok")
                    } else {
                    for (key, _) in snap! {
                        self.ref.child("users").child(key).child("selectedLocation").observe(.value, with: { (forSelectedLocationSnap) in
                            
                            let snapForSelectedLoc = forSelectedLocationSnap.value as? [String: Any]
                            let selectedLatitude = snapForSelectedLoc?["latitude"] as! CLLocationDegrees
                            let selectedLongitude = snapForSelectedLoc?["longitude"] as! CLLocationDegrees
                            self.request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongitude)))
                            
                        })
                        
                    }
                }
                    
            })
                
        }
            self.request.requestsAlternateRoutes = false
            self.request.transportType = .any
            
            let directions = MKDirections(request: self.request)
            let mapov = self.mapView.overlays
            directions.calculate { response, error in
                guard let unwrappedResponse = response else { return }
                self.mapView.removeOverlays(mapov)
                
                for route in unwrappedResponse.routes {
                    
                    if route.polyline != nil {
                        self.mapView.remove(route.polyline)
                    }
                    
                    self.mapView.add(route.polyline)
                    
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    
    func circleFunc() {
        let circle = MKCircle(center: CLLocationCoordinate2D(latitude: locationManager!.location!.coordinate.latitude, longitude: locationManager!.location!.coordinate.longitude), radius: 235.0)
        
        mapView.add(circle)
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (timer) in
            self.mapView.remove(circle)
        })
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        
        renderer.strokeColor = UIColor.init(red: 74/255, green: 114/255, blue: 255/255, alpha: 1.0)
        renderer.lineWidth = 4
        
        return renderer
    }
    
    func showDirections() {
        
        justForUserDirection()
        
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        
        for item in MapPage.selectedUsersInfo {

            let dic = item as! [String : Any]
            // secili kullanici id'si.
            let id = dic["id"] as! String
            ref.child("locations").child("\(id)").observe(.value, with: { (snapshot) in
                
                let snap = snapshot.value as? [String: Any]
                //Secili kullanici lokasyonu
                let latitude = snap?["latitude"] as! CLLocationDegrees
                let longitude = snap?["longitude"] as! CLLocationDegrees
                
                if latitude != nil && longitude != nil {
                    
             self.request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), addressDictionary: nil))
                
            self.request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), addressDictionary: nil))
             self.request.requestsAlternateRoutes = false
             self.request.transportType = .any
                    
             let directions = MKDirections(request: self.request)
                    let mapov = self.mapView.overlays
             directions.calculate { response, error in
             guard let unwrappedResponse = response else { return }
                self.mapView.removeOverlays(mapov)
                
                for route in unwrappedResponse.routes {
                
                    if route.polyline != nil {
                        self.mapView.remove(route.polyline)
                    }
                
                    self.mapView.add(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
         }
    }
    })
            
            
        }
        
    }


    @IBAction func longPressBtn(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        var locValues = [String: Any]()

        annotation.coordinate = locCoordinate
        annotation.title = "Let's meet up!"
        
        self.mapView.addAnnotation(annotation)
        if mapView.overlays == nil {
            
        } else {
            mapView.removeOverlays(mapView.overlays)
        }
        
        
        if lat == nil && long == nil {
            
        }else {
            locValues = ["latitude": lat, "longitude": long] as [String: Any]
        }
        ref.child("users").child(userID!).child("selectedLocation").setValue(locValues)
        showDirections()
    }
    
    @IBOutlet weak var trafficBtnImg: UIButton!
    @IBAction func trafficShow(_ sender: UIButton) {
        if mapView.showsTraffic == false  {
            trafficBtnImg.setImage(UIImage(named: "trafficIcon.png"), for: .normal)
            mapView.showsTraffic = true
        } else {
            mapView.showsTraffic = false
            trafficBtnImg.setImage(UIImage(named: "trafficOffIcon.png"), for: .normal)
        }
    }
    
    @IBAction func friendSelect(_ sender: UIButton) {
        self.performSegue(withIdentifier: "details", sender: nil)
    }
}
