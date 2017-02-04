//
//  FWRequest.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 11/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String:Any]

internal class FWRequest {
    func load<A>(resource:Resource<A>, completion:@escaping (A?)->()) {
        let request = NSMutableURLRequest(resource: resource)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data,response, error) in
            let result = data.flatMap(resource.parse)
            completion(result)
        })
        task.resume()
    }
}

// Mark:- Resource
struct Resource<A> {
    let url:URL
    let method:HttpMethod<Data>
    let parse:(Data) -> A?
}

extension Resource {
    init(url:URL, method:HttpMethod<Any> = .get, parseJSON:@escaping (Any) -> A?) {
        self.url = url
        self.method = method.map{ json in
            return try! JSONSerialization.data(withJSONObject: json, options: [])
        }
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as Any?
                print(json)
                return json.flatMap(parseJSON)
            }catch {
                return nil
            }
        }
    }
}

//Mark:- NSMutableURLRequest
extension NSMutableURLRequest {
    convenience init<A>(resource:Resource<A>) {
        self.init(url:resource.url)
        httpMethod = resource.method.method
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue("application/json", forHTTPHeaderField: "Accept")
        if case let .post(data) = resource.method {
            httpBody = data
        }
    }
}


//Mark:- HttpMethod
enum HttpMethod<Body> {
    case get
    case post(Body)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

extension HttpMethod {
    func map<B>(f:(Body)->B)->HttpMethod<B>{
        switch self {
        case .get:
            return .get
        case .post(let body):
            return .post(f(body))
        }
    }
}
