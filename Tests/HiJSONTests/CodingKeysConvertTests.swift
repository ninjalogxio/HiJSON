import XCTest
@testable import HiJSON

fileprivate struct CodingKeysModel: JSONDecodable {

    init(_ decoder: _HiJSONDecoder) {}
    
    @JSONKey(KeyPath("user_names", 0))
    var userName: String
    
    @JSONKey("snake_case")
    var snakeCase: String

    @JSONKey()
    var nested: Nested

    @JSONKey(KeyPath("nested", "nested_key"))
    var nestedKey: String
    
    
    struct Nested: JSONDecodable {
        init(_ decoder: _HiJSONDecoder) {}
        
        @JSONKey("nested_key")
        var nestedKey: String
    }
}

final class HiJSONTests: XCTestCase {

    func testExample() throws {
        let data = #"""
                    {
                    "user_names": ["xiaolong.jin"],
                    "snake_case": "value",
                    "nested": { "nested_key": "value1" }
                    }
                    """#.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let model = try decoder.decode(CodingKeysModel.self, from: data)
            XCTAssertEqual(model.userName, "xiaolong.jin")
            XCTAssertEqual(model.snakeCase, "value")
            XCTAssertEqual(model.nested.nestedKey, "value1")
            XCTAssertEqual(model.nestedKey, "value1")
        } catch {
            print("error: \(error)")
        }
    }
}
