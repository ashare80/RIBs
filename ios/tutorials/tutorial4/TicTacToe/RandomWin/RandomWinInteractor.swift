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
import RIBs

public protocol RandomWinRouting: PresentableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RandomWinPresentable: Presentable {
    var listener: RandomWinPresentableListener? { get set }
    func announce(winner: PlayerType)
}

public protocol RandomWinListener: AnyObject {
    func didRandomlyWin(with player: PlayerType)
}

final class RandomWinInteractor: PresentableInteractor<RandomWinPresentable>, RandomWinInteractable, RandomWinPresentableListener {

    weak var router: RandomWinRouting?

    weak var listener: RandomWinListener?

    init(presenter: RandomWinPresentable,
         mutableScoreStream: MutableScoreStream) {
        self.mutableScoreStream = mutableScoreStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    // MARK: - RandomWinPresentableListener
    
    var winner: PlayerType?

    func determineWinner() {
        let random = arc4random_uniform(100)
        let winner: PlayerType = random > 50 ? .player1 : .player2
        self.winner = winner
        presenter.announce(winner: winner)
    }
    
    func closedAlert() {
        guard let winner = winner else { return }
        self.mutableScoreStream.updateScore(with: winner)
        self.listener?.didRandomlyWin(with: winner)
    }

    // MARK: - Private

    private let mutableScoreStream: MutableScoreStream
}
