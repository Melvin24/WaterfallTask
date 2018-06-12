//
//  TaskResult.swift
//  WaterfallTask
//
//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

/// A wrapper to hold onto the result object
public struct TaskResult {
    
    public typealias ContinueWithResultsType = (Result<Any>) -> Void
    
    /// The waterfall/parallel/other object associated with the result
    public var currentTask: Task?
    
    /// The data object of the previous function
    public var userInfo: Any?
    
    /// This is executed to let the waterfall know it has finished its task
    public var continueWithResults: ContinueWithResultsType

    public init(currentTask: Task?, userInfo: Any?, continueWithResults: @escaping ContinueWithResultsType) {
        self.currentTask = currentTask
        self.userInfo = userInfo
        self.continueWithResults = continueWithResults
    }
    
}
