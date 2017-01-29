
//
//  CustomPointAnnotation.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 11/11/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?
    dynamic var subtitle: String?
    dynamic var image: UIImage?
    var profileImageUrl: URL?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

class MyAnnotationView: MKAnnotationView {
    weak var task: URLSessionTask?    // keep track of this in case we need to cancel it when the annotation view is re-used
}
class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

class MyAnnotationV: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?
    dynamic var subtitle: String?
    dynamic var image: UIImage?
    var profileImageUrl: URL?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
