//
//  ImagePreviewViewController.swift
//  IceWeather
//
//  Created by Kyusaku Mihara on 6/10/15.
//  Copyright (c) 2015 epohsoft. All rights reserved.
//

import UIKit

protocol ImagePreviewViewControllerDelegate: NSObjectProtocol {
    func imagePreviewViewController(viewController: ImagePreviewViewController, didFinishSelectImage image: UIImage)
}

class ImagePreviewViewController: UIViewController {
    
    weak var delegate: ImagePreviewViewControllerDelegate?
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    private var imagePickerController: UIImagePickerController!
    private weak var imagePickerControllerDelegate: UIImagePickerControllerDelegate?
    
    class func imagePreviewViewController() -> ImagePreviewViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("ImagePreviewViewController") as? ImagePreviewViewController {
            return viewController
        }
        fatalError("ImagePreviewViewController not found.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if
            let imagePickerController = self.navigationController as? UIImagePickerController,
            let imagePickerControllerDelegate = self.navigationController?.delegate as? UIImagePickerControllerDelegate
        {
            self.imagePickerController = imagePickerController
            self.imagePickerControllerDelegate = imagePickerControllerDelegate
        } else {
            fatalError("navigationController is not UIImagePickerController. \(self.navigationController)")
        }
        
        self.imageView.image = self.image
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.imagePickerController.sourceType == .Camera {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.imagePickerController.sourceType == .Camera {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        self.navigationController?.setToolbarHidden(true, animated: true)

        super.viewWillDisappear(animated)
    }

    @IBAction func cancelBarButtonTapped(sender: AnyObject) {
        self.imagePickerControllerDelegate?.imagePickerControllerDidCancel?(self.imagePickerController)
    }

    @IBAction func rotateBarButtonTapped(sender: AnyObject) {
        let originalSize = self.image.size

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(originalSize.height, originalSize.width), false, self.image.scale)
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(contextRef, 1, -1)
        CGContextRotateCTM(contextRef, CGFloat(-M_PI_2))
        CGContextDrawImage(contextRef, CGRectMake(0, 0, originalSize.width, originalSize.height), self.image.CGImage)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.imageView.image = self.image
    }

    @IBAction func sendBarButtonTapped(sender: AnyObject) {
        self.delegate?.imagePreviewViewController(self, didFinishSelectImage: self.image)
    }

}
