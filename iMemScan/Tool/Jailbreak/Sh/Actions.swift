//
//  Actions.swift
//  YMTool
//
//  Created by yiming on 2021/7/8.
//

import Foundation

func runCmd(path: String, args: [String]) -> Int32 {
    let argv: [UnsafeMutablePointer<CChar>?] = args.map { $0.withCString(strdup) }
    defer { for case let arg? in argv { free(arg) } }
    
    var pid = pid_t(0)
    var status = posix_spawn(&pid, path.cString(using: .utf8), nil, nil, argv + [nil], environ)
    if status == 0 {
        if waitpid(pid, &status, 0) == -1 {
            //NSLog("*** 等待进程")
        }
    } else {
        NSLog("*** posix_spawn: \(status)")
    }
    
    return status
}

func userspaceRebootSupported() -> Bool {
    FileManager.default.fileExists(atPath: "/odyssey/jailbreakd.plist") || FileManager.default.fileExists(atPath: "/taurine/jailbreakd.plist")
}

func enableTweaks() {
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "enableTweaks"])
}

func disableTweaks() {
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "disableTweaks"])
}

func respring() {
    _ = runCmd(path: "/usr/bin/sbreload", args: ["sbreload"])
}

func userspaceReboot() {
    guard userspaceRebootSupported() else {
        ldRestart()
        return
    }
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "userspaceReboot"])
}

func ldRestart() {
    _ = runCmd(path: Bundle.main.path(forResource: "giveMeRoot", ofType: "") ?? "", args: ["giveMeRoot", "ldRestart"])
}

