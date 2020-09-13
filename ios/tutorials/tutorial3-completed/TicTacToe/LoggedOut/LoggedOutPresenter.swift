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

protocol LoggedOutPresentableListener: AnyObject {
    func login(withPlayer1Name: String?, player2Name: String?)
}

final class LoggedOutPresenter: Presenter<LoggedOutView>, ViewPresentable, LoggedOutPresentable {
    weak var listener: LoggedOutPresentableListener?

    @Published var player1: String = ""
    @Published var player2: String = ""

    func loginButtonTouchUpInside() {
        listener?.login(withPlayer1Name: player1, player2Name: player2)
    }
}

struct LoggedOutView: PresenterView {
    @ObservedObject var presenter: LoggedOutPresenter

    var body: some View {
        VStack {
            TextField("Player 1 name", text: $presenter.player1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Player 2 name", text: $presenter.player2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: presenter.loginButtonTouchUpInside,
                   label: {
                       Text("Login")
                           .padding(8)
                           .frame(maxWidth: .infinity)
                           .background(Color.black)
                           .foregroundColor(Color.white)
                   })
        }
        .background(Color.white)
        .padding(16)
    }
}
