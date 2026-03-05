// The Swift Programming Language
// https://docs.swift.org/swift-book
import Controller

@main
struct CrystalsAndDragons {
    static func main() {
        guard let controller = GameController.bootstrapConsoleController() else {
            return
        }
        controller.runGameLoop()
    }
}
