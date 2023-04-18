import XCTest
@testable import HiJSON

let formatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyyMMdd HHmmss"
    return df
}()

let custom: (JSONKeyDecoder) throws -> Date = { _ in
    return .init()
}

struct DateModel: JSONDecodable {
    
    init(_ decoder: _HiJSONDecoder) { }
    
//    @JSONKey(decodingStrategy: .secondsSince1970)
//    var date: Date
//
//    @JSONKey(decodingStrategy: .secondsSince1970)
//    var dates: [Date]
    
    @JSONKey(decodingStrategy: .secondsSince1970)
    var datess: [[Date]]
    
//    @JSONKey(.key("dates").index(0), decodingStrategy: .secondsSince1970)
//    var dateFromDates: Date
}

class DecodeDateTests: XCTestCase {
    
    func test() {
        let data = """
                {
                "date": 1000000,
                "dates": [1000000, 1000000],
                "datess": [[1000000, 1000000]]
                }
                """.data(using: .utf8)!
        do {
            let model = try JSONDecoder().decode(DateModel.self, from: data)
//            XCTAssertEqual(model.date, Date(timeIntervalSince1970: 1000000))
        } catch {
            XCTAssertNil(error)
        }
    }
}
