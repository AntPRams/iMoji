import SwiftUI

struct EmojisSectionView: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.fetchRandomEmoji()
            } label: {
                Text(Localizable.emojisButton)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            NavigationLink(destination: {
                ImagesGridView(viewModel: ImagesGridViewModel(gridDataType: .emoji))
            }, label: {
                Text(Localizable.emojisList)
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            Divider()
                .padding(.vertical, 16)
        }
    }
}

#Preview {
    EmojisSectionView(viewModel: MainViewModel())
}
