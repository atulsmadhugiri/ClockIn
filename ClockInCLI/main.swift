import Foundation
import Network

class NetworkMonitor {
  private let monitor: NWPathMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
  private let queue = DispatchQueue(label: "ClockInCLIQueue")
  private var updateLastSentAt = Date(timeIntervalSince1970: 0)
  private var isConnected: Bool = false

  init() {
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        guard !self.isConnected else { return }
        self.isConnected = true
        if getCurrentSSID() == Constants.OFFICE_SSID {
          self.potentiallySendMessage()
        }
      } else {
        self.isConnected = false
      }
    }
    monitor.start(queue: queue)
  }

  private func potentiallySendMessage() {
    let now = Date()
    let calendar = Calendar.current

    if !calendar.isDate(now, inSameDayAs: self.updateLastSentAt) && !calendar.isDateInWeekend(now) {
      Task {
        try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        try await sendMessage(text: "Atul is here.")
        self.updateLastSentAt = now
      }
    }
  }

}

let networkMonitor = NetworkMonitor()
RunLoop.main.run()
