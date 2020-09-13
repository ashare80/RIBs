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

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window

            let launchRouter = RootBuilder(dependency: AppComponent()).build()
            self.launchRouter = launchRouter
            launchRouter.launch(from: window)
        }
    }
}
