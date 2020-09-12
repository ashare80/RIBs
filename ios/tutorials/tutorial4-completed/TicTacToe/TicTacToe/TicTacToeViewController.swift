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

protocol TicTacToePresentableListener: AnyObject {
    func placeCurrentPlayerMark(atRow row: Int, col: Int)
    func closeGame()
}

final class TicTacToePresenter: Presenter<TicTacToeView>, ViewPresentable, TicTacToePresentable {
    @Published var gameWinnerTitle: String?
    @Published var playerSelection: [Coordinate: PlayerType] = [:]
    weak var listener: TicTacToePresentableListener?
    
    private let player1Name: String
    private let player2Name: String
    
    init(player1Name: String,
         player2Name: String) {
        self.player1Name = player1Name
        self.player2Name = player2Name
    }

    // MARK: - TicTacToePresentable

    func setCell(atRow row: Int, col: Int, withPlayerType playerType: PlayerType) {
        playerSelection[Coordinate(x: col, y: row)] = playerType
    }
    
    func announce(winner: PlayerType?) {
        if let winner = winner {
            switch winner {
            case .player1:
                gameWinnerTitle = "\(player1Name) Won!"
            case .player2:
                gameWinnerTitle = "\(player2Name) Won!"
            }
        } else {
            gameWinnerTitle = "It's a Tie"
        }
    }
}

extension String: Identifiable {
    public var id: String { return self }
}

struct TicTacToeView: PresenterView {
    @ObservedObject var presenter: TicTacToePresenter
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(0..<GameConstants.rowCount) { y in
                HStack(alignment: .center, spacing: 0) {
                    ForEach(0..<GameConstants.colCount) { x in
                        Button(action: {
                            self.presenter.listener?.placeCurrentPlayerMark(atRow: y, col: x)
                        }) {
                            self.presenter.playerSelection[Coordinate(x: x, y: y)].color
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1.0, contentMode: .fit)
                                .border(Color.gray, width: 2)
                        }
                    }
                }
            }
        }
        .alert(item: $presenter.gameWinnerTitle, content: { (title) -> Alert in
            Alert(title: Text(title), message: nil, dismissButton: .default(Text("Close Game"), action: {
                self.presenter.listener?.closeGame()
            }))
        })
    }
}

struct Coordinate: Hashable {
    var x: Int
    var y: Int
}

extension Optional where Wrapped == PlayerType {
    var color: Color {
        return self?.color ?? .white
    }
}

extension PlayerType {
    var color: Color {
        switch self {
        case .player1:
            return .red
        case .player2:
            return .blue
        }
    }

    var name: String {
        switch self {
        case .player1:
            return "Red"
        case .player2:
            return "Blue"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TicTacToeView_Previews: PreviewProvider {
    static var previews: some View {
        TicTacToeView(presenter: TicTacToePresenter(player1Name: "player1Name",
                                                    player2Name: "player2Name"))
    }
}
#endif
