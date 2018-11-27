final class TitleSubtitle: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        applyStyles()
    }

    private func applyStyles() {
        styleBackground()
        styleTitle()
        styleSubtitle()
    }

    private func styleBackground() {
        backgroundColor = WPStyleGuide.greyLighten30()
    }

    private func styleTitle() {
        title.font = WPStyleGuide.fontForTextStyle(.title1, fontWeight: .bold)
        title.textColor = WPStyleGuide.darkGrey()
        title.adjustsFontForContentSizeCategory = true
    }

    private func styleSubtitle() {
        subtitle.font = WPStyleGuide.fontForTextStyle(.body, fontWeight: .regular)
        subtitle.textColor = WPStyleGuide.greyDarken10()
        subtitle.adjustsFontForContentSizeCategory = true
    }

    func setTitle(_ text: String) {
        title.text = text
        title.accessibilityLabel = text
    }

    func setSubtitle(_ text: String) {
        subtitle.text = text
        subtitle.accessibilityLabel = text
    }
}
