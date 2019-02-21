//
//  PhotoPreviewTransitionController.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/21/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

enum PhotoPreviewTransitionControllerMode: Int {
    case presenting, dismissing
}

protocol PhotoPreviewTransitionControllerProtocol {
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer)
    func supportsModalPresentationStyle(_ modalPresentationStyle: UIModalPresentationStyle) -> Bool
    var supportsInteractiveDismissal: Bool { get }
    var mode: PhotoPreviewTransitionControllerMode { get set }
    var transitionInfo: PhotoPreviewTransitionInfo { get }
}

protocol PhotoPreviewTransitionHostVCProtocol {
    var hostImageView: UIImageView { get }
    var hostOverlayView: UIView? { get }
    var scale: CGFloat { get }
    func setInitialConstaintsToHostImageView()
}

class PhotoPreviewTransitionController: NSObject, PhotoPreviewTransitionControllerProtocol,
UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
    
    var transitionInfo: PhotoPreviewTransitionInfo
    
    private struct Constants {
        static let FadeInOutTransitionRatio: Double = 1 / 3
        static let TransitionAnimSpringDampening: CGFloat = 1
        
        /// The distance threshold at which the interactive controller will dismiss upon end touches.
        static let DismissalPercentThreshold: CGFloat = 0.14
        /// The velocity threshold at which the interactive controller will dismiss upon end touches.
        static let DismissalVelocityYThreshold: CGFloat = 400
        /// The velocity threshold at which the interactive controller will dismiss in any direction the user is swiping.
        static let DismissalVelocityAnyDirectionThreshold: CGFloat = 1000
    }
    
    // Interactive dismissal transition tracking
    private var dismissalPercent: CGFloat = 0
    private var directionalDismissalPercent: CGFloat = 0
    private var dismissalVelocityY: CGFloat = 1
    private var forceImmediateInteractiveDismissal = false
    private var completeInteractiveDismissal = false
    private var imageViewInitialCenter: CGPoint = .zero
    
    private var imageViewOriginalSuperview: UIView?
    private var overlayViewOriginalSuperview: UIView?
    weak private var dismissalTransitionContext: UIViewControllerContextTransitioning?
    weak private var imageView: UIImageView?
    weak private var overlayView: UIView?
    
    private var startingCornerRadius: CGFloat = 0
    private var endingCornerRadius: CGFloat = 0
    
    private lazy var fadeView: UIView = {
        let fadeView = UIView()
        fadeView.backgroundColor = UIColor.black
        return fadeView
    }()
    
    var mode: PhotoPreviewTransitionControllerMode = .presenting
    
    /// Pending animations that can occur when interactive dismissal has not been triggered by the system,
    /// but our pan gesture recognizer is receiving touch events.
    /// Processed as soon as the interactive dismissal has been set up.
    private var pendingAnimations = [() -> Void]()
    
    private static let supportedModalPresentationStyles: [UIModalPresentationStyle] = [.fullScreen,
                                                                                       .currentContext,
                                                                                       .custom,
                                                                                       .overFullScreen,
                                                                                       .overCurrentContext]
    
    var supportsContextualPresentation: Bool {
        return (transitionInfo.startingView != nil)
    }
    
    var supportsInteractiveDismissal: Bool {
        return transitionInfo.interactiveDismissalEnabled
    }
    
    init(transitionInfo: PhotoPreviewTransitionInfo) {
        self.transitionInfo = transitionInfo
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionInfo.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.mode == .presenting {
            self.animatePresentation(using: transitionContext)
        } else if self.mode == .dismissing {
            self.animateDismissal(using: transitionContext)
        }
    }
    
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: .to),
            let from = transitionContext.viewController(forKey: .from),
            let referenceView = transitionInfo.startingView else {
                assertionFailure("Something missing")
                return
        }
        
        let referenceViewCopy = referenceView.imageViewCopy
        startingCornerRadius = referenceViewCopy.layer.cornerRadius
        
        fadeView.alpha = 0
        fadeView.frame = transitionContext.finalFrame(for: to)
        transitionContext.containerView.addSubview(fadeView)
        
        to.view.alpha = 0
        to.view.frame = transitionContext.finalFrame(for: to)
        transitionContext.containerView.addSubview(to.view)
        
        transitionContext.containerView.layoutIfNeeded()
        
        let referenceViewFrame = referenceView.frame
        referenceView.transform = .identity
        referenceView.frame = referenceViewFrame
        
        let referenceViewCenter = referenceView.center
        referenceViewCopy.transform = from.view.transform
        referenceViewCopy.center = transitionContext.containerView.convert(referenceViewCenter,
                                                                           from: referenceView.superview)
        transitionContext.containerView.addSubview(referenceViewCopy)
        
        var imageAspectRatio: CGFloat = 1
        if let image = referenceViewCopy.image {
            imageAspectRatio = image.size.width / image.size.height
        }
        
        let referenceViewAspectRatio = referenceViewCopy.bounds.size.width / referenceViewCopy.bounds.size.height
        var aspectRatioAdjustedSize = referenceViewCopy.bounds.size
        if abs(referenceViewAspectRatio - imageAspectRatio) > .ulpOfOne {
            aspectRatioAdjustedSize.width = aspectRatioAdjustedSize.height * imageAspectRatio
        }
        
        let scale = min(to.view.frame.size.width / aspectRatioAdjustedSize.width,
                        to.view.frame.size.height / aspectRatioAdjustedSize.height)
        let scaledSize = CGSize(width: aspectRatioAdjustedSize.width * scale,
                                height: aspectRatioAdjustedSize.height * scale)
        
        let scaleAnimations = { [weak self] () in
            guard let self = self else {
                return
            }
            
            referenceViewCopy.transform = .identity
            referenceViewCopy.frame.size = scaledSize
            referenceViewCopy.center = to.view.center
            
            // swiftformat:disable emptyBraces
            if #available(iOS 11.0, *) {
            } else {
                let animation = CABasicAnimation(keyPath: "cornerRadius")
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fromValue = NSNumber(value: Float(referenceViewCopy.layer.cornerRadius))
                animation.toValue = NSNumber(value: Float(self.endingCornerRadius))
                animation.duration = self.transitionDuration(using: transitionContext)
                referenceViewCopy.layer.add(animation, forKey: "cornerRadius")
            }
            // swiftformat:enable emptyBraces
            
            referenceViewCopy.layer.cornerRadius = self.endingCornerRadius
        }
        
        let scaleCompletion = { [weak self] (_ finished: Bool) in
            guard let self = self else {
                return
            }
            
            to.view.alpha = 1
            referenceViewCopy.removeFromSuperview()
            self.fadeView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        
        let fadeAnimations: () -> Void = { [weak self] in
            self?.fadeView.alpha = 1
        }
        
        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: Constants.TransitionAnimSpringDampening,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent],
            animations: scaleAnimations,
            completion: scaleCompletion
        )
        
        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext) * Constants.FadeInOutTransitionRatio,
            delay: 0,
            options: [.curveEaseInOut],
            animations: fadeAnimations
        )
    }
    
    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: .to),
            let from = transitionContext.viewController(forKey: .from) else {
                assertionFailure("Something missing")
                return
        }
        
        guard let imagePreviewViewController = imagePreviewViewControllerFrom(from) else {
            assertionFailure("Could not find ImagePreviewTransitionHostVCProtocol")
            return
        }
        
        let imageView = imagePreviewViewController.hostImageView
        if let contentMode = transitionInfo.endingView?.contentMode {
            imageView.contentMode = contentMode
        }
        let imageViewFrame = imageView.frame
        
        let presentersViewRemoved = from.presentationController?.shouldRemovePresentersView ?? false
        if to.view.superview != transitionContext.containerView && presentersViewRemoved {
            to.view.frame = transitionContext.finalFrame(for: to)
            transitionContext.containerView.addSubview(to.view)
        }
        
        fadeView.frame = transitionContext.finalFrame(for: from)
        transitionContext.containerView.insertSubview(fadeView, aboveSubview: to.view)
        
        if from.view.superview != transitionContext.containerView {
            from.view.frame = transitionContext.finalFrame(for: from)
            transitionContext.containerView.addSubview(from.view)
        }
        
        transitionContext.containerView.layoutIfNeeded()
        
        imageView.transform = .identity
        imageView.frame = imageViewFrame
        
        if imageView.superview != transitionContext.containerView {
            let imageViewCenter = imageView.center
            imageView.transform = from.view.transform
            let center = transitionContext.containerView.convert(imageViewCenter, from: imageView.superview)
            
            transitionContext.containerView.addSubview(imageView)
            
            imageView.snp.remakeConstraints({ make in
                make.size.equalTo(imageView.frame.size)
                make.center.equalTo(center)
            })
        }
        
        imagePreviewViewController.hostOverlayView?.isHidden = true
        
        var offscreenImageViewCenter: CGPoint?
        let scaleAnimations = { [weak self] () in
            guard let self = self else {
                return
            }
            
            imageView.layer.cornerRadius = self.startingCornerRadius
            imageView.layer.masksToBounds = true
            
            if self.canPerformContextualDismissal() {
                guard let referenceView = self.transitionInfo.endingView else {
                    assertionFailure("Expected non-nil endingView")
                    return
                }
                
                imageView.transform = .identity
                
                let frame = transitionContext.containerView.convert(referenceView.frame, from: referenceView.superview)
                let center = CGPoint(x: frame.midX, y: frame.midY)
                
                imageView.snp.remakeConstraints({ make in
                    make.size.equalTo(frame.size)
                    make.center.equalTo(center)
                })
                
                imageView.superview?.layoutIfNeeded()
            } else {
                if let offscreenImageViewCenter = offscreenImageViewCenter {
                    imageView.center = offscreenImageViewCenter
                }
            }
        }
        
        let scaleCompletion = { (_ finished: Bool) in
            
            imageView.removeFromSuperview()
            
            if transitionContext.isInteractive {
                transitionContext.finishInteractiveTransition()
            }
            
            transitionContext.completeTransition(true)
        }
        
        let fadeAnimations = { [weak self] in
            self?.fadeView.alpha = 0
            from.view.alpha = 0
        }
        
        let fadeCompletion: ((Bool) -> Void)? = { [weak self] (_ finished: Bool) in
            self?.fadeView.removeFromSuperview()
        }
        
        var scaleAnimationOptions: UIView.AnimationOptions
        var scaleInitialSpringVelocity: CGFloat
        
        if self.canPerformContextualDismissal() {
            scaleAnimationOptions = [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent]
            scaleInitialSpringVelocity = 0
        } else {
            let extrapolated = self.extrapolateFinalCenter(for: imageView, in: transitionContext.containerView)
            offscreenImageViewCenter = extrapolated.center
            
            if self.forceImmediateInteractiveDismissal {
                scaleAnimationOptions = [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent]
                scaleInitialSpringVelocity = 0
            } else {
                var divisor: CGFloat = 1
                let changed = extrapolated.changed
                if .ulpOfOne >= abs(changed - extrapolated.center.x) {
                    divisor = abs(changed - imageView.frame.origin.x)
                } else {
                    divisor = abs(changed - imageView.frame.origin.y)
                }
                
                scaleAnimationOptions = [.curveLinear, .beginFromCurrentState, .allowAnimatedContent]
                scaleInitialSpringVelocity = abs(self.dismissalVelocityY / divisor)
            }
        }
        
        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: Constants.TransitionAnimSpringDampening,
            initialSpringVelocity: scaleInitialSpringVelocity,
            options: scaleAnimationOptions,
            animations: scaleAnimations,
            completion: scaleCompletion
        )
        
        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext) * Constants.FadeInOutTransitionRatio,
            delay: 0,
            options: [.curveEaseInOut],
            animations: fadeAnimations,
            completion: fadeCompletion
        )
    }
    
    // MARK: - UIViewControllerInteractiveTransitioning
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.dismissalTransitionContext = transitionContext
        
        guard let to = transitionContext.viewController(forKey: .to),
            let from = transitionContext.viewController(forKey: .from) else {
                assertionFailure("Something missing")
                return
        }
        
        guard let imagePreviewViewController = imagePreviewViewControllerFrom(from) else {
            assertionFailure("Could not find ImagePreviewTransitionHostVCProtocol")
            return
        }
        
        let imageView = imagePreviewViewController.hostImageView
        
        self.imageView = imageView
        self.overlayView = imagePreviewViewController.hostImageView
        
        if self.forceImmediateInteractiveDismissal {
            self.processPendingAnimations()
            return
        }
        
        let presentersViewRemoved = from.presentationController?.shouldRemovePresentersView ?? false
        if presentersViewRemoved {
            to.view.frame = transitionContext.finalFrame(for: to)
            transitionContext.containerView.addSubview(to.view)
        }
        
        let fadeView = UIView()
        fadeView.backgroundColor = UIColor.black
        fadeView.frame = transitionContext.finalFrame(for: from)
        transitionContext.containerView.insertSubview(fadeView, aboveSubview: to.view)
        self.fadeView = fadeView
        
        from.view.frame = transitionContext.finalFrame(for: from)
        transitionContext.containerView.addSubview(from.view)
        
        transitionContext.containerView.layoutIfNeeded()
        
        self.imageViewOriginalSuperview = imageView.superview
        let center = transitionContext.containerView.convert(imageView.center, from: imageView.superview)
        transitionContext.containerView.addSubview(imageView)
        self.imageViewInitialCenter = center
        
        imageView.setNeedsLayout()
        
        let scale = imagePreviewViewController.scale
        
        imageView.snp.remakeConstraints({ make in
            make.center.equalTo(center)
            make.width.equalTo(imageView.frame.size.width * scale)
            make.height.equalTo(imageView.frame.size.height * scale)
        })
        imageView.superview?.layoutIfNeeded()
        
        let overlayView = imagePreviewViewController.hostOverlayView
        if let overlayView = overlayView {
            self.overlayViewOriginalSuperview = overlayView.superview
            overlayView.frame = transitionContext.containerView.convert(overlayView.frame, from: overlayView.superview)
            transitionContext.containerView.addSubview(overlayView)
        }
        
        from.view.alpha = 0
        
        self.processPendingAnimations()
    }
    
    private func cancelTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.viewController(forKey: .from) else {
            assertionFailure("Expected non-nil")
            return
        }
        
        guard let imagePreviewViewController = imagePreviewViewControllerFrom(from) else {
            assertionFailure("Could not find ImagePreviewTransitionHostVCProtocol in container's children.")
            return
        }
        
        let imageView = imagePreviewViewController.hostImageView
        var overlayView = imagePreviewViewController.hostOverlayView
        
        let animations = { [weak self] () in
            guard let self = self else {
                return
            }
            
            imageView.center.y = self.imageViewInitialCenter.y
            
            self.fadeView.alpha = 1
        }
        
        let completion = { [weak self] (_ finished: Bool) in
            guard let self = self else {
                return
            }
            
            from.view.alpha = 1
            
            self.imageViewOriginalSuperview?.addSubview(imageView)
            imagePreviewViewController.setInitialConstaintsToHostImageView()
            
            if let overlayView = overlayView {
                overlayView.frame = transitionContext.containerView.convert(overlayView.frame, to: self.overlayViewOriginalSuperview)
                self.overlayViewOriginalSuperview?.addSubview(overlayView)
            }
            
            self.imageViewInitialCenter = .zero
            self.imageViewOriginalSuperview = nil
            
            self.overlayViewOriginalSuperview = nil
            
            self.dismissalPercent = 0
            self.directionalDismissalPercent = 0
            self.dismissalVelocityY = 1
            
            if transitionContext.isInteractive {
                transitionContext.cancelInteractiveTransition()
            }
            
            transitionContext.completeTransition(false)
            self.dismissalTransitionContext = nil
        }
        
        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: Constants.TransitionAnimSpringDampening,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent],
            animations: animations,
            completion: completion
        )
    }
    
    // MARK: - Helpers
    
    private func imagePreviewViewControllerFrom(_ from: UIViewController) -> PhotoPreviewTransitionHostVCProtocol? {
        if let from = from as? PhotoPreviewTransitionHostVCProtocol {
            return from
        }
        return from.children
            .first { $0 is PhotoPreviewTransitionHostVCProtocol }
            .flatMap { $0 as? PhotoPreviewTransitionHostVCProtocol }
    }
    
    private func processPendingAnimations() {
        for animation in self.pendingAnimations {
            animation()
        }
        
        self.pendingAnimations.removeAll()
    }
    
    private func canPerformContextualDismissal() -> Bool {
        guard let endingView = transitionInfo.endingView, let endingViewSuperview = endingView.superview else {
            return false
        }
        
        return UIScreen.main.bounds.intersects(endingViewSuperview.convert(endingView.frame, to: nil))
    }
    
    // MARK: - ImagePreviewTransitionController
    
    func supportsModalPresentationStyle(_ modalPresentationStyle: UIModalPresentationStyle) -> Bool {
        return type(of: self).supportedModalPresentationStyles.contains(modalPresentationStyle)
    }
    
    public func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        self.dismissalVelocityY = sender.velocity(in: sender.view).y
        let translation = sender.translation(in: sender.view?.superview)
        
        switch sender.state {
        case .began:
            self.overlayView = nil
            
        case .changed:
            let animation = { [weak self] in
                guard let self = self else {
                    return
                }
                
                let height = UIScreen.main.bounds.size.height
                
                self.directionalDismissalPercent =
                    translation.y > 0 ? min(1, translation.y / height) : max(-1, translation.y / height)
                
                self.dismissalPercent = min(1, abs(translation.y / height))
                
                self.completeInteractiveDismissal =
                    (self.dismissalPercent >= Constants.DismissalPercentThreshold) ||
                    (abs(self.dismissalVelocityY) >= Constants.DismissalVelocityYThreshold)
                
                // this feels right-ish
                let dismissalRatio = (1.2 * self.dismissalPercent / Constants.DismissalPercentThreshold)
                
                let imageViewCenterY = self.imageViewInitialCenter.y + translation.y
                
                UIView.performWithoutAnimation {
                    self.imageView?.center.y = imageViewCenterY
                }
                
                self.fadeView.alpha = 1 - (1 * min(1, dismissalRatio))
            }
            
            if let dismissalTransitionContext = dismissalTransitionContext {
                disableInteractionsInDestinationVC(transitionContext: dismissalTransitionContext)
            }
            
            if self.imageView == nil || self.overlayView == nil {
                self.pendingAnimations.append(animation)
                return
            }
            
            animation()
            
        case .ended:
            fallthrough
        case .cancelled:
            let animation = { [weak self] in
                guard let self = self, let transitionContext = self.dismissalTransitionContext else {
                    return
                }
                
                if self.completeInteractiveDismissal {
                    self.animateDismissal(using: transitionContext)
                } else {
                    self.cancelTransition(using: transitionContext)
                }
                self.enableInteractionsInDestinationVC(transitionContext: transitionContext)
            }
            
            // `imageView`, `overlayView` set in `startInteractiveTransition(_:)`
            if self.imageView == nil || self.overlayView == nil {
                self.pendingAnimations.append(animation)
                return
            }
            
            animation()
            
        default:
            break
        }
    }
    
    private func extrapolateFinalCenter(for imageView: UIImageView,
                                        in view: UIView) -> (center: CGPoint, changed: CGFloat) {
        
        let dismissFromBottom =
            abs(self.dismissalVelocityY) > Constants.DismissalVelocityAnyDirectionThreshold ?
                self.dismissalVelocityY >= 0 :
                self.directionalDismissalPercent >= 0
        
        let imageViewRect = imageView.convert(imageView.bounds, to: view)
        var imageViewCenter = imageView.center
        
        if dismissFromBottom {
            imageViewCenter.y = -(imageViewRect.size.height / 2)
        } else {
            imageViewCenter.y = view.frame.size.height + (imageViewRect.size.height / 2)
        }
        
        if abs(imageView.center.x - imageViewCenter.x) >= .ulpOfOne {
            return (imageViewCenter, imageViewCenter.x)
        } else {
            return (imageViewCenter, imageViewCenter.y)
        }
    }
    
    private func disableInteractionsInDestinationVC(transitionContext: UIViewControllerContextTransitioning) {
        setInteractionEnabledStatus(false, toDestinationVCFromContext: transitionContext)
    }
    
    private func enableInteractionsInDestinationVC(transitionContext: UIViewControllerContextTransitioning) {
        setInteractionEnabledStatus(true, toDestinationVCFromContext: transitionContext)
    }
    
    private func setInteractionEnabledStatus(_ isEnabled: Bool, toDestinationVCFromContext context: UIViewControllerContextTransitioning) {
        guard let to = context.viewController(forKey: .to) else {
            assertionFailure("Something missing")
            return
        }
        
        to.view.isUserInteractionEnabled = isEnabled
    }
}
