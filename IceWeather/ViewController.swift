//
//  ViewController.swift
//  IceWeather
//
//  Created by Kyusaku Mihara on 6/4/15.
//  Copyright (c) 2015 epohsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImagePreviewViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBarItems()
        fetchIceImage()
    }

    @IBAction func reloadBarButtonTapped(sender: AnyObject) {
        fetchIceImage()
    }
    
    func cameraBarButtonTapped(sender: AnyObject) {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            fatalError("Camera is not supported.")
        }
        
        showImagePicker(.Camera)
    }
    
    func photoLibraryBarButtonTapped(sender: AnyObject) {
        showImagePicker(.PhotoLibrary)
    }
    
    // MARK: - Private methods
    
    private func setUpNavigationBarItems() {
        var rightBarButtonItems: [UIBarButtonItem] = []
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            rightBarButtonItems.append(UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "cameraBarButtonTapped:"))
        }
        rightBarButtonItems.append(UIBarButtonItem(barButtonSystemItem: .Organize, target: self, action: "photoLibraryBarButtonTapped:"))
        
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    private func fetchIceImage() {
        self.navigationItem.leftBarButtonItem?.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.navigationItem.title = "読み込み中..."

        IceWeatherAPI.iceImage { iceImage, error in
            self.navigationItem.leftBarButtonItem?.enabled = true
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if let _ = error {
                self.navigationItem.title = "読み込み失敗"
                let alertController = UIAlertController(title: "エラー", message: "写真の取得に失敗しました。", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.navigationItem.title = iceImage.createdAt
            if let data = NSData(contentsOfURL: NSURL(string: iceImage.URL)!) {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    private func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imagePreviewViewController = ImagePreviewViewController.imagePreviewViewController()
            imagePreviewViewController.delegate = self
            imagePreviewViewController.image = image
            picker.pushViewController(imagePreviewViewController, animated: true)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - ImagePreviewViewControllerDelegate methods

    func imagePreviewViewController(viewController: ImagePreviewViewController, didFinishSelectImage image: UIImage) {
        self.navigationItem.leftBarButtonItem?.enabled = false
        if let rightBarButtonItems = self.navigationItem.rightBarButtonItems {
            for barButtonItem in rightBarButtonItems {
                barButtonItem.enabled = false
            }
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.navigationItem.title = "送信中..."

        IceWeatherAPI.uploadIceImage(image) { iceImage, error in
            self.navigationItem.leftBarButtonItem?.enabled = true
            if let rightBarButtonItems = self.navigationItem.rightBarButtonItems {
                for barButtonItem in rightBarButtonItems {
                    barButtonItem.enabled = true
                }
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if let _ = error {
                self.navigationItem.title = "送信失敗"
                let alertController = UIAlertController(title: "エラー", message: "写真の送信に失敗しました。", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }

            self.navigationItem.title = iceImage.createdAt
            if let data = NSData(contentsOfURL: NSURL(string: iceImage.URL)!) {
                self.imageView.image = UIImage(data: data)
            }
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

