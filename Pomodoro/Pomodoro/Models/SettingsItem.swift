import UIKit
enum SettingsItem: CustomStringConvertible {
    case timerSettings([PomodoroSessionType])
    var description: String {
        return "Settings"
    }
}


