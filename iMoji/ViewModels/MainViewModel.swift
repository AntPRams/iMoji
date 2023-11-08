import Foundation
import Combine

@Observable 
class MainViewModel {
    
    // MARK: - Properties
    
    let repository: PersistentDataRepositoryInterface
    var displayedItem: MediaItem?
    var nameQuery: String = String()
    var viewState: ViewState = .initial
    var error: Error?
    
    private var disposableBag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(repository: PersistentDataRepositoryInterface = PersistentDataRepository()) {
        self.repository = repository
        subscribeToAvatarRemovalNotification()
        fetchEmojis()
    }
    
    // MARK: - Public Interface
    
    func fetchEmojis() {
        viewState = .loading
        Task {
            do {
                try await repository.fetchItems(.emoji)
                await MainActor.run {
                    self.viewState = .idle
                }
            } catch {
                await react(to: error)
            }
        }
    }
    
    func fetchRandomEmoji() {
        viewState = .loading
        Task {
            do {
                let emoji = try await repository.fetchRandomEmoji()
                await MainActor.run {
                    self.displayedItem = emoji
                    self.viewState = .idle
                }
            } catch {
                await react(to: error)
            }
        }
    }
    
    func searchUser() {
        // TODO: - ensure that the field has data
        viewState = .loading
        Task {
            do {
                let user = try await repository.fetchAvatar(user: nameQuery)
                await MainActor.run {
                    self.nameQuery = String()
                    self.viewState = .idle
                    self.displayedItem = user
                }
            } catch {
                await react(to: error)
            }
        }
    }
}

// MARK: - Private work

private extension MainViewModel {
    
    private func react(to error: Error) async {
        await MainActor.run {
            self.error = error
            self.viewState = .idle
        }
    }
    
    func subscribeToAvatarRemovalNotification() {
        NotificationCenter.default.publisher(for: .didRemoveAvatarFromPersistence)
            .compactMap { $0.object as? String }
            .sink { [weak self] avatarName in
                guard let self else { return }
                if displayedItem?.name == avatarName {
                    displayedItem = nil
                }
            }
            .store(in: &disposableBag)
    }
}
