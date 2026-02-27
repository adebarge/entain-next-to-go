import Testing
import Foundation
@testable import ViewModels
import Model

@Suite("RaceRowViewModel")
struct RaceRowViewModelTests {

    // MARK: - Static string formatting

    @Test("raceNumberText formats race number correctly")
    func raceNumberText() {
        let race = Race.make(raceNumber: 7)
        let row = RaceRowViewModel(race: race)
        #expect(row.raceNumberText == "Race 7")
    }

    @Test("categoryName returns localised name for horse")
    func categoryNameHorse() {
        let row = RaceRowViewModel(race: Race.make(category: .horse))
        #expect(row.categoryName == "Horse")
    }

    @Test("categoryName returns localised name for harness")
    func categoryNameHarness() {
        let row = RaceRowViewModel(race: Race.make(category: .harness))
        #expect(row.categoryName == "Harness")
    }

    @Test("categoryName returns localised name for greyhound")
    func categoryNameGreyhound() {
        let row = RaceRowViewModel(race: Race.make(category: .greyhound))
        #expect(row.categoryName == "Greyhound")
    }

    @Test("accessibilityLabel formats race number, meeting, category")
    func accessibilityLabel() {
        let race = Race.make(meetingName: "Randwick", raceNumber: 3, category: .horse)
        let row = RaceRowViewModel(race: race)
        #expect(row.accessibilityLabel == "Race 3, Randwick, Horse race")
    }

    @Test("accessibilityHint formats race number and meeting")
    func accessibilityHint() {
        let race = Race.make(meetingName: "Randwick", raceNumber: 3)
        let row = RaceRowViewModel(race: race)
        #expect(row.accessibilityHint == "Race 3 at Randwick")
    }

    // MARK: - Dynamic countdown

    @Test("countdownText for future race shows 'Starts in' with minutes and seconds")
    func countdownTextFuture() {
        let now = Date()
        let race = Race.make(start: now.addingTimeInterval(1000)) // 16m 40s
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "Starts in 16 minutes 40 seconds")
    }

    @Test("countdownText for past race shows 'Started' with seconds")
    func countdownTextPast() {
        let now = Date()
        let race = Race.make(start: now.addingTimeInterval(-45)) // 45s ago
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "Started 45 seconds ago")
    }

    @Test("countdownText uses singular minute form")
    func countdownTextSingularMinute() {
        let now = Date()
        let race = Race.make(start: now.addingTimeInterval(65)) // 1m 5s
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "Starts in 1 minute 5 seconds")
    }

    @Test("countdownText uses singular second form")
    func countdownTextSingularSecond() {
        let now = Date()
        let race = Race.make(start: now.addingTimeInterval(121)) // 2m 1s
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "Starts in 2 minutes 1 second")
    }

    @Test("isStarted returns false for future race")
    func isStartedFuture() {
        let now = Date()
        let row = RaceRowViewModel(race: Race.make(start: now.addingTimeInterval(10)))
        #expect(!row.isStarted(at: now))
    }

    @Test("isStarted returns true for past race")
    func isStartedPast() {
        let now = Date()
        let row = RaceRowViewModel(race: Race.make(start: now.addingTimeInterval(-10)))
        #expect(row.isStarted(at: now))
    }

    // MARK: - RaceListViewModel static strings

    @Test("listTitle equals 'Next to Go'")
    func listTitle() {
        #expect(RaceListViewModel.listTitle == "Next to Go")
    }

    @Test("loadingMessage equals 'Loading races...'")
    func loadingMessage() {
        #expect(RaceListViewModel.loadingMessage == "Loading races...")
    }
}
