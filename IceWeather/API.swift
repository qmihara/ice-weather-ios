//
//  API.swift
//  IceWeather
//
//  Created by Kyusaku Mihara on 6/4/15.
//  Copyright (c) 2015 epohsoft. All rights reserved.
//

import UIKit

class IceWeatherAPI {

    enum Method: String {
        case GET  = "GET"
        case POST = "POST"
    }

    private static let baseURL = NSURL(string: IceWeatherAPIConfig.BaseURL.rawValue)!

    class func iceImage(completionHandler: (IceImage!, NSError!) -> Void) {
        let URLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = URLSession.dataTaskWithRequest(URLRequest(.GET, path: "ice/image")) { data, response, error in
            if let error = error {
                println(error)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(nil, error)
                }
                return
            }

            var JSONError: NSError?
            if let result = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &JSONError) as? [String: AnyObject] {
                if let iceImage = IceImage(dictionary: result) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(iceImage, nil)
                    }
                    return
                }
            }

            println(JSONError?.localizedDescription)

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(nil, NSError(domain: "IceWeatherError", code: 9001, userInfo: nil))
            }
        }
        task.resume()
    }

    class func uploadIceImage(image: UIImage, completionHandler: (IceImage!, NSError!) -> Void) {
        let imageData = UIImageJPEGRepresentation(image, 0.9)

        let request = URLRequest(.POST, path: "ice/image")

        let boundary = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let postData = NSMutableData()
        postData.appendData(("--\(boundary)\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(("Content-Disposition: form-data;" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(("name=\"acceptImage\";" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(("filename=\"image.jpg\"\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(("Content-Type: image/jpeg\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(("\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(imageData)
        postData.appendData(("\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(("--\(boundary)--\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)

        request.HTTPBody = postData

        let URLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = URLSession.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                println(error)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(nil, error)
                }
                return
            }

            var JSONError: NSError?
            if let result = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &JSONError) as? [String: AnyObject] {
                if let iceImage = IceImage(dictionary: result) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(iceImage, nil)
                    }
                    return
                }
            }

            println(JSONError?.localizedDescription)

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(nil, NSError(domain: "IceWeatherError", code: 9002, userInfo: nil))
            }
        }
        task.resume()
    }

    private class func URLRequest(method: Method, path: String) -> NSMutableURLRequest {
        if let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true) {
            components.path = (components.path ?? "").stringByAppendingPathComponent(path)

            let request = NSMutableURLRequest(URL: components.URL!)
            request.HTTPMethod = method.rawValue
            return request
        }

        fatalError("Invalid baseURL. \(baseURL)")
    }

}