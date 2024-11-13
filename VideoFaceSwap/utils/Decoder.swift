//
//  Decoder.swift
//  Insect_EP
//
//  Created by Javad on 8/13/24.
//

import Foundation

enum MyDecoderState<Data , Error> {

    case success(Data)
    case failure(Error)
    
}


class MyDecoder<DataModel:Decodable> {
    
    func decodeJSON(json : Data) -> MyDecoderState<DataModel?, Error?> {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(DataModel.self, from: json)
            return MyDecoderState.success(data)
          } catch let jsonError as NSError {
              print("JSON decode failed: \(jsonError.description)")
              return MyDecoderState.failure(jsonError)
          }
        
    }
    
}
