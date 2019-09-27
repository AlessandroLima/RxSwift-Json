//
//  RepositoriesRouter.swift
//  TesteJson
//
//  Created by Alessandro on 06/09/19.
//  Copyright © 2019 Alessandro. All rights reserved.
//

import Foundation
import UIKit

protocol RepositoriesRouterProtocol {
    func list()
}
protocol RxRepositoriesRouterProtocol {
    func listRx()
}


class RepositoriesRouter: UINavigationController, RepositoriesRouterProtocol,RxRepositoriesRouterProtocol {
    
    // MARK: Properties
    
    var window: UIWindow?
    var repositoriesViewController:RepositoriesViewController?
    var rxRepositoriesViewController:RxRepositoriesViewController?
    
    // MARK: Initializers
    
    convenience init(window: UIWindow?) {
        self.init()
        self.window = window
    }
    
    
    // MARK: Functions
    
    func list() {
        
        repositoriesViewController = RepositoriesViewController()
        if let repositoriesViewController = repositoriesViewController {
            repositoriesViewController.navigationItem.title = "Repositórios"
            repositoriesViewController.title = "Repositórios"
            viewControllers = [repositoriesViewController]
        }
        
        if let window = window {
            window.rootViewController = self
        }
    }
    
    func listRx() {
        
        rxRepositoriesViewController = RxRepositoriesViewController()
        if let rxRepositoriesViewController = rxRepositoriesViewController {
            rxRepositoriesViewController.navigationItem.title = "Repositórios"
            rxRepositoriesViewController.title = "Repositórios"
            viewControllers = [rxRepositoriesViewController]
        }
        
        if let window = window {
            window.rootViewController = self
        }
    }
}
