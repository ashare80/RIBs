//
//  SceneDelegate.swift
//  TicTacToe
//
//  Created by Adam Share on 9/9/20.
//  Copyright © 2020 Uber. All rights reserved.
//

import RIBs
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var launchRouter: LaunchRouting?
    private var urlHandler: UrlHandler?

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window

            let result = RootBuilder(dependency: AppComponent()).build()
            launchRouter = result.launchRouter
            urlHandler = result.urlHandler
            result.launchRouter.launch(from: window)
        }
    }

    public func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        urlHandler?.handle(url)
        return true
    }
}

protocol UrlHandler: AnyObject {
    func handle(_ url: URL)
}
