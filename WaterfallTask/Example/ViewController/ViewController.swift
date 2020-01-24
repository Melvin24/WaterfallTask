//
//  ViewController.swift
//  WaterfallTask
//
//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let networkService = JSONNetworkService()
        
        task = networkService.fetchSomeJSON { commentsResult in
            switch commentsResult {
            case .success(let comments):
                comments.forEach {
                    print($0.id, ", ")
                }
            case .failure(let error):
                print(error)
            }
        }
        
        task?.start()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        task?.cancel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        task?.resume()
    }
    
    
}

