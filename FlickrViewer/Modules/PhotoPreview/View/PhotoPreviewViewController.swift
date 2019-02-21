//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit
import SnapKit

final class PhotoPreviewViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    typealias TransitionController = (
        PhotoPreviewTransitionControllerProtocol &
        UIViewControllerAnimatedTransitioning &
        UIViewControllerInteractiveTransitioning)
    
    // MARK: Public properties
    
    var photo: MainModel.Photo?
    var transitionController: TransitionController?
    
    // MARK: Private properties
    
    private var maxSize = CGSize.zero
    private var initialScale: CGFloat = 0
    
    private enum ScaleModificator {
        static let min: CGFloat = 1
        static let middle: CGFloat = 1.75
        static let max: CGFloat = 3
        
        static let allValues: [CGFloat] = [ScaleModificator.min, ScaleModificator.middle, ScaleModificator.max]
    }
    
    private var panGesture: UIPanGestureRecognizer?
    
    private var doubleTapGesture: UITapGestureRecognizer?
    
    fileprivate var isForcingNonInteractiveDismissal = false
    
    // MARK: UI elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        return contentView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return imageView
    }()
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImage()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture = pan
        view.addGestureRecognizer(pan)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTapGesture = doubleTap
        view.addGestureRecognizer(doubleTap)
        
        transitioningDelegate = self
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        
        super.dismiss(animated: flag) { [weak self] in
            guard let self = self else { return }
            let canceled = (self.view.window != nil)
            
            if canceled {
                self.isForcingNonInteractiveDismissal = false
                self.panGesture?.isEnabled = true
                self.doubleTapGesture?.isEnabled = true
            }
            
            completion?()
        }
    }
}

// MARK: - Actions

extension PhotoPreviewViewController {
    
    @objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            isForcingNonInteractiveDismissal = false
            dismiss(animated: true, completion: nil)
        }
        
        transitionController?.handlePanGesture(panGesture)
    }
    
    @objc func handleDoubleTapGesture(_ doubleTapGesture: UITapGestureRecognizer) {
        let nextScale = ScaleModificator.allValues
            .map { $0 * initialScale }
            .filter { $0 > scrollView.zoomScale }
            .first
        
        scrollView.setZoomScale(nextScale ?? initialScale, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoPreviewViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
            guard let self = self else {
                return
            }
            
            scrollView.contentInset = self.newInset(scrollView: scrollView)
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = scrollView.zoomScale > initialScale
        
        if scrollView.contentSize.width <= maxSize.width && scrollView.contentSize.height <= maxSize.height {
            scrollView.contentInset = newInset(scrollView: scrollView)
        }
    }
}

// MARK: - ImagePreviewViewProtocol

extension PhotoPreviewViewController {
    func configureTransition(with transitionInfo: PhotoPreviewTransitionInfo?) {
        guard let transitionInfo = transitionInfo else {
            return
        }
        
        transitionController = PhotoPreviewTransitionController(transitionInfo: transitionInfo)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension PhotoPreviewViewController {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let isModalPresentationStyleSupports = transitionController?.supportsModalPresentationStyle(self.modalPresentationStyle)
        let isInteractiveDismissalSupports = transitionController?.supportsInteractiveDismissal
        
        guard isModalPresentationStyleSupports == true && isInteractiveDismissalSupports == true else {
            return nil
        }
        
        transitionController?.mode = .dismissing
        
        return transitionController
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard transitionController?.supportsModalPresentationStyle(self.modalPresentationStyle) == true else {
            return nil
        }
        
        transitionController?.mode = .presenting
        
        return transitionController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard transitionController?.supportsInteractiveDismissal == true && !isForcingNonInteractiveDismissal else {
            return nil
        }
        
        return transitionController
    }
}

extension PhotoPreviewViewController: PhotoPreviewTransitionHostVCProtocol {
    var hostImageView: UIImageView {
        return imageView
    }
    
    var hostOverlayView: UIView? {
        return nil
    }
    
    var scale: CGFloat {
        return scrollView.zoomScale
    }
    
    func setInitialConstaintsToHostImageView() {
        imageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        
        prepareScrollView()
    }
}

private extension PhotoPreviewViewController {
    func newInset(scrollView: UIScrollView) -> UIEdgeInsets {
        var yOffset = imageView.frame.origin.y * scrollView.zoomScale
        var xOffset = imageView.frame.origin.x * scrollView.zoomScale
        
        if imageView.bounds.size.width * scrollView.zoomScale < view.bounds.size.width {
            xOffset = xOffset - view.bounds.size.width / 2 + imageView.frame.size.width * scrollView.zoomScale / 2
        }
        
        if imageView.bounds.size.height * scrollView.zoomScale < view.bounds.size.height {
            yOffset = yOffset - view.bounds.size.height / 2 + imageView.frame.size.height * scrollView.zoomScale / 2
        }
        
        return UIEdgeInsets(
            top: -yOffset,
            left: -xOffset,
            bottom: -yOffset,
            right: -xOffset)
    }
    
    func setupImage() {
        
        guard let thumbLink = photo?.thumb?.url,
            let thumb = URL(string: thumbLink) else { return }
        imageView.sd_setImage(with: thumb) { [weak self] image, error, cahceType, url in
            guard let self = self else {
                return
            }
            
            self.prepareScrollView()
        }
        let placeholder = imageView.image
        guard let link = photo?.orig?.url,
            let url = URL(string: link) else { return }
        imageView.sd_setImage(with: url, placeholderImage: placeholder, options: [.highPriority]) { [weak self] image, error, cahceType, url in
            guard let self = self else {
                return
            }
            
            self.prepareScrollView()
        }
    }
    
    func prepareScrollView() {
        guard let imageSize = imageView.image?.size else {
            return
        }
        
        let widthScale = view.bounds.size.width / imageSize.width
        let heightScale = view.bounds.size.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        initialScale = minScale
        
        scrollView.contentSize = imageView.bounds.size
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = minScale * ScaleModificator.max
        
        view.layoutIfNeeded()
        
        maxSize = CGSize(width: contentView.frame.size.width * scrollView.maximumZoomScale,
                         height: contentView.frame.size.height * scrollView.maximumZoomScale)
        
        scrollView.contentInset = newInset(scrollView: scrollView)
        scrollView.zoomScale = minScale
    }
}


