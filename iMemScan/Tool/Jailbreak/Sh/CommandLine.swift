//
//  CommandLine.swift
//  CommandLine
//
//  Created by yiming on 2021/8/20.
//

import Foundation

func runCmd(path: String, args: [String]) {
    let task = NSTask()
    task?.launchPath = path
    task?.arguments = args

    let pipe = Pipe()
    task?.setStandardOutput(pipe)
    task?.launch()

    //let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task?.waitUntilExit()

//    let status = String(data: data, encoding: .utf8)
//    JHLog.share().cache(status!)
//    JHLog.share().save()
}

//func runCmd(path: String, args: [String]) {
//
//    var model = RunCmdModel()
//    model.path = path
//    model.args = args
//
//    // Model -> Json
//    let jsonStr = model.kj.JSONString()
//    //NSLog("memlog: Model -> Json = \(jsonStr)")
//
//    // Base64
//    let enc = jsonStr.toBase64()
//    NSLog("memlog: Json -> enc = \(enc!)")
//
//    let url = "http://localhost:8081/rucmd/params&&\(enc!)"
//    AF.request(url, method: .post, parameters: nil, headers: nil).responseJSON { (response) in
//        switch response.result {
//        case .success(let json):
//            print(json)
//        case .failure(let error):
//            print(error)
//        }
//    }
//}
