//
//  CanPerformJobs.swift
//  WaterfallTask
//
//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

public protocol Tasker: class {
    
    typealias JobType = (TaskResult) throws -> Task
    
    /// Adds a task to to be executed.
    ///
    /// - parameter job: The function to execute.
    func add(job: @escaping JobType)
    
    /// Adds all tasks to be executed.
    ///
    /// - parameter jobs: The list of functions to execute.
    func add(jobs: [JobType])
    
}
