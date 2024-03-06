import Foundation

func shell(command: String) -> String {
  let process = Process()
  let pipe = Pipe()

  process.standardOutput = pipe
  process.arguments = ["-c", command]
  process.launchPath = "/bin/zsh"
  process.launch()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(data: data, encoding: .utf8) ?? ""
}

func getCurrentSSID() -> String {
  let commandOutput = shell(
    command:
      "/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}'"
  )
  return commandOutput.trimmingCharacters(in: .whitespacesAndNewlines)
}
