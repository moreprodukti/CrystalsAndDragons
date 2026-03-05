//
//  ConsoleView.swift
//  CrystalsAndDragons
//
//  Created by Алиса on 04/03/26.
//

import Foundation

public final class ConsoleView {
    private let ansiReset = "\u{001B}[0m"

    public init() {}

    public func clearScreen() {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
    }

    public func showRoomCountPrompt() {
        print("Hello! Let's play the game! First enter number of rooms:")
    }

    public func readRoomCount() -> Int? {
        guard let input = readLine() else {
            return nil
        }
        return Int(input)
    }

    public func readCommand() -> String? {
        guard let input = readLine() else {
            return nil
        }
        return input
    }

    public func showMessage(_ message: ViewMessage) {
        print("\(render(message: message))\n")
    }

    public func showInvalidRoomCount() {
        print("Invalid room count")
    }

    public func showGenerationFailed(_ error: Error) {
        print("Failed to generate game: \(error)")
    }

    public func victory() {
        print("""

        ╔══════════════════════════════════════════════════════╗
        ║                                                      ║
        ║     ✨✨✨  VICTORY! ✨✨✨                          ║
        ║                                                      ║
        ║     You have found the Holy Grail!                   ║
        ║     The ancient prophecy is fulfilled...             ║
        ║                                                      ║
        ║     You are now the rightful ruler of the kingdom!   ║
        ║                                                      ║
        ╚══════════════════════════════════════════════════════╝

        """)
    }

    public func gameOver() {
        print("""
            
        ╔══════════════════════════════════════════════════════╗
        ║                                                      ║
        ║            💀💀💀  GAME OVER  💀💀💀                ║
        ║                                                      ║
        ║            Your journey ends here...                 ║
        ║                                                      ║
        ╚══════════════════════════════════════════════════════╝
            
        """)
    }

    public func chooseAction() {
        print("Your action? (N/S/W/E, open, eat, get, drop, inv, quit)\n")
    }

