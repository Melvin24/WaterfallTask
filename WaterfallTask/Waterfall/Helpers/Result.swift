//
//  Result.swift
//  WaterfallTask
//
//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

/// A Result Type
public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

extension Result {
    
    /// Evaluates the given closure when this Result is `.success`, passing the
    /// unwrapped value as a parameter.
    ///
    /// - Parameter transform: A closure that takes the unwrapped success value.
    /// - Returns: The result of the given closure. If the instance is `failure`
    ///   returns the failure.
    public func map<T>(transform: (Value) -> T) -> Result<T> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Evaluates the given closure when this Result is `.success`, passing the
    /// unwrapped value as a parameter.
    ///
    /// - Parameter transform: A closure that takes the unwrapped success value.
    /// - Returns: The result of the given closure. If the instance is `failure`
    ///   returns the failure.
    public func flatMap<T>(transform: (Value) -> Result<T>) -> Result<T> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
    
}
