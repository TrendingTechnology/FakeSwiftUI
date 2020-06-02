//
//  SearchBar.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/15.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture

open class SearchBar:View {
    let __view = UISearchBar()
    
    public init(placeholder:String, _ text$:BehaviorRelay<String?>) {        
        super.init()
        _view = __view
        _init()
        __view.placeholder = placeholder
        text$ <~> __view.rx.text ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func barStyle(_ style:UIBarStyle) -> Self {
        __view.barStyle = style
        return self
    }
    
    public func autocapitalizationType(_ type:UITextAutocapitalizationType) -> Self {
        __view.autocapitalizationType = type
        return self
    }
    
    public func onSearch(_ callback:@escaping(String?) -> ()) -> Self {
        __view.rx.searchButtonClicked
            .subscribe(onNext:{[unowned self] in
                callback(self.__view.text)
            }) ~ disposeBag
        return self
    }
    
    public func onCancel(_ callback:@escaping() -> ()) -> Self {
        __view.rx.text.changed.distinctUntilChanged()
            .subscribe(onNext:{
                if $0 == "" {
                    callback()
                }
            }) ~ disposeBag
        return self
    }
}

