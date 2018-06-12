//
//  BlockTask.swift
//  WaterfallTask
//
//  Created by Melvin John on 21/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

struct Job {
    
    typealias ThrowableBlock = (TaskResult) throws -> Any
    
    static func throwableTask(withThrowableBlock block: @escaping ThrowableBlock) -> Tasker.JobType {
        
        return { result in
            return BlockTask {
                do{
                    result.continueWithResults(.success(try block(result)))
                } catch let error {
                    result.continueWithResults(.failure(error))
                }
                
            }
        }
        
    }
    
}

public class BlockTask: Task {
    
    public typealias ExecutionType = () -> Void

    public var isRunning: Bool = false
    
    /// A boolean indicating if the task has been cancelled.
    public var isCancelled: Bool = false
    
    /// The execution block.
    public var execution: ExecutionType
    
    public init(execution: @escaping ExecutionType) {
        self.execution = execution
    }
    
    /// Start the task
    open func start() {
        
        guard !isCancelled else {
            return
        }
        
        isRunning = true
        execution()
        isRunning = false
    }
    
    /// Resume a currently non-started or cancelled task.
    open func resume() {
        isCancelled = false
        start()
    }
    
    /// Cancels the task. This stops the sync task executing.
    open func cancel() {
        isCancelled = true
    }
    
}
