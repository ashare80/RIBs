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

protocol OffGameInteractable: Interactable {
    var router: OffGameRouting? { get set }
    var listener: OffGameListener? { get set }
}

final class OffGameRouter: PresentableRouter<OffGameInteractable, OffGamePresentable>, OffGameRouting {
    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: OffGameInteractable, presenter: OffGamePresentable) {
        super.init(interactor: interactor, presenter: presenter)
        interactor.router = self
    }
}
