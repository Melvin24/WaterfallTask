//
//  Waterfall.swift
//  WaterfallTask
//
//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

public class Waterfall<T>: Task {
    
    //********** HELPERS *********
    
    public enum TaskError: Error {
        case noResult
    }
    
    public typealias JobType = Tasker.JobType
    
    public typealias CompletionType = (Result<T>) -> Void
    
    //*****************************
    
    
    public var isRunning: Bool = false
    
    public var isCancelled: Bool = false
    
    private lazy var jobs: [JobType] = []
    
    private var currentJobTask: Task?
    
    private let userInfo: Any?
    
    private var completionBlock: CompletionType
    
    /// Initialise with a userInfo to pass into the first task.
    public init(with userInfo: Any? = nil,
                completionBlock: @escaping CompletionType) {
        
        self.userInfo = userInfo
        self.completionBlock = completionBlock
        
    }
    
    private func finish(userInfo: Any? = nil,
                        error: Error? = nil) {
        
        self.isRunning = false
        self.currentJobTask = nil

        switch (userInfo, error) {
        case (.some(let completionValue as T), _):
            
            completionBlock(.success(completionValue))
        case (_, .some(let error)):
            
            completionBlock(.failure(error))
        default:
            
            completionBlock(.failure(TaskError.noResult))
        }
        
    }

    private func continueBlock(_ userInfo: Any?) -> Void {
        
        guard !self.isCancelled else {
            self.isRunning = false
            return
        }
        
        guard self.jobs.count > 0 else {
            self.finish(userInfo: userInfo)
            return
        }
        
        let result = TaskResult(currentTask: self,
                                 userInfo: userInfo) { [weak self] currentTaskResult in
            
            switch currentTaskResult {
            case .success(let result):
                
                self?.continueBlock(result)
            case .failure(let error):
                
                self?.finish(error: error)
            }
            
        }
        
        do {
            self.currentJobTask = try self.jobs.removeFirst()(result)
            self.currentJobTask?.resume()
        } catch let error {
            
            self.finish(error: error)
        }
        
    }
    
    //MARK: Task
    public func start() {
        guard currentJobTask == nil else {
            assertionFailure("Waterfall is already executing, suspended or cancelled")
            return
        }
        
        isRunning = true
        
        continueBlock(userInfo)
    }
    
    public func resume() {
        
        if let current = currentJobTask {
            current.resume()
        } else {
            start()
        }
    }
    
    public func cancel() {
        isRunning = false
        isCancelled = true
        currentJobTask?.cancel()
    }

}

extension Waterfall: Tasker {
    
    
    /// Adds a single task to the waterfall to be executed.
    ///
    /// - parameter job: The function to execute.
    public func add(job: @escaping JobType) {
        self.jobs.append(job)
    }
    
    /// Adds all task to the waterfall to be executed.
    ///
    /// - parameter jobs: The list of functions to execute.
    public func add(jobs: [JobType]) {
        self.jobs.append(contentsOf: jobs)
    }
    
}
