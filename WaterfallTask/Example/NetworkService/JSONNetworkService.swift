//
//  SomeJSONNetworkService.swift
//  WaterfallTask
//
//  Created by Melvin John on 23/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

class JSONNetworkService {
    
    enum JSONNetworkServiceError: Error {
        case failedToSendRequest
        case invalidUserInfo(result: Any?, expected: Any.Type)
        case noData
        case failedToParseData
    }
    
    typealias Completion = (Result<[Comment]>) -> Void
    
    func fetchSomeJSON(completion: @escaping Completion) -> Task {
        
        let URLPath = "https://jsonplaceholder.typicode.com/comments"
        
        let waterfallTask = Waterfall(with: URLPath, completionBlock: completion)
        
        waterfallTask.add(jobs: [
            self.makeGetRequestTask(),
            self.performNetworkRequestTask(),
            self.parseResponseTask()
        ])

        return waterfallTask
    }
    
    private func makeGetRequestTask() -> Tasker.JobType {
        
        return Job.throwableTask { result in
            
            guard let urlPath = result.userInfo as? String,
                let url = URL(string: urlPath) else {
                    throw JSONNetworkServiceError.failedToSendRequest
            }
            
            let request = URLRequest(url: url,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: 60)
            
            return request
            
        }
    }
    
    private func performNetworkRequestTask(usingSession session: URLSession = .shared) -> Tasker.JobType {
        
        return { result in
            
            guard let urlRequest = result.userInfo as? URLRequest else {
                throw JSONNetworkServiceError.failedToSendRequest
            }
            
            return session.dataTask(with: urlRequest) { data, response, error in
                
                switch (data, response, error) {
                case (.some(let responseData), _, _):
                    result.continueWithResults(.success(responseData))
                case (_, _, .some(let requestError)):
                    result.continueWithResults(.failure(requestError))
                default:
                    result.continueWithResults(.failure(JSONNetworkServiceError.noData))
                }
                
            }
            
        }
        
    }
    
    private func parseResponseTask() -> Tasker.JobType {
        return Job.throwableTask { result in
            
            guard let requestResponseData = result.userInfo as? Data else {
                throw JSONNetworkServiceError.failedToSendRequest
            }
            
            return try JSONDecoder().decode([Comment].self, from: requestResponseData)
            
        }
    }
    
}
