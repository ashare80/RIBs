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

protocol RootPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class RootPresenter: Presenter<RootView>, ViewPresentable, RootPresentable {
    @Published var presentedPresenter: Presentable?

    weak var listener: RootPresentableListener?

    // MARK: - RootPresentable

    func present(presenter: Presentable) {
        presentedPresenter = presenter
    }

    func dismiss(presenter: Presentable) {
        if presentedPresenter === presenter {
            presentedPresenter = nil
        }
    }
}

// MARK: LoggedInPresentable

extension RootPresenter: LoggedInPresentable {}

struct RootView: PresenterView {
    @ObservedObject var presenter: RootPresenter

    var body: some View {
        presenter.presentedPresenter?.viewable.asAnyView
    }
}

// MARK: - Preview

#if DEBUG
    struct RootView_Previews: PreviewProvider {
        static var previews: some View {
            RootView(presenter: RootPresenter())
        }
    }
#endif
