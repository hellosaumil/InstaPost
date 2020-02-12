//
//  Data.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/8/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import Foundation

enum DataLoadSaveError: Error{
    case fileNotFound, coudlNotLoadFromBundle, coudlNotSaveToBundle, coudlNotParse
}

func swiftToJSONString(data:Any) -> String? {
    do {
        
        let arrayAsData: Data = try JSONSerialization.data(withJSONObject: data)
        
        return String(data: arrayAsData, encoding:String.Encoding.utf8)
        
    } catch {
        
        return nil
        
    }
}

func cleanKeys(of dict: [String:Any]) -> [String:Any] {
    
    var newDict: [String: Any] = [:]
    
    for (key, value) in dict {
        newDict[key.replacingOccurrences(of: "-", with: "_")] = value
    }
    
    return newDict
}

func getPostRequest(from validURL: URL, of dataToPost: Data) -> URLRequest {
    
    var urlPostRequest = URLRequest(url: validURL)
    urlPostRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlPostRequest.httpMethod = "POST"
    urlPostRequest.httpBody = dataToPost
    
    return urlPostRequest
}

func parseHTTPResponse(data:Data?, response:URLResponse?, error:Error?) -> Any? {
    guard error == nil else {

        print("error: \(error!.localizedDescription)")
        return nil
    }
    
    let httpResponse = response as? HTTPURLResponse
    let status:Int = httpResponse!.statusCode
    
    guard data != nil && (status == 200) else {
    
        print("\n\t***Status: \(status)")
        
        if data != nil {
        
            do {
                
                let json: Any = try JSONSerialization.jsonObject(with: data!)
                print("\n\t***json: \(json)")
                
            } catch {
                
                print("\n\t***Catching ***")
                print(httpResponse.debugDescription)
            }
        }
        
        return nil
    }
    
    do {
        
        let json: Any = try JSONSerialization.jsonObject(with: data!)
//        print("\njson: \(json)")
        return json
        
    } catch {
        
        print("\nCatching ***")
        print(httpResponse.debugDescription)
        return nil
    }
}

func getBoolJSONData(_ data:Data?, _ response:URLResponse?, _ error:Error?, key: String) -> Bool {
    
    guard let validJSONObject = parseHTTPResponse(data: data, response: response, error: error) as? [String:Any] else { return false }
    
    
    guard let boolData = validJSONObject[key] as? Bool else {
        
        print("\nKey: \(key) not found!")
        print(type(of: validJSONObject), validJSONObject)
        
        return false
    }
    
    print("key: \t\(boolData)")
    
    return boolData
    
}

func getIntJSONData(_ data:Data?, _ response:URLResponse?, _ error:Error?, key: String) -> Int? {
    
    guard let validJSONObject = parseHTTPResponse(data: data, response: response, error: error) as? [String:Any] else { return nil }
    
    
    guard let intData = validJSONObject[key] as? Int else {
        
        print("\nKey: \(key) not found!")
        print(type(of: validJSONObject), validJSONObject)
        
        return nil
    }
    
    print("key: \t\(intData)")
    
    return intData
    
}

func getIntsJSONData(_ data:Data?, _ response:URLResponse?, _ error:Error?, key: String) -> [Int] {
    
    guard let validJSONObject = parseHTTPResponse(data: data, response: response, error: error) as? [String:Any] else { return [] }
    
    
    guard let listData = validJSONObject[key] as? [Int] else {
        
        print("\nKey: \(key) not found!")
        print(type(of: validJSONObject), validJSONObject)
        
        return []
    }
    
    print("ints data: \t\(listData)")
    return listData
    
}


func getStringsJSONData(_ data:Data?, _ response:URLResponse?, _ error:Error?, key: String) -> [String] {
    
    guard let validJSONObject = parseHTTPResponse(data: data, response: response, error: error) as? [String:Any] else { print("\nNIL ***"); return [] }
    
    
    guard let listData = validJSONObject[key] as? [String] else {
        
        print("\nKey: \(key) not found!")
        print(type(of: validJSONObject), validJSONObject)
        
        return []
    }
    
//    print("strings data: \t\(listData)")
    print("stringData valid")
    
    return listData
    
}

func getStringJSONData(_ data:Data?, _ response:URLResponse?, _ error:Error?, key: String) -> String? {
    
    guard let validJSONObject = parseHTTPResponse(data: data, response: response, error: error) as? [String:Any] else { return nil }
    
    guard let stringData = validJSONObject[key] as? String else {
        
        print("\nKey: \(key) not found!")
        print(type(of: validJSONObject), validJSONObject)
        
        return nil
    }
    
    if stringData.count < 100 {
        print("key: \t\(stringData)")
    }
    
    return stringData
    
}



let serviceCallURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/service-calls"
let nicknamesURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/nicknames"

let hashtagsURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/hashtags"
let hashtagsCountURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/hashtag-count"

let postURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/post?post-id="
let imageURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/image?id="

let nicknamePostIDsURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/nickname-post-ids?nickname="
let hashtagPostIDsURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/hashtags-post-ids?hashtag="

let authenticateURLString: String = "https://bismarck.sdsu.edu/api/instapost-query/authenticate?"

let createNewUserURLString: String = "https://bismarck.sdsu.edu/api/instapost-upload/newuser"

let createNewPostURLString: String = "https://bismarck.sdsu.edu/api/instapost-upload/post"

let createNewImageURLString: String = "https://bismarck.sdsu.edu/api/instapost-upload/image"

let updateRatingURLString: String = "https://bismarck.sdsu.edu/api/instapost-upload/rating"

let updateCommentURLString: String = "https://bismarck.sdsu.edu/api/instapost-upload/comment"
