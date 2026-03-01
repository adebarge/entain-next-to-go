#if DEBUG
import Model
import Foundation

struct DemoRaceService: RaceService {
    func fetchNextRaces(count: Int) async throws -> [Race] {
        if UserDefaults.standard.bool(forKey: "demo_simulate_error") {
            throw URLError(.notConnectedToInternet)
        }
        let delay = UserDefaults.standard.double(forKey: "demo_loading_delay")
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }

        if UserDefaults.standard.bool(forKey: "demo_simulate_empty_state") {
            return []
        }

        let now = Date.now
        return [
            Race(id: "demo-1", meetingName: "Randwick", raceNumber: 3,
                 advertisedStart: now + 45, category: .horse),
            Race(id: "demo-2", meetingName: "The Meadows", raceNumber: 7,
                 advertisedStart: now + 90, category: .greyhound),
            Race(id: "demo-3", meetingName: "Menangle", raceNumber: 2,
                 advertisedStart: now + 150, category: .harness),
            Race(id: "demo-4", meetingName: "Eagle Farm", raceNumber: 5,
                 advertisedStart: now + 210, category: .horse),
            Race(id: "demo-5", meetingName: "Sandown", raceNumber: 1,
                 advertisedStart: now + 270, category: .greyhound),
            Race(id: "demo-6", meetingName: "Harold Park", raceNumber: 4,
                 advertisedStart: now + 330, category: .harness),
            Race(id: "demo-7", meetingName: "Flemington", raceNumber: 8,
                 advertisedStart: now + 390, category: .horse),
            Race(id: "demo-8", meetingName: "Wentworth Park", raceNumber: 3,
                 advertisedStart: now + 450, category: .greyhound),
            Race(id: "demo-9", meetingName: "Albion Park", raceNumber: 6,
                 advertisedStart: now + 510, category: .harness),
            Race(id: "demo-10", meetingName: "Rosehill", raceNumber: 2,
                 advertisedStart: now + 570, category: .horse)
        ]
    }
}
#endif
