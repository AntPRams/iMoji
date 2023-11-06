import Foundation
import SwiftUI

protocol MainViewModelInterface: ObservableObject {
    
    var error: Error? { get set }
    var emojiAdapter: EmojiAdapter { get }
    var avatarAdapter: AvatarAdapter { get }
    var nameQuery: String { get set }
    var state: ViewState { get set }
    var modelToPresent: PersistentModelRepresentable? { get set }
    
    func fetchEmojis()
    func fetchRandomEmoji()
    func searchUser()
}

class MainViewModel: MainViewModelInterface {
    
    let emojiAdapter: EmojiAdapter
    let avatarAdapter: AvatarAdapter
    @Published var error: Error?
    @Published var modelToPresent: PersistentModelRepresentable?
    @Published var nameQuery: String = String()
    @Published var state: ViewState = .initial
    
    init(
        emojiAdapter: EmojiAdapter = EmojiAdapter(),
        avatarAdapter: AvatarAdapter = AvatarAdapter()
    ) {
        self.emojiAdapter = emojiAdapter
        self.avatarAdapter = avatarAdapter
    }
    
    func fetchEmojis() {
        state = .loading
        Task {
            do {
                _ = try await emojiAdapter.fetchEmojisData()
                await MainActor.run {
                    withAnimation {
                        self.state = .idle
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.state = .idle
                }
            }
        }
    }
    
    func fetchRandomEmoji() {
        state = .loading
        Task {
            let randomEmoji = await emojiAdapter.fetchRandomEmoji()
            await MainActor.run {
                withAnimation {
                    self.state = .idle
                    self.modelToPresent = randomEmoji
                }
            }
        }
    }
    
    func searchUser() {
        // TODO: - ensure that the field has data
        state = .loading
        Task {
            do {
                let user = try await avatarAdapter.fetch(user: nameQuery)
                await MainActor.run {
                    withAnimation {
                        self.nameQuery = String()
                        self.state = .idle
                        self.modelToPresent = user
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.state = .idle
                }
            }
        }
    }
}
