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

import SwiftUI

/// The root `Router` of an application.
public protocol LaunchRouting: PresentableRouting {
    /// Launches the router tree.
    ///
    /// - parameter window: The application window to launch from.
    func launch(from window: UIWindow)
}

/// The application root router base class, that acts as the root of the router tree.
open class LaunchRouter<InteractorType, PresenterType>: PresentableRouter<InteractorType, PresenterType>, LaunchRouting {
    /// Initializer.
    ///
    /// - parameter interactor: The corresponding `Interactor` of this `Router`.
    /// - parameter presenter: The corresponding `View` of this `Router`.
    override public init(interactor: InteractorType, presenter: PresenterType) {
        super.init(interactor: interactor, presenter: presenter)
    }

    /// Launches the router tree.
    ///
    /// - parameter window: The window to launch the router tree in.
    public final func launch(from window: UIWindow) {
        window.rootViewController = UIHostingController(rootView: presentable.viewable.asAnyView)
        window.makeKeyAndVisible()

        interactable.activate()
        load()
    }
}
