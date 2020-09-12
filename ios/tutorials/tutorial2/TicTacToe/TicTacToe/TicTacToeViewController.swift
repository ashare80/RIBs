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
    @Published var gameWinner: PlayerType?
    @Published var playerSelection: [Coordinate: PlayerType] = [:]
    weak var listener: TicTacToePresentableListener?

    // MARK: - TicTacToePresentable

    func setCell(atRow row: Int, col: Int, withPlayerType playerType: PlayerType) {
        playerSelection[Coordinate(x: col, y: row)] = playerType
    }

    func announce(winner: PlayerType) {
        gameWinner = winner
    }
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
                            EmptyView()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .background(self.presenter.playerSelection[Coordinate(x: x, y: y)].color)
                                .border(Color.gray, width: 2)
                        }
                    }
                }
            }
        }
        .background(Color.yellow)
        .alert(item: $presenter.gameWinner, content: { (winner) -> Alert in
            Alert(title: Text("\(winner.name) Won!"), message: nil, dismissButton: .default(Text("Close Game"), action: {
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
        case .red:
            return .red
        case .blue:
            return .blue
        }
    }

    var name: String {
        switch self {
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TicTacToeView_Previews: PreviewProvider {
    static var previews: some View {
        TicTacToeView(presenter: TicTacToePresenter())
    }
}
#endif
