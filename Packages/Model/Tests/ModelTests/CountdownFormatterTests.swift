import Testing
@testable import Model

@Suite("CountdownFormatter")
struct CountdownFormatterTests {

    @Test("Formats positive intervals correctly")
    func formatsPositiveIntervals() {
        #expect(CountdownFormatter.string(from: 0) == "0:00")
        #expect(CountdownFormatter.string(from: 1) == "0:01")
        #expect(CountdownFormatter.string(from: 59) == "0:59")
        #expect(CountdownFormatter.string(from: 60) == "1:00")
        #expect(CountdownFormatter.string(from: 83) == "1:23")
        #expect(CountdownFormatter.string(from: 3661) == "61:01")
    }

    @Test("Formats negative intervals with leading minus")
    func formatsNegativeIntervals() {
        #expect(CountdownFormatter.string(from: -1) == "-0:01")
        #expect(CountdownFormatter.string(from: -45) == "-0:45")
        #expect(CountdownFormatter.string(from: -60) == "-1:00")
        #expect(CountdownFormatter.string(from: -83) == "-1:23")
    }

    @Test("Formats fractional seconds by truncating")
    func formatsFractionalSeconds() {
        #expect(CountdownFormatter.string(from: 1.9) == "0:01")
        #expect(CountdownFormatter.string(from: 59.999) == "0:59")
        #expect(CountdownFormatter.string(from: -0.5) == "-0:00")
    }
}
