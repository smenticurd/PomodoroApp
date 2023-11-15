import UIKit
enum PomodoroSessionType: CustomStringConvertible, CaseIterable {
    case work, shortBreak, longBreak
    
    var description: String {
        switch self {
        case .work:
            return "Work"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
}
