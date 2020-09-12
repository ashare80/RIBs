//___FILEHEADER___

import RIBs

protocol ___VARIABLE_productName___Interactable: Interactable {
    var router: ___VARIABLE_productName___Routing? { get set }
    var listener: ___VARIABLE_productName___Listener? { get set }
}

protocol ___VARIABLE_productName___Viewable: Viewable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ___VARIABLE_productName___Router: PresentableRouter<___VARIABLE_productName___Interactable, ___VARIABLE_productName___Viewable>, ___VARIABLE_productName___Routing {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ___VARIABLE_productName___Interactable, presenter: ___VARIABLE_productName___Viewable) {
        super.init(interactor: interactor, presenter: presenter)
        interactor.router = self
    }
}
