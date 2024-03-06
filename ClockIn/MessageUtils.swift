import Foundation

struct MessageBody: Codable {
  let threadID: String
  let localID: String
  let text: String
}

struct MessageRequest: Codable {
  let input: MessageBody
  let cookie: String
  let sessionID: String
}

func sendMessage(text: String) async throws {

  let messageBody = MessageBody(
    threadID: "256|518255",
    localID: String(format: "%02X", Int.random(in: 0..<Int.max)),
    text: text
  )

  let messageRequest = MessageRequest(
    input: messageBody,
    cookie: Secrets.COOKIE,
    sessionID: Secrets.SESSION_ID
  )

  let data = try await NetworkManager.sendCommRequest(
    to: URL(string: "https://squadcal.org/create_text_message")!,
    with: messageRequest
  )

  if let stringified = String(data: data, encoding: .utf8) {
    print(stringified)
  } else {
    print("Failed to convert Data to String")
  }
}
