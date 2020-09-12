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
import SwiftUI

protocol OffGamePresentableListener: AnyObject {
    func start(_ game: Game)
}

final class OffGamePresenter: Presenter<OffGameView>, ViewPresentable, OffGamePresentable {

    weak var listener: OffGamePresentableListener?
    
    @Published var scoreBoardPresenter: Presentable?

    init(games: [Game]) {
        self.games = games
        super.init()
    }

    func show(scoreBoardPresenter: Presentable) {
        self.scoreBoardPresenter = scoreBoardPresenter
    }

    // MARK: - Private

    let games: [Game]
}

struct OffGameView: PresenterView {
    @ObservedObject var presenter: OffGamePresenter
    
    var body: some View {
        VStack {
            presenter.scoreBoardPresenter?.viewable.asAnyView
            ForEach(0..<presenter.games.count) { index in
                Button(action: {
                    self.presenter.listener?.start(self.presenter.games[index])
                }, label: {
                    Text("Start Game")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(Color.white)
                })
                .padding(8)
            }
        }
        .background(Color.white)
        .padding(16)
    }
}
