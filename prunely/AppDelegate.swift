//
//  AppDelegate.swift
//  prunely
//
//  Created by Aayush Rajagopalan on 13/05/2025.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "apple.terminal.on.rectangle", accessibilityDescription: "Prunely")
        }

        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Prune", action: #selector(prune), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        // Attach the menu
        statusItem?.menu = menu
    }
    
    func hasProject(in directoryPath: String, project: String) -> Bool {
        let fileManager = FileManager.default
        let nodeModulesPath = (directoryPath as NSString).appendingPathComponent(project)
        
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: nodeModulesPath, isDirectory: &isDirectory)
        
        return exists && isDirectory.boolValue
    }
    

    @objc func prune() {
        let fileManager = FileManager.default
        let labPath = "/Users/aayush/lab"

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: labPath)
            for item in contents {
                var isDir: ObjCBool = false
                let fullPath = "\(labPath)/\(item)"
                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                    do {
                        let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                        if let modificationDate = attributes[.modificationDate] as? Date {
                            print("Directory: \(item), Last Modified: \(modificationDate)")
                            let currentDate = Date()
                            if Calendar.current.dateComponents([.day], from: modificationDate, to: currentDate).day ?? 0 > 14 {
                                print("This directory has not been modified in more than a week")
                                if hasProject(in: fullPath, project: "node_modules") {
                                    print("node found")
                                    do {
                                        try fileManager.removeItem(atPath: "\(fullPath)/node_modules")
                                        print ("\(item) pruned")
                                    }
                                }
                                if hasProject(in: fullPath, project: "src-tauri"){
                                    print("tauri found")
                                    do {
                                        try fileManager.removeItem(atPath: "\(fullPath)/src-tauri/target")
                                        print ("\(item) pruned")
                                    }
                                } else {
                                    print("not found")
                                }
                            }
                        } else {
                            print("Directory: \(item), Last Modified: Unknown")
                        }
                    } catch {
                        print("Directory: \(item), Error retrieving modification date: \(error)")
                    }
                    
                }
            }
        } catch {
            print("Error reading lab directory: \(error)")
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
