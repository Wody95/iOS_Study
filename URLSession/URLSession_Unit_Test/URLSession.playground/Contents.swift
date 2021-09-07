import UIKit
import Foundation


// itemList
struct Response: Decodable {
    let descriptions: String
    let currency: String
    let discounted_price: Int
    let registration_date: Double
    let stock: Int
    let thumbnails: [String]
    let id: Int
    let price: Int
    let title: String
    let images: [String]

}


func requestGet(url: String) {
    guard let url = URL(string: url) else {
        print("Error: cannot create URL")
        return
    }
    
    var request = URLRequest(url: url)
    let session = URLSession.shared
    
    request.httpMethod = "GET"
    
    session.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        
        print(data)
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }
        
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            print("Error: JSON Data Parsing failed")
            return
        }
        print(output)
    }.resume()
    
}

requestGet(url: "https://camp-open-market-2.herokuapp.com/item/43")

