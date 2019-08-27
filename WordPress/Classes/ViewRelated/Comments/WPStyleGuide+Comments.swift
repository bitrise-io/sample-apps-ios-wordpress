import Foundation

import WordPressShared

/// This class groups all of the styles used by all of the CommentsViewController.
///
extension WPStyleGuide {
    public struct Comments {
        // MARK: - Public Properties
        //
        public static func gravatarPlaceholderImage(isApproved approved: Bool) -> UIImage {
            return approved ? gravatarApproved : gravatarUnapproved
        }

        public static func separatorsColor(isApproved approved: Bool) -> UIColor {
            return approved ? .divider : UIColor(light: .warning(.shade90), dark: .warning(.shade40))
        }

        public static func detailsRegularStyle(isApproved approved: Bool) -> [NSAttributedString.Key: Any] {
            let color = approved ? .textSubtle : UIColor(light: .warning(.shade90), dark: .warning(.shade40))

            return  [.paragraphStyle: titleParagraph,
                     .font: titleRegularFont,
                     .foregroundColor: color ]
        }

        public static func detailsRegularRedStyle(isApproved approved: Bool) -> [NSAttributedString.Key: Any] {
            let color = approved ? .text : UIColor(light: .error(.shade90), dark: .error(.shade40))

            return  [.paragraphStyle: titleParagraph,
                     .font: titleRegularFont,
                     .foregroundColor: color ]
        }

        public static func detailsItalicsStyle(isApproved approved: Bool) -> [NSAttributedString.Key: Any] {
            let color = approved ? .text : UIColor(light: .error(.shade90), dark: .error(.shade40))

            return  [.paragraphStyle: titleParagraph,
                     .font: titleItalicsFont,
                     .foregroundColor: color ]
        }

        public static func detailsBoldStyle(isApproved approved: Bool) -> [NSAttributedString.Key: Any] {
            let color = approved ? .text : UIColor(light: .error(.shade90), dark: .error(.shade40))

            return  [.paragraphStyle: titleParagraph,
                     .font: titleBoldFont,
                     .foregroundColor: color ]
        }

        public static func timestampStyle(isApproved approved: Bool) -> [NSAttributedString.Key: Any] {
            let color = approved ? .textSubtle : UIColor(light: .warning(.shade90), dark: .warning(.shade40))

            return  [.font: timestampFont,
                     .foregroundColor: color ]
        }

        public static func backgroundColor(isApproved approved: Bool) -> UIColor {
            return approved ? .listForeground : UIColor(light: .warning(.shade0), dark: .warning(.shade100))
        }

        public static func timestampImage(isApproved approved: Bool) -> UIImage {
            let timestampImage = UIImage(named: "reader-postaction-time")!
            return approved ? timestampImage : timestampImage.withRenderingMode(.alwaysTemplate)
        }



        // MARK: - Private Properties
        //
        fileprivate static let gravatarApproved     = UIImage(named: "gravatar")!
        fileprivate static let gravatarUnapproved   = UIImage(named: "gravatar-unapproved")!

        private static var timestampFont: UIFont {
            return WPStyleGuide.fontForTextStyle(.caption1)
        }

        private static var titleRegularFont: UIFont {
            return WPStyleGuide.fontForTextStyle(.footnote)
        }

        private static var titleBoldFont: UIFont {
            return WPStyleGuide.fontForTextStyle(.footnote, fontWeight: .semibold)
        }

        private static var titleItalicsFont: UIFont {
            return WPStyleGuide.fontForTextStyle(.footnote, symbolicTraits: .traitItalic)
        }

        private static var titleLineSize: CGFloat {
            return WPStyleGuide.fontSizeForTextStyle(.footnote) * 1.3
        }

        private static var titleParagraph: NSMutableParagraphStyle {
            return NSMutableParagraphStyle(minLineHeight: titleLineSize,
                                           maxLineHeight: titleLineSize,
                                           lineBreakMode: .byTruncatingTail,
                                           alignment: .natural)
        }
    }
}
