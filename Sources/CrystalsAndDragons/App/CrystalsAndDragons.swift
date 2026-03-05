// The Swift Programming Language
// https://docs.swift.org/swift-book
import Controller

@main
struct CrystalsAndDragons {
    static func main() {
        print("Enter number of rooms:")

        guard
            let input = readLine(),
            let roomCount = Int(input),
            roomCount > 0
        else {
            print("Invalid room count")
            return
        }

        let controller: GameController
        do {
            controller = try GameController(roomCount: roomCount)
        } catch {
            print("Failed to generate game: \(error)")
            return
        }

        controller.startScreen()
        controller.sendResponse(controller.playerInfo())
        controller.sendResponse(controller.playerPosition())

        while true {
            let command = controller.getCommand()

            if case .quit = command {
                break
            }

            let response = controller.runCommand(command)
            controller.sendResponse(response)
            controller.sendResponse(controller.playerInfo())
            controller.sendResponse(controller.playerPosition())

            if controller.isGameFinished() {
                break
            }
        }
    }
}
