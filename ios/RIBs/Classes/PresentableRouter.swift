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

import Combine
import SwiftUI

/// The base protocol for all routers that own their own view controllers.
public protocol PresentableRouting: Routing {
    // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
    // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
    // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
    // base class logic without error.

    /// The base view associated with this `Router`.
    var presentable: Presentable { get }
}

/// The base class of all routers that owns view controllers, representing application states.
///
/// A `Router` acts on inputs from its corresponding interactor, to manipulate application state and view state,
/// forming a tree of routers that drives the tree of view controllers. Router drives the lifecycle of its owned
/// interactor. `Router`s should always use helper builders to instantiate children `Router`s.
open class PresentableRouter<InteractorType, PresenterType>: Router<InteractorType>, PresentableRouting {
    /// The corresponding `Presenter` owned by this `Router`.
    public let presenter: PresenterType

    /// The corresponding `Presentable` owned by this `Router`.
    public let presentable: Presentable

    /// Initializer.
    ///
    /// - parameter interactor: The corresponding `Interactor` of this `Router`.
    /// - parameter presenter: The corresponding `Presenter` of this `Router`.
    public init(interactor: InteractorType, presenter: PresenterType) {
        self.presenter = presenter
        guard let presentable = presenter as? Presentable else {
            fatalError("\(presenter) should conform to \(Presentable.self)")
        }
        self.presentable = presentable
        super.init(interactor: interactor)
    }

    // MARK: - Internal

    override func internalDidLoad() {
        setupViewLeakDetection()

        super.internalDidLoad()
    }

    // MARK: - Private

    private var viewDisappearExpectation: LeakDetectionHandle?

    private func setupViewLeakDetection() {
        guard let viewTracker = presenter as? ViewTracking else {
            print("\(presenter) does not conform to `ViewTracking` to expect view disappear.")
            return
        }

        let disposable = interactable.isActiveStream
            // Do not retain self here to guarantee execution. Retaining self will cause the cancel bag to never be
            // cancelled, thus self is never deallocated. Also cannot just store the disposable and call cancel(),
            // since we want to keep the subscription alive until deallocation, in case the router is re-attached.
            // Using weak does require the router to be retained until its interactor is deactivated.
            .sink(receiveValue: { [weak self] (isActive: Bool) in
                guard let self = self else { return }

                self.viewDisappearExpectation?.cancel()
                self.viewDisappearExpectation = nil

                if !isActive {
                    self.viewDisappearExpectation = LeakDetector.instance.expectViewDisappear(tracker: viewTracker)
                }
            })
        deinitCancellable.insert(disposable)
    }

    deinit {
        LeakDetector.instance.expectDeallocate(object: presenter as AnyObject, inTime: LeakDefaultExpectationTime.viewDisappear)
    }
}
