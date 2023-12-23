//
//  SetModel.swift
//  SetModel
//
//  Created by yiming on 2021/8/16.
//

import Foundation

struct SetModel: Convertible {
    var range: String = ""
    var addrRangeStart: String = ""
    var addrRangeEnd: String = ""
    var LimitCount: String = ""
    var duration: String = ""
    var duration1: String = ""
    
    static func fetch() -> SetModel {

        guard let json = try? String(contentsOf: Self.path()) else {

            var model = SetModel()
            model.range = "0x20"
            model.addrRangeStart = "0x100000000"
            model.addrRangeEnd = "0x160000000"
            model.LimitCount = "1000000"
            model.duration = "100"
            model.duration1 = "20"

            return model
        }

        let model = json.kj.model(SetModel.self)

        return model!
    }
    
    func save() {
        let json = self.kj.JSONString()
        //print("json",json)
        do {
            try json.write(to: Self.path(), atomically: true, encoding: .utf8)
        } catch let error {
            print("error", error)
        }
    }
    
    private static func path() -> URL {
        
#if false
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentURL?.appendingPathComponent("Set.data")
        return fileURL!
#else
        let url = URL.init(fileURLWithPath: "/var/mobile/Media/iMemScan(Script)/Set.data")
        return url
#endif
    }
}
