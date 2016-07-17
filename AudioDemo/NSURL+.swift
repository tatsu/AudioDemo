//
//  NSURL+.swift
//  AudioDemo
//
//  Created by Tatsuhiko Arai on 7/18/16.
//  Copyright © 2016 Tatsuhiko Arai. All rights reserved.
//

import Foundation

extension NSURL {
    // http://stackoverflow.com/questions/31736404/ios-get-file-size-before-downloading
    var remoteSize: Int64 {
        var contentLength: Int64 = NSURLSessionTransferSizeUnknown
        let request = NSMutableURLRequest(URL: self, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0);
        request.HTTPMethod = "HEAD";
        request.timeoutInterval = 5;
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            dispatch_group_leave(group)
        }).resume()
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, Int64(5 * NSEC_PER_SEC)))
        return contentLength
    }
}
