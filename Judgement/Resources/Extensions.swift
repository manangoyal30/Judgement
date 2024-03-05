//
//  Extensions.swift
//  Judgement
//
//  Created by manan.goyal on 9/2/2024.
//

import UIKit

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}

extension Notification.Name {
    /// Notificaiton  when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

extension Array {
    mutating func rotateLeft(by places: Int) {
        let offset = places % count
        self = Array(self[offset ..< count] + self[0 ..< offset])
    }
}
