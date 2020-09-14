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

protocol LoggedInInteractable: Interactable, OffGameListener, TicTacToeListener {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}

protocol LoggedInPresentable: Presentable {
    func present(presenter: Presentable)
    func dismiss(presenter: Presentable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {
    init(interactor: LoggedInInteractable,
         presenter: LoggedInPresentable,
         offGameBuilder: OffGameBuildable,
         ticTacToeBuilder: TicTacToeBuildable)
    {
        self.presenter = presenter
        self.offGameBuilder = offGameBuilder
        self.ticTacToeBuilder = ticTacToeBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
        attachOffGame()
    }

    // MARK: - LoggedInRouting

    func cleanupViews() {
        if let currentChild = currentChild {
            presenter.dismiss(presenter: currentChild.presentable)
        }
    }

    func routeToTicTacToe() {
        detachCurrentChild()

        let ticTacToe = ticTacToeBuilder.build(withListener: interactor)
        currentChild = ticTacToe
        attachChild(ticTacToe)
        presenter.present(presenter: ticTacToe.presentable)
    }

    func routeToOffGame() {
        detachCurrentChild()
        attachOffGame()
    }

    // MARK: - Private

    private let presenter: LoggedInPresentable
    private let offGameBuilder: OffGameBuildable
    private let ticTacToeBuilder: TicTacToeBuildable

    private var currentChild: PresentableRouting?

    private func attachOffGame() {
        let offGame = offGameBuilder.build(withListener: interactor)
        currentChild = offGame
        attachChild(offGame)
        presenter.present(presenter: offGame.presentable)
    }

    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            presenter.dismiss(presenter: currentChild.presentable)
        }
    }
}
