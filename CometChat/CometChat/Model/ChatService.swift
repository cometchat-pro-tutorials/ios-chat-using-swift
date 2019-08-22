//
//  ChatService.swift
//  CometChat
//
//  Created by Marin Benčević on 09/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import Foundation
import CometChatPro

extension String: Error {}

final class ChatService {
  
  private enum Constants {
    #warning("Don't forget to set your API key and app ID here!")
    static let cometChatAPIKey = "API_KEY"
    static let cometChatAppID = "APP_ID"
    static let groupID = "supergroup"
  }
  
  static let shared = ChatService()
  private init() {}
  
  static func initialize() {
    CometChat(
      appId: Constants.cometChatAppID,
      onSuccess: { isSuccess in
        print("CometChat connected successfully: \(isSuccess)")
    },
      onError: { error in
        print(error)
    })
  }
  
  private var user: User?
  var onRecievedMessage: ((Message)-> Void)?
  
  func login(email: String, onComplete: @escaping (Result<User, Error>)-> Void) {
    CometChat.messagedelegate = self
    CometChat.login(
      UID: email,
      apiKey: Constants.cometChatAPIKey,
      onSuccess: { [weak self] cometChatUser in
        guard let self = self else { return }
        self.user = User(name: email)
        self.joinGroup(as: self.user!)
        DispatchQueue.main.async {
          onComplete(.success(self.user!))
        }
      }, onError: { error in
        print("Error logging in:")
        print(error.errorDescription)
        DispatchQueue.main.async {
          onComplete(.failure("Error logging in"))
        }
    })
  }
  
  func send(message: String) {
    guard let user = user else {
      return
    }
    
    let textMessage = TextMessage(
      receiverUid: Constants.groupID,
      text: message,
      messageType: .text,
      receiverType: .group)
    
    CometChat.sendTextMessage(
      message: textMessage,
      onSuccess: { [weak self] _ in
        guard let self = self else { return }
        print("Message sent")
        DispatchQueue.main.async {
          self.onRecievedMessage?(Message(user: user, content: message, isIncoming: false))
        }
      },
      onError: { error in
        print("Error sending message:")
        print(error?.errorDescription ?? "")
    })
  }
  
  private var messagesRequest: MessagesRequest?
  
  func getMessages(onComplete: @escaping ([Message])-> Void) {
    guard let user = user else {
      return
    }
    
    let limit = 50
    
    messagesRequest = MessagesRequest.MessageRequestBuilder()
      .set(limit: limit)
      .set(guid: Constants.groupID)
      .build()
    
    messagesRequest!.fetchPrevious(
      onSuccess: { fetchedMessages in
        print("Fetched \(fetchedMessages?.count ?? 0) older messages")
        guard let fetchedMessages = fetchedMessages else {
          onComplete([])
          return
        }
        
        let messages = fetchedMessages
          .compactMap { $0 as? TextMessage }
          .map { Message($0, isIncoming: $0.senderUid != user.name.lowercased()) }
        
        DispatchQueue.main.async {
          onComplete(messages)
        }
    }, onError: { error in
        print("Fetching messages failed with error:")
        print(error?.errorDescription ?? "unknown")
    })
  }
  
  private func joinGroup(as user: User) {
    CometChat.joinGroup(
      GUID: Constants.groupID,
      groupType: .public,
      password: nil,
      onSuccess: { _ in
        print("Group joined successfully!")
      },
      onError: { error in
        print("Error:", error?.errorDescription ?? "Unknown")
    })
  }
}

extension ChatService: CometChatMessageDelegate {
  func onTextMessageReceived(textMessage: TextMessage) {
    DispatchQueue.main.async {
      self.onRecievedMessage?(Message(textMessage, isIncoming: true))
    }
  }
}
