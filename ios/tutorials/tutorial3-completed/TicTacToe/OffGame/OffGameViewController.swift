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
    func startGame()
}

final class OffGamePresenter: Presenter<OffGameView>, ViewPresentable, OffGamePresentable {

    weak var listener: OffGamePresentableListener?
    
    @Published var player1Text: String = ""
    @Published var player2Text: String = ""
    @Published var score: Score?
    
    private let player1Name: String
    private let player2Name: String
    
    init(player1Name: String, player2Name: String) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        super.init()
        setText(player1Score: 0, player2Score: 0)
    }

    func startButtonDidTouchUpInside() {
        listener?.startGame()
    }
    
    // MARK: - OffGamePresentable

    func set(score: Score) {
        self.score = score
        setText(player1Score: score.player1Score, player2Score: score.player2Score)
    }
    
    private func setText(player1Score: Int, player2Score: Int) {
        player1Text = "\(player1Name) (\(player1Score))"
        player2Text = "\(player2Name) (\(player2Score))"
    }
}

struct OffGameView: PresenterView {
    @ObservedObject var presenter: OffGamePresenter
    
    var body: some View {
        VStack {
            Text(presenter.player1Text)
            .padding(8)
            Text("vs")
            .padding(8)
            Text(presenter.player2Text)
            .padding(8)
            Button(action: {
                self.presenter.startButtonDidTouchUpInside()
            }, label: {
                Text("Start Game")
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(Color.white)
            })
            .padding(8)
        }
        .background(Color.white)
        .padding(16)
    }
}
