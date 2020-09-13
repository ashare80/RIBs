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

import RIBs

protocol RootInteractable: Interactable, LoggedOutListener, LoggedInListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
    func present(presenter: Presentable)
    func dismiss(presenter: Presentable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootPresentable>, RootRouting {
    init(interactor: RootInteractable,
         presenter: RootPresentable,
         loggedOutBuilder: LoggedOutBuildable,
         loggedInBuilder: LoggedInBuildable)
    {
        self.loggedOutBuilder = loggedOutBuilder
        self.loggedInBuilder = loggedInBuilder
        super.init(interactor: interactor, presenter: presenter)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()

        routeToLoggedOut()
    }

    func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String) -> LoggedInActionableItem {
        // Detach logged out.
        if let loggedOut = self.loggedOut {
            detachChild(loggedOut)
            presenter.dismiss(presenter: loggedOut.presentable)
            self.loggedOut = nil
        }

        let loggedIn = loggedInBuilder.build(withListener: interactor,
                                             player1Name: player1Name,
                                             player2Name: player2Name)
        attachChild(loggedIn.router)
        return loggedIn.actionableItem
    }

    // MARK: - Private

    private let loggedOutBuilder: LoggedOutBuildable
    private let loggedInBuilder: LoggedInBuildable

    private var loggedOut: PresentableRouting?

    private func routeToLoggedOut() {
        let loggedOut = loggedOutBuilder.build(withListener: interactor)
        self.loggedOut = loggedOut
        attachChild(loggedOut)
        presenter.present(presenter: loggedOut.presentable)
    }
}
