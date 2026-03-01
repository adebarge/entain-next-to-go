import Testing
import Foundation
@testable import ViewModels
import Model

@Suite("RaceRowViewModel")
struct RaceRowViewModelTests {

    // MARK: - String formatting

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

    @Test("accessibilityLabel formats race number, meeting, category and start time")
    func accessibilityLabel() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let race = Race.make(meetingName: "Randwick", raceNumber: 3, start: start, category: .horse)
        let row = RaceRowViewModel(race: race)
        let expectedTime = start.formatted(.dateTime.hour().minute().second())
        #expect(row.accessibilityLabel == "Race 3, Randwick, Horse race, starts at \(expectedTime)")
    }

    // MARK: - Dynamic countdown

    @Test("countdownText for future race uses current localized short format")
    func countdownTextFuture() {
        let now = Date.now
        let race = Race.make(start: now.addingTimeInterval(1000)) // 16m 40s
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "16 mins 40 secs")
    }

    @Test("countdownText for past race uses current negative prefix format")
    func countdownTextPast() {
        let now = Date.now
        let race = Race.make(start: now.addingTimeInterval(-45)) // 45s ago
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "-45 secs")
    }

    @Test("countdownText uses singular minute form")
    func countdownTextSingularMinute() {
        let now = Date.now
        let race = Race.make(start: now.addingTimeInterval(65)) // 1m 5s
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "1 min 5 secs")
    }

    @Test("countdownText uses singular second form")
    func countdownTextSingularSecond() {
        let now = Date.now
        let race = Race.make(start: now.addingTimeInterval(121)) // 2m 1s
        let row = RaceRowViewModel(race: race)
        let text = row.countdownText(at: now)
        #expect(text == "2 mins 1 sec")
    }

    @Test("isStarted returns false for future race")
    func isStartedFuture() {
        let now = Date.now
        let row = RaceRowViewModel(race: Race.make(start: now.addingTimeInterval(10)))
        #expect(!row.isStarted(at: now))
    }

    @Test("isStarted returns true for past race")
    func isStartedPast() {
        let now = Date.now
        let row = RaceRowViewModel(race: Race.make(start: now.addingTimeInterval(-10)))
        #expect(row.isStarted(at: now))
    }

    // MARK: - RaceListViewModel localized strings

    @Test("listTitle equals 'Next to Go'")
    @MainActor
    func listTitle() {
        let testSubject = RaceListViewModel(service: NoopRaceService())
        #expect(testSubject.listTitle == "Next to Go")
    }

    @Test("loadingMessage equals 'Loading races...'")
    @MainActor
    func loadingMessage() {
        let testSubject = RaceListViewModel(service: NoopRaceService())
        #expect(testSubject.loadingMessage == "Loading races...")
    }
}

private struct NoopRaceService: RaceService {
    func fetchNextRaces(count: Int) async throws -> [Race] { [] }
}
