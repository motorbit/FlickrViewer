//
//  LayoutGuide.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/20/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

extension UIView {
    
    private struct AssociatedKeys {
        static var keyboardLayoutGuide = "keyboardLayoutGuide"
    }
    
    /// A layout guide representing the inset for the keyboard.
    /// Use this layout guide’s top anchor to create constraints pinning to the top of the keyboard.
    var keyboardLayoutGuide: KeyboardLayoutGuide {
        if let obj = objc_getAssociatedObject(self, &AssociatedKeys.keyboardLayoutGuide) as? KeyboardLayoutGuide {
            return obj
        }
        let guide = KeyboardLayoutGuide()
        addLayoutGuide(guide)
        guide.setup()
        objc_setAssociatedObject(self, &AssociatedKeys.keyboardLayoutGuide, guide as Any, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}

final class KeyboardLayoutGuide: UILayoutGuide {
    
    private final class Keyboard {
        static let shared = Keyboard()
        var currentHeight: CGFloat = 0
    }
    
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        // Observe keyboardWillChangeFrame notifications
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(keyboardWillChangeFrame(_:)),
                       name: UIResponder.keyboardWillChangeFrameNotification,
                       object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Setup
    
    fileprivate func setup() {
        guard let view = owningView else {
            return
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Keyboard.shared.currentHeight),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor),
            ]
        )
        let viewBottomAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            viewBottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            viewBottomAnchor = view.bottomAnchor
        }
        bottomAnchor.constraint(equalTo: viewBottomAnchor).isActive = true
    }
    
    
    // MARK: - Notifications
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard var height = notification.keyboardHeight else {
            return
        }
        if #available(iOS 11.0, *), height > 0, let owningView = owningView {
            height -= owningView.safeAreaInsets.bottom
        }
        if let constraint = heightConstraint, case let oldHeight = constraint.constant, oldHeight != height {
            animate { constraint.constant = height }
        }
        Keyboard.shared.currentHeight = height
    }
    
    
}


// MARK: - Helpers

extension UILayoutGuide {
    var heightConstraint: NSLayoutConstraint? {
        guard let target = owningView else { return nil }
        for c in target.constraints {
            if let fi = c.firstItem as? UILayoutGuide, fi == self && c.firstAttribute == .height {
                return c
            }
        }
        return nil
    }
    
    func animate(layout: () -> Void) {
        guard let owningView = owningView else {
            return
        }
        if owningView.isVisible() {
            UIView.performWithoutAnimation {
                owningView.layoutIfNeeded()
            }
            layout()
            owningView.layoutIfNeeded()
        } else {
            layout()
            UIView.performWithoutAnimation {
                owningView.layoutIfNeeded()
            }
        }
    }
}

private extension Notification {
    var keyboardHeight: CGFloat? {
        guard let v = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return nil }
        
        // Weirdly enough UIKeyboardFrameEndUserInfoKey doesn't have the same behaviour
        // in ios 10 or iOS 11 so we can't rely on v.cgRectValue.width
        return UIScreen.main.bounds.height - v.cgRectValue.minY
    }
}

extension UIView {
    func isVisible() -> Bool {
        func isVisible(inView: UIView?) -> Bool {
            guard let inView = inView else {
                return true
            }
            let frame = self.layer.presentation()?.frame ?? self.frame
            let viewFrame = inView.convert(frame, from: self.superview)
            
            if viewFrame.intersects(inView.bounds) {
                return isVisible(inView: inView.superview)
            }
            return false
        }
        
        return isVisible(inView: self.superview)
    }
}