    public func showStartScreen() {
        print(#"""

                                 CRYSTALS & DRAGONS   
                      
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⡄            
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣠⣤⣤⣤⣤⣤⣤⣤⣤⣀⣀⣼⣻⡄⠀⠀⠀⠀⠀⠀⡄⠀⢀⣸⣿⡆           
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣤⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠳⣦⣄⡀⣀⣴⣿⣾⣿⣿⠟⠃           
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣉⣭⣴⣾⣿⣿⠿⣻⣿⣿⡏⢀⣠⣼⣿⠹⣿⣿⣿⡻⡟⠁⠀            
           ⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⣭⣿⣾⣿⣿⣿⣿⣿⡟⠛⠁⣠⣾⣿⣿⣿⣴⣿⣿⣿⣿⣇⠙⢿⣿⣿⣬⣦⠀⠀⠀          
           ⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣩⣵⣾⣿⣿⣿⣿⣿⣿⡿⣿⠏⠉⠀⣠⠞⣻⣿⣿⠇⣿⣿⣿⣿⣿⣿⣿⣿⣾⣷⣿⣿⣿⡇⠀⠀          
           ⠀⢀⡾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣽⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⡁⠈⠀⠀⣠⢞⣵⣾⣿⣿⠋⢰⣿⣿⣿⣿⣿⣟⣩⣿⣿⣯⣟⣿⣿⣷⡄⠀          
           ⢠⣯⡾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠋⠖⠀⠀⢀⣤⠞⢁⣞⣻⣿⣿⠁⠀⢸⣿⣿⣿⣿⣿⣿⣯⣴⣟⣿⢿⣿⣿⣿⣿⠀          
           ⠛⠁⠀⠀⣿⣿⣿⣿⣿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠀⠂⠀⠀⠀⢀⡴⠋⠁⠀⠈⠙⠛⢿⣿⣷⣄⢸⣿⣿⣿⣿⣿⣿⣿⣏⡈⣧⠀⠈⠙⣿⡏⠀          
           ⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠐⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣭⣉⢹⡄⠀⠀⠈⠀⠀          
           ⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠲⣆⠀⠀⠀⣠⠾⢋⣀⣤⠤⣤⣀⡀⠀⠀⠀⠀⠀⠉⢿⣿⣿⣿⣿⣿⣿⡿⢻⣿⣄⡀⣱⡀⠀⠀⠀⠀          
           ⠀⠀⣰⣯⣾⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⣸⠟⣦⡾⠗⠋⠁⠀⠀⠀⡀⠀⣽⣷⣄⠀⠀⣀⣤⣬⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⠀⢻⢧⠀⠀⠀⠀          
           ⠀⢰⡿⠋⠉⢻⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⣼⡵⠊⠉⠀⠀⣠⣀⣰⣶⣾⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⡟⠻⣧⣿⡉⠙⢳⡏⢈⡆⠀⠀⠀          
           ⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⣀⣠⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣠⣿⣿⠛⠢⣼⠟⣩⠃⠀⠀⠀          
            ⠀⠀⠀⠀⠀⢸⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⢠⣤⣼⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⣹⣿⣿⣿⣿⣿⣿⣿⣿⣥⣾⡟⠙⠻⣷⣴⣿⣠⡞⠀⠀⠀⠀         
           ⠀⠀⠀⠀⠀⣸⣿⣿⠃⠀⠀⠀⠀⠀⢠⣤⣾⣿⣿⣿⣿⣿⢿⣿⣯⣿⣿⣿⣿⡿⠀⣰⣿⣿⠛⣿⣿⢻⣿⣿⣿⣴⣿⣾⣤⣤⡼⣿⣿⠋⠀⠀⠀⠀⠀          
           ⠀⠀⠀⠀⢀⣏⣾⠃⠀⠀⠀⠀⠠⣤⣾⣿⣿⣿⣿⣿⠿⠛⠋⢉⣽⣦⣼⣿⣿⣁⣰⣿⣯⣿⣷⣿⣿⣿⣿⡿⠋⣿⡽⠶⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀          
           ⠀⠀⠀⠀⣸⡿⠁⠀⠀⠀⠀⠀⣤⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠈⠻⣷⡆⢹⡇⠀⠈⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀          
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⣿⣿⡿⠋⠙⠋⠙⢿⣿⣿⡀⠀⠀⠀⠀⠀⠹⣿⣜⣷⣀⠀⠙⢿⣿⣿⣶⣤⣄⡀
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡏⢀⣀⣀⣀⣀⣀⣼⣿⣿⣧⣀⣀⣀⣀⣀⣻⣿⣿⣷⢾⣶⣤⣤⣠⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣦⡀
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣧⠀⠛⠿⠿⠿⢿⣿⣿⢿⣿⣿⡿⠿⠿⢿⡟⠛⠿⠛⠛⠛⠟⠟⠛⠿⠿⠛⠟⠛⠻⠟⠟⠛⠋⠟⠻⠿⠿⠁
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣷⣄⣀⣀⣀⣤⣴⣶⣶⣶⣾⣷⣾⠶⣤⣿⣶⣄
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⡛⣛⣉⣉⣀⣀⣀⣘⣛⣉⣉⠙⠃


        ╔════════════════════════════════════════════════════════════════════╗
        ║                                                                    ║ 
        ║                     WELCOME, BRAVE ADVENTURER!                     ║ 
        ║                                                                    ║    
        ║           The ancient dragon guards the legendary crystals...      ║
        ║                Find the Holy Grail and claim your destiny!         ║
        ║                                                                    ║
        ║        Commands:                                                   ║
        ║         • move <n/s/w/e>     - Move between rooms                  ║
        ║         • get <item>         - Pick up item                        ║
        ║         • open <chest>       - Open chest                          ║
        ║         • inv                - Check inventory                     ║
        ║         • eat <item>         - Eat food                            ║
        ║         • drop <item>        - Drop item                           ║
        ║         • quit               - Exit game                           ║
        ║                                                                    ║
        ╚════════════════════════════════════════════════════════════════════╝    
        """#)
    }

    private func render(message: ViewMessage) -> String {
        message.segments.map { segment in
            guard let color = segment.color else {
                return segment.text
            }
            return "\(ansiCode(for: color))\(segment.text)\(ansiReset)"
        }.joined()
    }

    private func ansiCode(for color: ViewMessage.TextColor) -> String {
        switch color {
        case .red:
            return "\u{001B}[31m"
        case .green:
            return "\u{001B}[32m"
        case .blue:
            return "\u{001B}[34m"
        case .yellow:
            return "\u{001B}[33m"
        case .gold:
            return "\u{001B}[93m"
        case .roasted:
            return "\u{001B}[38;5;52m"
        }
    }
}
