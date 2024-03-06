import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
  let monitor: NWPathMonitor
  let queue = DispatchQueue(label: "NetworkMonitor")
  @Published var isConnected: Bool = false

  init() {
    monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    monitor.pathUpdateHandler = { path in
      Task { await MainActor.run { self.isConnected = path.status == .satisfied } }
    }
    monitor.start(queue: queue)
  }
}

struct ContentView: View {
  @StateObject private var networkMonitor = NetworkMonitor()
  @State var lastSent: Date = Date(timeIntervalSince1970: 0)

  var body: some View {
    VStack {
      Text(networkMonitor.isConnected ? "Connected" : "Not Connected")
      Text(getCurrentSSID())
      Text(lastSent.formatted())
    }.onChange(of: networkMonitor.isConnected) {
      guard networkMonitor.isConnected else { return }
      if getCurrentSSID() == Constants.OFFICE_SSID {
        Task {
          let currentDate = Date()
          if !Calendar.current.isDate(currentDate, inSameDayAs: lastSent) {
            try await sendMessage(text: "Atul has arrived at the office.")
            self.lastSent = currentDate
          }
        }
      }
    }
  }
}
