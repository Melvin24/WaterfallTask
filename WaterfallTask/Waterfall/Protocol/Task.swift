//
//  Task.swift
//  WaterfallTask
//
//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

/// A Task represents any syncronus or asyncronus object so we can cancel, suspend and resume.
public protocol Task {
    
    /// Determines whether the task is running.
    var isRunning: Bool { get }
    
    /// Boolean stating if the task was cancelled.
    var isCancelled: Bool { get }
    
    /// Start the task
    func start()
    
    /// Resume a currently suspended or non-started task.
    func resume()
    
    /// Cancels the task.
    func cancel()
    
}

extension URLSessionTask: Task {
    
    public var isRunning: Bool {
        return state == .running
    }
    
    public var isCancelled: Bool {
        return !isRunning
    }
    
    public func start() {
        self.resume()
    }
    
    
}
