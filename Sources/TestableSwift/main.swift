import Foundation
import Publish
import Plot
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct TestableSwift: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
//        var ingredients: [String]
//        var preparationTime: TimeInterval
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "https://your-website-url.com")!
    var name = "@testable Swift"
    var description = "A Swift blog by Anders Mannberg on test-driven development, functional programming and the stuff in between!"
    var language: Language { .english }
    var imagePath: Path? { nil }
}

try TestableSwift().publish(using: [
    .installPlugin(.splash(withClassPrefix: "")),
    .addMarkdownFiles(),
    .copyResources(),
    .generateHTML(withTheme: .testableSwift),
    .generateSiteMap()
])
