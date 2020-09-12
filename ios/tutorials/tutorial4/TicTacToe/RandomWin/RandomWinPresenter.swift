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

protocol RandomWinPresentableListener: AnyObject {
    func determineWinner()
    func closedAlert()
}

final class RandomWinPresenter: Presenter<RandomWinView>, ViewPresentable, RandomWinPresentable {

    weak var listener: RandomWinPresentableListener?
    
    @Published var winnerText: String?
    
    private let player1Name: String
    private let player2Name: String
    
    init(player1Name: String,
         player2Name: String) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        super.init()
    }

    // MARK: - RandomWinPresentable

    func announce(winner: PlayerType) {
        winnerText = {
            switch winner {
            case .player1:
                return "\(player1Name) Won!"
            case .player2:
                return "\(player2Name) Won!"
            }
        }()
    }
}

struct RandomWinView: PresenterView {
    
    @ObservedObject var presenter: RandomWinPresenter
    
    var body: some View {
        VStack {
            Button(action: {
                self.presenter.listener?.determineWinner()
            }, label: {
                Text("Magic")
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(Color.white)
            })
                .alert(item: $presenter.winnerText) { (text) -> Alert in
                    Alert(title: Text(text), message: nil, dismissButton: .default(Text("That was random..."), action: {
                        self.presenter.listener?.closedAlert()
                    }))
            }
        }
        .background(Color.white)
        .padding(16)
    }
}

// MARK: - Preview

#if DEBUG
struct RandomWinView_Previews: PreviewProvider {
    static var previews: some View {
        RandomWinView(presenter: RandomWinPresenter(player1Name: "player1Name", player2Name: "player2Name"))
    }
}
#endif
