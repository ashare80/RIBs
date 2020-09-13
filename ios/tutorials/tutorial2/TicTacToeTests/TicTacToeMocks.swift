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
import RIBs
import SwiftUI
@testable import TicTacToe

// MARK: - LoggedInBuildableMock class

/// A LoggedInBuildableMock class used for testing.
class LoggedInBuildableMock: LoggedInBuildable {
    // Function Handlers
    var buildHandler: ((_ listener: LoggedInListener) -> LoggedInRouting)?
    var buildCallCount: Int = 0

    init() {}

    func build(withListener listener: LoggedInListener) -> LoggedInRouting {
        buildCallCount += 1
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        fatalError("Function build returns a value that can't be handled with a default value and its handler must be set")
    }
}

// MARK: - LoggedInInteractableMock class

/// A LoggedInInteractableMock class used for testing.
class LoggedInInteractableMock: LoggedInInteractable {
    // Variables
    var router: LoggedInRouting? { didSet { routerSetCallCount += 1 } }
    var routerSetCallCount = 0
    var listener: LoggedInListener? { didSet { listenerSetCallCount += 1 } }
    var listenerSetCallCount = 0
    var isActive: Bool = false { didSet { isActiveSetCallCount += 1 } }
    var isActiveSetCallCount = 0
    var isActiveStreamSubject = PassthroughSubject<Bool, Never>() { didSet { isActiveStreamSubjectSetCallCount += 1 } }
    var isActiveStreamSubjectSetCallCount = 0
    var isActiveStream: AnyPublisher<Bool, Never> { return isActiveStreamSubject.eraseToAnyPublisher() }

    // Function Handlers
    var activateHandler: (() -> Void)?
    var activateCallCount: Int = 0
    var deactivateHandler: (() -> Void)?
    var deactivateCallCount: Int = 0
    var startTicTacToeHandler: (() -> Void)?
    var startTicTacToeCallCount: Int = 0
    var gameDidEndHandler: (() -> Void)?
    var gameDidEndCallCount: Int = 0

    init() {}

    func activate() {
        activateCallCount += 1
        if let activateHandler = activateHandler {
            return activateHandler()
        }
    }

    func deactivate() {
        deactivateCallCount += 1
        if let deactivateHandler = deactivateHandler {
            return deactivateHandler()
        }
    }

    func startTicTacToe() {
        startTicTacToeCallCount += 1
        if let startTicTacToeHandler = startTicTacToeHandler {
            return startTicTacToeHandler()
        }
    }

    func gameDidEnd() {
        gameDidEndCallCount += 1
        if let gameDidEndHandler = gameDidEndHandler {
            return gameDidEndHandler()
        }
    }
}

// MARK: - LoggedInRoutingMock class

/// A LoggedInRoutingMock class used for testing.
class LoggedInRoutingMock: LoggedInRouting {
    // Variables
    var interactable: Interactable { didSet { interactableSetCallCount += 1 } }
    var interactableSetCallCount = 0
    var children = [Routing]() { didSet { childrenSetCallCount += 1 } }
    var childrenSetCallCount = 0
    var lifecycleSubject = PassthroughSubject<RouterLifecycle, Never>() { didSet { lifecycleSubjectSetCallCount += 1 } }
    var lifecycleSubjectSetCallCount = 0
    var lifecycle: AnyPublisher<RouterLifecycle, Never> { return lifecycleSubject.eraseToAnyPublisher() }

    // Function Handlers
    var cleanupViewsHandler: (() -> Void)?
    var cleanupViewsCallCount: Int = 0
    var routeToTicTacToeHandler: (() -> Void)?
    var routeToTicTacToeCallCount: Int = 0
    var routeToOffGameHandler: (() -> Void)?
    var routeToOffGameCallCount: Int = 0
    var loadHandler: (() -> Void)?
    var loadCallCount: Int = 0
    var attachChildHandler: ((_ child: Routing) -> Void)?
    var attachChildCallCount: Int = 0
    var detachChildHandler: ((_ child: Routing) -> Void)?
    var detachChildCallCount: Int = 0

    init(interactable: Interactable) {
        self.interactable = interactable
    }

