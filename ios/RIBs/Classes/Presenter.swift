//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import SwiftUI
import Combine

/// The base protocol for all `Presenter`s.
public protocol Presentable: AnyObject {
    
    /// Type erased view for public use.
    var viewable: Viewable { get }
}

/// Conformance by `Presenter` subclasses to provide a `ViewType` and be an `ObservableObject`.
public protocol ViewPresentable: Presentable, ObservableObject  {
    /// View type confroming to `View`.
    associatedtype ViewType: View
    
    /// Typed view for internal reference.
    var view: ViewType { get }
}

/// The base class of all `Presenter`s. A `Presenter` translates business models into values the corresponding
/// `View` can consume and display. It also maps UI events to business logic method, invoked to
/// its listener.
open class Presenter<View>: BasePresenter {
    public typealias ViewType = View
    
    override public init() { super.init() }
}

/// Base class of `Presenter` for a concrete type.
open class BasePresenter: ViewTracking {
    
    /// Set to `true` `onAppear`, and `false` `onDisappear`.
    public var isDisplayed: Bool = false {
        didSet {
            guard isDisplayed != oldValue else { return }
            if isDisplayed {
                internalOnViewAppear()
            } else {
                internalOnViewDisappear()
            }
        }
    }
    
    let deinitCancellable: CompositeCancellable = CompositeCancellable()
    
    var viewAppearanceCancellable: CompositeCancellable?
    
    deinit {
        deinitCancellable.cancel()
    }
    
    /// Called when `viewTracker.isDisplayed` is `true`.
    open func onViewAppear() { }
    
    /// Called when `viewTracker.isDisplayed` is `false`.
    open func onViewDisappear() { }
    
    func internalOnViewAppear() {
        viewAppearanceCancellable = CompositeCancellable()
        onViewAppear()
    }
    
    func internalOnViewDisappear() {
        viewAppearanceCancellable?.cancel()
        viewAppearanceCancellable = nil
        onViewDisappear()
    }
}

extension ViewPresentable where ViewType: PresenterView, ViewType.PresenterType == Self {
    public var view: ViewType {
        return ViewType(presenter: self)
    }
}

extension ViewPresentable where Self: ViewTracking {
    /// The corresponding `View` owned by this `Presenter`.
    public var viewable: Viewable {
        return tracked(view).asAnyView
    }
}

/// `Presenter` related `Cancellable` extensions.
extension Cancellable {

    /// Cancels the subscription based on the appearance of the given `Presenter`'s `View `. The subscription is cancelled
    /// when the view disappears.
    ///
    /// If the given presenter is not in the view hierarchy at the time this method is invoked, the subscription is immediately
    /// terminated.
    ///
    ///  - note: Dependent on proper binding of the `ViewTracker` to the returned `Viewable` reference.
    ///
    /// - parameter presenter: The presenter to cancel the subscription based on.
    @discardableResult
    public func cancelOnDisappear(presenter: BasePresenter) -> Self {
        if let viewAppearanceCancellable = presenter.viewAppearanceCancellable {
            viewAppearanceCancellable.insert(self)
        } else {
            cancel()
            print("Subscription immediately terminated, since \(presenter)'s view is not displayed.")
        }
        return self
    }
    
    /// Cancels the subscription when `Presenter` is released.
    @discardableResult
    public func cancelOnDeinit(presenter: BasePresenter) -> Self {
        presenter.deinitCancellable.insert(self)
        return self
    }
}
