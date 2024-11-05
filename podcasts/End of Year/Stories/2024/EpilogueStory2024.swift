import SwiftUI

struct StoryShareButton: View {
    let shareable: Bool

    var body: some View {
        EmptyView()
    }
}

struct EpilogueStory2024: StoryView {

    private let foregroundColor = Color.black
    private let marqueeTextColor = Color(hex: "#EEB1F4")
    private let backgroundColor = Color(hex: "#EE661C")

    private let words = [
        "Thanks",
        "Merci",
        "Gracias",
        "Obrigado",
        "Gratki"
    ].map { $0.uppercased() }

    private let separator = Image("playback-24-heart")

    var identifier: String = "ending"

    var body: some View {
        VStack {
            Spacer()
            VStack {
                MarqueeTextView(words: words, separator: separator, direction: .leading)
                MarqueeTextView(words: words, separator: separator, direction: .trailing)
            }
            .frame(height: 350)
            .foregroundStyle(marqueeTextColor)
            Spacer()
            footerView()
        }
        .minimumScaleFactor(0.8)
        .foregroundStyle(foregroundColor)
        .background {
            backgroundColor
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .enableProportionalValueScaling()
    }

    @ViewBuilder func footerView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.eoy2024EpilogueTitle)
                .font(.system(size: 31, weight: .bold))
            Text(L10n.eoy2024EpilogueDescription)
                .font(.system(size: 15, weight: .light))
            Button(L10n.eoyStoryReplay) {
                StoriesController.shared.replay()
                Analytics.track(.endOfYearStoryReplayButtonTapped)
            }
            .buttonStyle(BasicButtonStyle(textColor: .black, backgroundColor: Color.clear, borderColor: .black))
            .allowsHitTesting(true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
    }

    func onAppear() {
        Analytics.track(.endOfYearStoryShown, story: identifier)
    }
}