    func cleanupViews() {
        cleanupViewsCallCount += 1
        if let cleanupViewsHandler = cleanupViewsHandler {
            return cleanupViewsHandler()
        }
    }

    func routeToTicTacToe() {
        routeToTicTacToeCallCount += 1
        if let routeToTicTacToeHandler = routeToTicTacToeHandler {
            return routeToTicTacToeHandler()
        }
    }

    func routeToOffGame() {
        routeToOffGameCallCount += 1
        if let routeToOffGameHandler = routeToOffGameHandler {
            return routeToOffGameHandler()
        }
    }

    func load() {
        loadCallCount += 1
        if let loadHandler = loadHandler {
            return loadHandler()
        }
    }

    func attachChild(_ child: Routing) {
        attachChildCallCount += 1
        if let attachChildHandler = attachChildHandler {
            return attachChildHandler(child)
        }
    }

    func detachChild(_ child: Routing) {
        detachChildCallCount += 1
        if let detachChildHandler = detachChildHandler {
            return detachChildHandler(child)
        }
    }
}

// MARK: - LoggedOutBuildableMock class

/// A LoggedOutBuildableMock class used for testing.
class LoggedOutBuildableMock: LoggedOutBuildable {
    // Function Handlers
    var buildHandler: ((_ listener: LoggedOutListener) -> LoggedOutRouting)?
    var buildCallCount: Int = 0

    init() {}

    func build(withListener listener: LoggedOutListener) -> LoggedOutRouting {
        buildCallCount += 1
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        fatalError("Function build returns a value that can't be handled with a default value and its handler must be set")
    }
}

// MARK: - RootInteractableMock class

/// A RootInteractableMock class used for testing.
class RootInteractableMock: RootInteractable {
    // Variables
    var router: RootRouting? { didSet { routerSetCallCount += 1 } }
    var routerSetCallCount = 0
    var listener: RootListener? { didSet { listenerSetCallCount += 1 } }
    var listenerSetCallCount = 0
    var isActive: Bool = false { didSet { isActiveSetCallCount += 1 } }
    var isActiveSetCallCount = 0
    var isActiveStreamSubject = PassthroughSubject<Bool, Never>() { didSet { isActiveStreamSubjectSetCallCount += 1 } }
    var isActiveStreamSubjectSetCallCount = 0
    var isActiveStream: AnyPublisher<Bool, Never> { return isActiveStreamSubject.eraseToAnyPublisher() }

    // Function Handlers
    var activateHandler: (() -> Void)?
    var activateCallCount: Int = 0
    var deactivateHandler: (() -> Void)?
    var deactivateCallCount: Int = 0
    var didLoginHandler: ((_ player1Name: String, _ player2Name: String) -> Void)?
    var didLoginCallCount: Int = 0

    init() {}

    func activate() {
        activateCallCount += 1
        if let activateHandler = activateHandler {
            return activateHandler()
        }
    }

    func deactivate() {
        deactivateCallCount += 1
        if let deactivateHandler = deactivateHandler {
            return deactivateHandler()
        }
    }

    func didLogin(withPlayer1Name player1Name: String, player2Name: String) {
        didLoginCallCount += 1
        if let didLoginHandler = didLoginHandler {
            return didLoginHandler(player1Name, player2Name)
        }
    }
}

// MARK: - RootPresentableMock class

struct ViewableMock: Viewable {
    let asAnyPresenter: AnyView = EmptyView().asAnyView
}

/// A RootPresentableMock class used for testing.
class RootPresentableMock: RootPresentable {
    // Variables
    var view: Viewable = ViewableMock() { didSet { viewSetCallCount += 1 } }
    var viewSetCallCount = 0

    // Function Handlers
    var presentHandler: ((_ presenter: Presentable) -> Void)?
    var presentCallCount: Int = 0
    var dismissHandler: ((_ presenter: Presentable) -> Void)?
    var dismissCallCount: Int = 0

    init() {}

    func present(presenter _: Presentable) {
        presentCallCount += 1
        if let presentHandler = presentHandler {
            return presentHandler(view)
        }
    }

    func dismiss(presenter _: Presentable) {
        dismissCallCount += 1
        if let dismissHandler = dismissHandler {
            return dismissHandler(view)
        }
    }
}
