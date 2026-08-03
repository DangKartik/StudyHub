import Foundation

/// Which part of the day a greeting phrase belongs to — `.any` phrases work
/// regardless of hour, everything else only shows up during its own window.
enum GreetingTimeWindow {
    case morning
    case afternoon
    case evening
    case night
    case any
}

struct GreetingPhrase {
    let text: String
    let window: GreetingTimeWindow
}

/// A large, hand-written rotation of home-screen greetings (Home should
/// "greet you" with more personality than a fixed "Good morning/afternoon/
/// evening") — plain static content, no AI/network involved, same idea as
/// `HomeViewModel`'s quote-of-the-day rotation. A new one is picked each
/// time Home loads, filtered to phrases that fit the current hour (plus the
/// always-eligible `.any` ones).
enum GreetingLibrary {
    static let phrases: [GreetingPhrase] = [
        // Morning (5am - 12pm)
        .init(text: "Good morning", window: .morning),
        .init(text: "Rise and shine", window: .morning),
        .init(text: "Coffee and study", window: .morning),
        .init(text: "Early bird energy", window: .morning),
        .init(text: "Fresh start", window: .morning),
        .init(text: "Morning momentum", window: .morning),
        .init(text: "Sunrise scholar", window: .morning),
        .init(text: "Wake up and learn", window: .morning),
        .init(text: "Bright start", window: .morning),
        .init(text: "New day, new notes", window: .morning),
        .init(text: "Morning motivation", window: .morning),
        .init(text: "Up and at it", window: .morning),
        .init(text: "Dawn patrol", window: .morning),
        .init(text: "Breakfast and books", window: .morning),
        .init(text: "Sunny side up", window: .morning),
        .init(text: "Morning grind", window: .morning),
        .init(text: "First light focus", window: .morning),
        .init(text: "Caffeinated and curious", window: .morning),
        .init(text: "Early riser", window: .morning),
        .init(text: "Good morning, genius", window: .morning),
        .init(text: "Top of the morning", window: .morning),
        .init(text: "Fresh coffee, fresh mind", window: .morning),
        .init(text: "Morning glory", window: .morning),
        .init(text: "Kickstart the day", window: .morning),
        .init(text: "Sunrise session", window: .morning),

        // Afternoon (12pm - 5pm)
        .init(text: "Good afternoon", window: .afternoon),
        .init(text: "Midday momentum", window: .afternoon),
        .init(text: "Afternoon focus", window: .afternoon),
        .init(text: "Keep the pace", window: .afternoon),
        .init(text: "Halfway there", window: .afternoon),
        .init(text: "Afternoon push", window: .afternoon),
        .init(text: "Lunch and learn", window: .afternoon),
        .init(text: "Midday motivation", window: .afternoon),
        .init(text: "Sunny afternoon", window: .afternoon),
        .init(text: "Second wind", window: .afternoon),
        .init(text: "Afternoon grind", window: .afternoon),
        .init(text: "Power through", window: .afternoon),
        .init(text: "Midday check-in", window: .afternoon),
        .init(text: "Keep going", window: .afternoon),
        .init(text: "Afternoon energy", window: .afternoon),
        .init(text: "Steady as she goes", window: .afternoon),
        .init(text: "Midday hustle", window: .afternoon),
        .init(text: "Stay sharp", window: .afternoon),
        .init(text: "Onward and upward", window: .afternoon),
        .init(text: "Halfway hero", window: .afternoon),
        .init(text: "Midday focus mode", window: .afternoon),
        .init(text: "Afternoon study squad", window: .afternoon),
        .init(text: "Keep cruising", window: .afternoon),
        .init(text: "Afternoon check-in", window: .afternoon),
        .init(text: "Right on schedule", window: .afternoon),

        // Evening (5pm - 9pm)
        .init(text: "Good evening", window: .evening),
        .init(text: "Evening grind", window: .evening),
        .init(text: "Wind down and review", window: .evening),
        .init(text: "Evening focus", window: .evening),
        .init(text: "Twilight study", window: .evening),
        .init(text: "Sunset scholar", window: .evening),
        .init(text: "Evening momentum", window: .evening),
        .init(text: "Golden hour grind", window: .evening),
        .init(text: "Prime time to study", window: .evening),
        .init(text: "Evening push", window: .evening),
        .init(text: "Nightfall notes", window: .evening),
        .init(text: "Dusk study session", window: .evening),
        .init(text: "Evening energy", window: .evening),
        .init(text: "Wrap up strong", window: .evening),
        .init(text: "Evening reflection", window: .evening),
        .init(text: "Study by sunset", window: .evening),
        .init(text: "Twilight hours", window: .evening),
        .init(text: "Final stretch", window: .evening),
        .init(text: "Evening check-in", window: .evening),
        .init(text: "Sunset session", window: .evening),
        .init(text: "Evening effort", window: .evening),
        .init(text: "Dinner and diagrams", window: .evening),
        .init(text: "Evening groove", window: .evening),
        .init(text: "Golden hour focus", window: .evening),
        .init(text: "Evening wind-up", window: .evening),

        // Night (9pm - 5am)
        .init(text: "Midnight scholar", window: .night),
        .init(text: "Night owl session", window: .night),
        .init(text: "Burning the midnight oil", window: .night),
        .init(text: "Late night grind", window: .night),
        .init(text: "Moonlight study", window: .night),
        .init(text: "Night shift learning", window: .night),
        .init(text: "Insomniac genius", window: .night),
        .init(text: "Late night hustle", window: .night),
        .init(text: "Nocturnal knowledge", window: .night),
        .init(text: "Night owl energy", window: .night),
        .init(text: "Midnight momentum", window: .night),
        .init(text: "Quiet hours, loud focus", window: .night),
        .init(text: "Night session", window: .night),
        .init(text: "Stars and study guides", window: .night),
        .init(text: "Late night library vibes", window: .night),
        .init(text: "Midnight motivation", window: .night),
        .init(text: "Night owl mode: on", window: .night),
        .init(text: "Silent study hours", window: .night),
        .init(text: "After-hours academic", window: .night),
        .init(text: "Midnight musings", window: .night),
        .init(text: "Late night learner", window: .night),
        .init(text: "Nightcap and notes", window: .night),
        .init(text: "Under the moonlight", window: .night),
        .init(text: "Still up? Let's study", window: .night),
        .init(text: "Midnight scroller, turned scholar", window: .night),

        // Any time
        .init(text: "Ready to learn?", window: .any),
        .init(text: "Let's make today count", window: .any),
        .init(text: "Time to grow", window: .any),
        .init(text: "Small steps, big progress", window: .any),
        .init(text: "Knowledge awaits", window: .any),
        .init(text: "Let's get sharp", window: .any),
        .init(text: "Study mode: activated", window: .any),
        .init(text: "Your brain is ready", window: .any),
        .init(text: "Progress starts now", window: .any),
        .init(text: "Let's do this", window: .any),
        .init(text: "Focus mode: on", window: .any),
        .init(text: "Another day, another lesson", window: .any),
        .init(text: "Keep the streak alive", window: .any),
        .init(text: "Learning never stops", window: .any),
        .init(text: "Let's get to work", window: .any),
        .init(text: "Rise and grind", window: .morning),
        .init(text: "Good morning, let's go", window: .morning),
        .init(text: "First cup, first page", window: .morning),
        .init(text: "Fresh page, fresh you", window: .morning),
        .init(text: "Start before you're ready", window: .morning),
        .init(text: "Good afternoon, keep it up", window: .afternoon),
        .init(text: "One more push before the day's out", window: .afternoon),
        .init(text: "Afternoon reset", window: .afternoon),
        .init(text: "Still time to make today count", window: .afternoon),
        .init(text: "Good evening, almost there", window: .evening),
        .init(text: "Evening review time", window: .evening),
        .init(text: "One more session before you rest", window: .evening),
        .init(text: "Close the day out strong", window: .evening),
        .init(text: "Still awake, still capable", window: .night),
        .init(text: "Night owl mode", window: .night),
        .init(text: "The quiet hours are yours", window: .night),
        .init(text: "One more page before bed", window: .night),
        .init(text: "You again? Let's finish this", window: .any),
        .init(text: "Back for more, nice", window: .any),
        .init(text: "Today counts too", window: .any),
        .init(text: "Let's turn effort into progress", window: .any),
        .init(text: "Open the book, close the gap", window: .any),
        .init(text: "Your streak is watching", window: .any),
        .init(text: "Show up, even a little", window: .any)
    ]

    private static func window(for hour: Int) -> GreetingTimeWindow {
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default: return .night
        }
    }

    static func randomPhrase(hour: Int) -> String {
        let currentWindow = window(for: hour)
        let eligible = phrases.filter { $0.window == currentWindow || $0.window == .any }
        return eligible.randomElement()?.text ?? "Hello"
    }
}
