import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
  let monitor: NWPathMonitor
  let queue = DispatchQueue(label: "NetworkMonitor")
  @Published var isConnected: Bool = false

  init() {
    monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    monitor.pathUpdateHandler = { path in
      Task {
        await MainActor.run {
          self.isConnected = path.status == .satisfied
          if self.isConnected && (getCurrentSSID() == "wizards") {
            Task {
              try await sendMessage(text: "Atul has arrived at the office.")
            }
          }
        }
      }
    }
    monitor.start(queue: queue)
  }
}

struct ContentView: View {
  @StateObject private var networkMonitor = NetworkMonitor()

  var body: some View {
    VStack {
      Text(networkMonitor.isConnected ? "Connected" : "Not Connected")
      Text(getCurrentSSID())
    }
  }
}
