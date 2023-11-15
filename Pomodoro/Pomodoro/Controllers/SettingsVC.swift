import UIKit
import Combine
class SettingsVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    
    deinit {
        print("deinit SettingsVC")
        
    }
    


    fileprivate var anyCancellable = Set<AnyCancellable>()
        
    fileprivate(set) var durationChangePublisher = PassthroughSubject<TimerSettingsCell.Action, Never>()

    
    
    fileprivate let timeSettingsItems = PomodoroSessionType.allCases
    lazy var workDuration = getCurrentWorkDuration()
    lazy var shortBreakDuration = getCurrentShortBreakDuration()
    lazy var longBreakDuration = getCurrentLongBreakDuration()

    
    
    
    fileprivate lazy var settingsSection: [SettingsItem] = [.timerSettings(timeSettingsItems)]
    
    
    fileprivate func setUpTableView() {
        tableView.register(TimerSettingsCell.self, forCellReuseIdentifier: TimerSettingsCell.cellReuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
    }
    
}




extension SettingsVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard case .timerSettings(let timeSettingsItems) = settingsSection[indexPath.section] else {
            fatalError("Unexpected settings section type")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: TimerSettingsCell.cellReuseIdentifier, for: indexPath) as! TimerSettingsCell
        let session = timeSettingsItems[indexPath.row]
        configure(cell, with: session)
        return cell
    }
    
    
    /// Binds TimerSettingsCell with PomodoroSessionType and attaches a combine subscriber to the cell's passthroughSubject
    fileprivate func configure(_ cell: TimerSettingsCell, with session: PomodoroSessionType) {
        switch session {
        case .work:
            cell.configureTitle(with: session, durationInMins: workDuration)
            subscribe(to: cell)

        case .shortBreak:
            cell.configureTitle(with: session, durationInMins: shortBreakDuration)
            subscribe(to: cell)
            
        case .longBreak:
            cell.configureTitle(with: session, durationInMins: longBreakDuration)
             subscribe(to: cell)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard case .timerSettings = settingsSection[indexPath.section] else {
            fatalError("Unexpected settings section type")
        }

        return 170
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .timerSettings(let timeSettingsItems) = settingsSection[section] {
            return timeSettingsItems.count
        } else {
            // Handle other cases if needed
            fatalError("Unexpected settings section type")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSection.count
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel()
        let sectionTitle = settingsSection[section]
        titleLabel.text = "    \(sectionTitle.description)"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = .appMainColor
        titleLabel.backgroundColor = .white
        return titleLabel
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}



//MARK: - Actions
extension SettingsVC {
    
    /// Listens to TimerSettingsCell actions published via passthroughsubject
    fileprivate func subscribe(to cell: TimerSettingsCell) {
        cell.cellActionPublisher
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: {[weak self] cellAction in
            switch cellAction {
                
            case .increaseDuration(let sessionType):
                self?.increase(session: sessionType, by: 1)
                
            case .decreaseDuration(let sessionType):
                self?.decrease(session: sessionType, by: 1)
                
            }
        }.store(in: &anyCancellable)
    }
    
    
    func increase(session: PomodoroSessionType, by num: Int) {
        switch session {
        case .work:
            workDuration += num
            UserDefaults.standard.set(workDuration, forKey: .workDuration)
            durationChangePublisher.send(.increaseDuration(.work))

        case .shortBreak:
            shortBreakDuration += num
            UserDefaults.standard.set(shortBreakDuration, forKey: .shortBreakDuration)
            durationChangePublisher.send(.increaseDuration(.shortBreak))

        case .longBreak:
            longBreakDuration += num
            UserDefaults.standard.set(longBreakDuration, forKey: .longBreakDuration)
            durationChangePublisher.send(.increaseDuration(.longBreak))

        }
        

    }
    
    
    func decrease(session: PomodoroSessionType, by num: Int) {
        
        switch session {
        case .work:
            guard workDuration > 0 else {return}
            workDuration -= num
            UserDefaults.standard.set(workDuration, forKey: .workDuration)
            durationChangePublisher.send(.decreaseDuration(.work))

        case .shortBreak:
            guard shortBreakDuration > 0 else {return}
            shortBreakDuration -= num
            UserDefaults.standard.set(shortBreakDuration, forKey: .shortBreakDuration)
            durationChangePublisher.send(.decreaseDuration(.shortBreak))

        case .longBreak:
            guard longBreakDuration > 0 else {return}
            longBreakDuration -= num
            UserDefaults.standard.set(longBreakDuration, forKey: .longBreakDuration)
            durationChangePublisher.send(.decreaseDuration(.longBreak))

        }
        
        

        
    }
    
    
}

