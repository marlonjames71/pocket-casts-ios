import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var theme: Theme

    enum DisplayState {
        case plus
        case newAccount
    }

    let displayState: DisplayState = .newAccount

    var titleText: String {
        switch displayState {
        case .plus:
            return "Thank you, now let’s get you listening!"
        case .newAccount:
            return "Welcome, now let’s get you listening!"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            WelcomeConfetti(type: (displayState == .plus) ? .plus : .normal)

            ScrollViewIfNeeded {
                VStack(alignment: .leading) {
                    HeaderIcon(isPlus: displayState == .plus)

                    Label(titleText, for: .title)

                    ForEach(sections) { section in
                        WelcomeSectionView(model: section) {
                            print("Tappy")
                        }
                    }

                    Spacer()

                    Button("Done") {

                    }.buttonStyle(RoundedButtonStyle(theme: theme))
                }
                .padding(.top, Config.padding.top)
                .padding([.leading, .trailing], Config.padding.horizontal)
                .padding(.bottom)
            }
            .background(AppTheme.color(for: .background, theme: theme).ignoresSafeArea())
        }
    }

    private let sections: [WelcomeSection] = [
        WelcomeSection(title: "Import your podcasts", subtitle: "Coming from another app? Bring your podcasts with you.", imageName: "welcome-import", buttonTitle: "Import Podcasts"),
        WelcomeSection(title: "Discover something new", subtitle: "Find under-the-radar and trending podcasts in our hand-curated Discover page.", imageName: "welcome-discover", buttonTitle: "Find My Next Podcast")
    ]
}

private extension ThemeStyle {
    static let background = Self.primaryUi01
    static let text = Self.primaryText01
    static let sectionDescription = Self.primaryText02
    static let icon = Self.primaryIcon01
    static let sectionStroke = Self.primaryUi05
    static let sectionButtonTitle = Self.primaryInteractive01
}

private enum Config {
    enum padding {
        static let top = 40.0
        static let horizontal = 24.0
        static let sectionButtonVertical = 16.0
    }

    static let sectionCornerRadius = 12.0
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .previewWithAllThemes()
    }
}

// MARK: - View Components
private struct WelcomeConfetti: View {
    let type: WelcomeConfettiEmitter.ConfettiType

    var body: some View {
        GeometryReader { proxy in
            WelcomeConfettiEmitter(type: type,
                             frame: proxy.frame(in: .local)).ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .ignoresSafeArea().zIndex(1000)
    }
}

/// A view that displays the header icon
/// We display this using 2 images to allow us to apply the color overlay to the
/// icon without effecting the check mark
private struct HeaderIcon: View {
    @EnvironmentObject var theme: Theme
    let isPlus: Bool

    var body: some View {
        HStack {
            ZStack {
                Image("welcome-icon")
                    .foregroundColor(isPlus ? Color.plusGradientColor1 : AppTheme.color(for: .icon, theme: theme))
                    .gradientOverlay(isPlus ? Color.plusGradient : nil)
                Image("welcome-icon-check")
            }
            Spacer()
        }
    }
}

private struct Label: View {
    @EnvironmentObject var theme: Theme

    enum LabelStyle {
        case title
        case sectionTitle
        case sectionDescription
    }

    let text: String
    let labelStyle: LabelStyle

    init(_ text: String, for style: LabelStyle) {
        self.text = text
        self.labelStyle = style
    }

    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .fixedSize(horizontal: false, vertical: true)
            .modifier(LabelFont(labelStyle: labelStyle))
    }

    private var textColor: Color {
        switch labelStyle {

        case .title:
            return AppTheme.color(for: .text, theme: theme)
        case .sectionTitle:
            return AppTheme.color(for: .text, theme: theme)
        case .sectionDescription:
            return AppTheme.color(for: .sectionDescription, theme: theme)
        }
    }

    private struct LabelFont: ViewModifier {
        let labelStyle: LabelStyle

        func body(content: Content) -> some View {
            switch labelStyle {
            case .title:
                return content.font(size: 31, style: .title, weight: .bold)
            case .sectionTitle:
                return content.font(size: 18, style: .body, weight: .semibold)
            case .sectionDescription:
                return content.font(size: 13, style: .caption, maxSizeCategory: .extraExtraLarge)
            }
        }
    }
}

private struct WelcomeSection: Identifiable {
    let title: String
    let subtitle: String
    let imageName: String
    let buttonTitle: String

    var id: String { title }
}

private struct WelcomeSectionView: View {
    @EnvironmentObject var theme: Theme

    let model: WelcomeSection
    let action: () -> Void

    var body: some View {
        // The container view that displays the stroke
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {

                // The labels + icon view
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(model.title, for: .sectionTitle)
                        Label(model.subtitle, for: .sectionDescription)
                    }
                    Spacer()
                    Image(model.imageName)
                        .foregroundColor(AppTheme.color(for: .icon, theme: theme))
                }.padding(Config.padding.horizontal)

                divider
                button
            }
        }.overlay(roundedCorners)
    }

    private var roundedCorners: some View {
        RoundedRectangle(cornerRadius: Config.sectionCornerRadius)
            .stroke(AppTheme.color(for: .sectionStroke, theme: theme), lineWidth: 1)
    }

    private var divider: some View {
        Divider().background(
            AppTheme.color(for: .sectionStroke, theme: theme)
        )
    }

    private var button: some View {
            Button(model.buttonTitle) {
                action()
            }
            .foregroundColor(AppTheme.color(for: .sectionButtonTitle, theme: theme))
            .font(size: 15, style: .callout, weight: .medium)
            .padding([.top, .bottom], Config.padding.sectionButtonVertical)
            .padding([.leading, .trailing], Config.padding.horizontal)
    }
}
// MARK: - Confetti 🎉

private struct WelcomeConfettiEmitter: UIViewRepresentable {
    let type: ConfettiType
    let frame: CGRect
    let afterDelay: TimeInterval

    enum ConfettiType {
        case normal
        case plus
    }

    init(type: ConfettiType, frame: CGRect, afterDelay: TimeInterval = 0.5) {
        self.type = type
        self.frame = frame
        self.afterDelay = afterDelay
    }

    func makeUIView(context: Context) -> UIView {
        let hostView = UIView(frame: frame)

        DispatchQueue.main.asyncAfter(deadline: .now() + afterDelay) {
            let completion: ConfettiView.AnimationCompletion = { confettiView in
                confettiView.removeFromSuperview()
            }

            let confetti = (type == .plus) ? PlusConfettiView.self : NormalConfettiView.self
            confetti.cleanupAndAnimate(on: hostView, frame: frame, onAnimationCompletion: completion)
        }

        return hostView
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    private class PlusConfettiView: ConfettiView {
        override func emitConfetti() {
            guard let icon = UIImage(named: "confetti-plus") else {
                return
            }

            // Add more to the emitter
            var particles: [Particle] = []
            for _ in 0..<10 {
                particles.append(Particle(image: icon))
            }

            var config = PlusConfettiView.EmitterConfig()
            config.scaleRange = 1.2

            self.emit(with: particles, config: config)
        }
    }

    private class NormalConfettiView: ConfettiView {
        override func emitConfetti() {
            var images: [Particle] = []

            // Generate the particles
            for i in 1..<21 {
                let fileName = "confetti-shape-\(i)"
                if let image = UIImage(named: fileName) {
                    images.append(Particle(image: image))
                }
            }

            self.emit(with: images, config: NormalConfettiView.EmitterConfig())
        }
    }
}
