//
//  Extentions.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 01/11/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImagesUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return

        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async  {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
//                    self.layer.cornerRadius = 25
                    self.layer.masksToBounds = true
                    self.contentMode = .scaleAspectFill
                    self.translatesAutoresizingMaskIntoConstraints = false
                    
                }
                
            }
            
        }).resume()
        
    }
    
}

extension UIImage {
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)   // note, using `WithOptions` rendition with `scale` of `0`
        draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()                              // note, if you call `UIGraphicsBeginImageContext`, you must end it, too
        return image
    }
}
