// The Swift Programming Language
// https://docs.swift.org/swift-book
import Controller
import View

@main
struct CrystalsAndDragons {
    static func main() {
        let view = ConsoleView()
        view.showStartScreen()

        let parser = CommandParser()
        print(parser.parse(command: "inv") as Any)
    }
}
