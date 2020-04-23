//
//  ScalableImage.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/1/14.
//  Copyright © 2020 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import AwaitKit
import AVKit
import RxSwift
import RxCocoa
import RxBinding

open class ScalableImage:View
{
    lazy var __view = self._view as! UIScrollView
    let imageView = UIImageView()

    public init(_ image$:Driver<UIImage?>) {
        super.init()
        _view = UIScrollView()
        __view.delegate = self
        _init()
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.append(to: __view)
        
        imageView.rx.tapGesture() { gesture, _ in
            gesture.numberOfTapsRequired = 2
        }.when(.recognized)
            .subscribe(onNext:{[weak self] _ in
                guard let self = self else { return }
                if (self.__view.zoomScale > self.__view.minimumZoomScale) {
                    self.__view.setZoomScale(self.__view.minimumZoomScale, animated: true)
                } else {
                    self.__view.setZoomScale(self.__view.maximumZoomScale, animated: true)
                }
            }) ~ disposeBag
        image$
            .drive(onNext:{[weak self] in
                guard let self = self else { return }
                self.imageView.image = $0
                guard let size = $0?.size else { return }
                self.__view.contentSize = CGSize(width: size.width, height: size.height)
                self.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                self.setZoomScale()
               
                if size.width >= size.height {
                    let newContentOffsetX = (self.__view.contentSize.width/2) - (self.bounds.size.width/2)
                    self.__view.setContentOffset(CGPoint(x: newContentOffsetX, y: 0) , animated: false)
                } else {
                    self.__view.setContentOffset(CGPoint(x: 0, y: 0) , animated: false)
                }
            }) ~ disposeBag
    }
    
    public convenience init(_ url$:Observable<String>) {
        let image$ = url$
                .flatMapLatest{ $0.get$().catchErrorJustReturn(Data()) }
                .map{UIImage(data:$0)}
                .asDriver(onErrorJustReturn: nil)
        self.init(image$)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = _view.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
            
        __view.minimumZoomScale = min(widthScale, heightScale)
        __view.maximumZoomScale = max(widthScale, heightScale)
        __view.zoomScale = heightScale
    }
}

extension ScalableImage:UIScrollViewDelegate
{
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let xCenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : scrollView.center.x
        let yCenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : scrollView.center.y;
        imageView.center = CGPoint(x: xCenter, y: yCenter)
    }
}
