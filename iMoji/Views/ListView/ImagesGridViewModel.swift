import Foundation

protocol ImagesGridViewModelInterface: ObservableObject {
    
    var error: Error? { get set }
    var adapter: EmojiAdapter { get }
    var emojis: [EmojiModel] { get set }
    
    func fetchEmojis()
}

class ImagesGridViewModel: ImagesGridViewModelInterface {
    
    let adapter: EmojiAdapter
    
    @Published var error: Error?
    @Published var emojis = [EmojiModel]()
    
    init(adapter: EmojiAdapter = EmojiAdapter(), shouldLoadEmojisOnInitialization: Bool = true) {
        self.adapter = adapter
        guard shouldLoadEmojisOnInitialization else {
            return
        }
        fetchEmojis()
    }
    
    func fetchEmojis() {
        Task {
            do {
                let emojis = try await adapter.fetchEmojisData()
                await MainActor.run {
                    self.emojis = emojis
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}