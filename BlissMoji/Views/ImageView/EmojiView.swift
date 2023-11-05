import SwiftUI

struct EmojiView<ViewModel: EmojiViewModelInterface>: View {
    
    @StateObject var viewModel: ViewModel
    var deleteAction: () -> Void
    
    var body: some View {
        VStack {
            if viewModel.state == .loading {
                ZStack {
                    ProgressView()
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
            } else if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
            }
            Text(viewModel.emojiModel.name)
        }
        .onTapGesture(perform: deleteAction)
    }
}

enum State {
    case loading, idle, concluded
}