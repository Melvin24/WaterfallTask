
//  WaterfallTests.swift
//  WaterfallTaskTests

//  Created by Melvin John on 19/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.


import XCTest
@testable import WaterfallTask

class WaterfallTests: XCTestCase {
    
    func testDeinit() {
        
        class WaterfallMock: Waterfall<Any> {
            
            var didDeinitialise: () -> Void = { }
            
            deinit {
                didDeinitialise()
            }
            
        }
        
        let deinitExpectation     = expectation(description: "should deinitialise")
        let completionExpectation = expectation(description: "should execute the completion block")
        
        autoreleasepool {
            
            var waterfall: WaterfallMock? = WaterfallMock(with: "0") { _ in
                completionExpectation.fulfill()
            }
            
            waterfall?.add { (result) -> Task in
                
                BlockTask {
                    result.continueWithResults(.success("1"))
                }
            }
            
            waterfall?.didDeinitialise = {
                deinitExpectation.fulfill()
            }
                        
            waterfall?.start()
            
            waterfall = nil
            
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testRequestWithUserInfo() {
        
        let waterfall = Waterfall<[Int]>(with: [ 1, 2, 3 ]) { _ in
            
        }
        
        let resume = expectation(description: "resume is called")
        
        waterfall.add { result in
            
            XCTAssertEqual((result.userInfo as? [Int]) ?? [ ], [ 1, 2, 3 ])
            
            return BlockTask {
                resume.fulfill()
            }
            
        }
        
        waterfall.resume()
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testRequestWithoutUserInfo() {
        
        let waterfall = Waterfall<Any> { _ in
            
        }
        
        let resume = expectation(description: "resume is called")
        
        waterfall.add { result in
            
            XCTAssertNil(result.userInfo)
            
            return BlockTask {
                resume.fulfill()
            }
            
        }
        
        waterfall.start()
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testRequestWaterfall() {
        
        let waterfall = Waterfall<Any> { _ in
            
        }
        
        let resume = expectation(description: "resume is called")
        
        waterfall.add { result in
            BlockTask {
                result.continueWithResults(.success(1))
            }
        }
        
        waterfall.add { result in
            
            XCTAssertEqual(result.userInfo as? Int, 1)
            
            return BlockTask {
                resume.fulfill()
                result.continueWithResults(.success(1))
            }
        }
        
        waterfall.start()
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testRequestWaterfallCompletionBlock() {
        
        let completionBlock = expectation(description: "completionBlock is called")

        let waterfall = Waterfall<Int> { result in
            completionBlock.fulfill()
        }
        
        waterfall.add { result in
            BlockTask {
                result.continueWithResults(.success(1))
            }
        }
        
        waterfall.add { result in
            
            XCTAssertEqual(result.userInfo as? Int, 1)
            
            return BlockTask {
                result.continueWithResults(.success(1))
            }
        }
        
        waterfall.start()
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testRequestWaterfallErrorQuitsWaterfall() {
        
        enum TaskError: Error {
            
            case failed
            
        }
        
        let completionBlock = expectation(description: "completionBlock is called")

        let waterfall = Waterfall<Any> { result in
            
            switch result {
            case .success:
                XCTFail()
            default:
                completionBlock.fulfill()
            }
            
        }
        
        waterfall.add { result in
            BlockTask {
                result.continueWithResults(.failure(TaskError.failed))
            }
        }
        
        waterfall.add { result in
            XCTFail("should not execute the second job")
            return BlockTask { }
        }
        
        waterfall.start()
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testRequestWaterfallCancelQuitsWaterfall() {
        
//        let waterfall = Waterfall<Any> { _ in
//            XCTFail("should not execute the completion")
//        }
//
//        waterfall.add { result in
//            BlockTask {
//                result.async?.cancel()
//                result.continueWithResults(nil, nil)
//            }
//        }
//
//        waterfall.add { result in
//            XCTFail("should not execute the second job")
//            return BlockTask { }
//        }
//
//        waterfall.start()
//
//        XCTAssertFalse(waterfall.isRunning)
        
    }
    
    func testExecutesMultipleJobs() {
        
        let waterfall = Waterfall<Any> { _ in
            
        }
        
        let A = expectation(description: "should execute first job")
        let B = expectation(description: "should execute second job")
        
        waterfall.add(jobs: [ { result in
            return BlockTask {
                A.fulfill()
                result.continueWithResults(.success("A"))
            }
            }, { result in
                return BlockTask {
                    B.fulfill()
                    result.continueWithResults(.success("B"))
                }
            }
            
            ])
        
        waterfall.resume()
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
        
    
}
