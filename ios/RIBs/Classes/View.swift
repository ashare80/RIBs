//
//  File.swift
//  
//
//  Created by Adam Share on 9/10/20.
//

import Foundation
import SwiftUI

/// Type erased `View`.
public protocol Viewable {
    /// Wraps in `AnyView`.
    var asAnyView: AnyView { get }
}

extension AnyView: Viewable {
    public var asAnyView: AnyView {
        return self
    }
}

/// Convenience protocol for a `View ` with only a `Presenter` dependency.
public protocol PresenterView: View {
    
    /// `ObservableObject` presenter to bind to the `View` .
    associatedtype PresenterType: ObservableObject
    
    /// Initializes with an observable presenter.
    init(presenter: PresenterType)
}

extension View {
    public var asAnyView: AnyView {
        return AnyView(self)
    }
}

extension ViewTracking {
    public func tracked<V: View>(_ view: V) -> some View {
        return view.onAppear {
            self.isDisplayed = true
        }
        .onDisappear {
            self.isDisplayed = false
        }
    }
}
