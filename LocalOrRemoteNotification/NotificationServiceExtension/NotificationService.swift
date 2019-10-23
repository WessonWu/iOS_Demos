//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by wuweixin on 2019/10/23.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UserNotifications
import MobileCoreServices

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            
            if let attachmentString = bestAttemptContent.userInfo["attachment-url"] as? String,
                let attachmentURL = URL(string: attachmentString) {
                let urlRequest = URLRequest(url: attachmentURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
                URLSession.shared.downloadTask(with: urlRequest) { (tempURL, resp, error) in
                    guard self.bestAttemptContent == bestAttemptContent else {
                        return
                    }
                    defer {
                        contentHandler(bestAttemptContent)
                    }
                    if let error = error {
                        print(error)
                    } else if let fileURL = tempURL {
                        do {
                            let mimeType: String = resp?.mimeType ?? "image/jpeg"
                            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() ?? kUTTypeJPEG
                            let attachment = try UNNotificationAttachment(identifier: attachmentString, url: fileURL, options: [UNNotificationAttachmentOptionsTypeHintKey: uti as String])
                            bestAttemptContent.attachments = [attachment]
                        } catch {
                            print(error)
                        }
                    }
                }.resume()
            } else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
