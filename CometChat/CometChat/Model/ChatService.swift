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
    
    func login(email: String, onComplete: @escaping (Result<User, String>)-> Void) {
        CometChat.messagedelegate = self

        CometChat.login(
            UID: email,
            apiKey: Constants.cometChatAPIKey,
            onSuccess: { user in
                self.user = User(name: user.uid ?? "unknown user")
                self.joinGroup()
                DispatchQueue.main.async {
                    onComplete(.success(User(name: user.uid ?? "unknown user")))
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
    
    private func joinGroup() {
        CometChat.joinGroup(
            GUID: Constants.groupID,
            groupType: .public,
            password: nil,
            onSuccess: { _ in
                print("Successfully joined group.")
            },
            onError: { error in
                print("Error joining group:")
                print(error?.errorDescription ?? "")
            })
    }
}

extension ChatService: CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        let content = textMessage.text
        let sender = User(name: textMessage.senderUid)
        let message = Message(user: sender, content: content, isIncoming: true)
        DispatchQueue.main.async {
            self.onRecievedMessage?(message)
        }
    }
    
}
