//
//  DecodeResponseTests.swift
//  
//
//  Created by Kinglets on 2023/4/20.
//

import XCTest
@testable import HiJSON

public class Response : JSONDecodable {
    
    @JSONKey()
    final public var notify: String?
    
    @JSONKey()
    final public var response: String?
    
    @JSONKey("content-data")
    final public var contentData: String?
    
    public required init(_ decoder: _HiJSONDecoder) {
    }
    
    public var isNotify: Bool {
        return notify != nil
    }
    
    public var isRequestResponse: Bool {
        return response != nil
    }
}

public class Request : JSONEncodable {

    @JSONKey("request-id")
    final public var requestId: String
}

public class AuthResponse : Request {
    
    @JSONKey()
    public var request: String
    
    @JSONKey("param-response")
    public var paramResponse: String
}

final class DecodeResponseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        let jsonString = """
        {"notify": "authenticate"}
        """
        
        do {
            let notify = try JSONDecoder().decode(Response.self, from: jsonString.data(using: .utf8)!)
            print("notify")
        } catch {
            print(error)
        }
        
        let response = AuthResponse()
        response.request = "authenticate"
        response.requestId = "0"
        response.paramResponse = UUID().uuidString
        if let data = try? JSONEncoder().encode(response) {
            print(String(data: data, encoding: .utf8) ?? "")
        }
        print("end")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
