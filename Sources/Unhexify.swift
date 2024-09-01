// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

// https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

@main
struct Unhexify: ParsableCommand {
    @Option(name: .shortAndLong, help: "The data to unhexify.")
    var data: String

    @Option(name: .shortAndLong, help: "Output file name.")
    var outputFile: String

    mutating func run() throws {
        var inputData = [Character]()
        var position = 0
        for ch in data {
            if ch.isHexDigit {
                inputData.append(ch)
                position += 1
            } else if ch.isWhitespace {
                position += 1
                continue
            } else {
                print("Error: Invalid character in hex string at position \(position)")
                throw ExitCode.failure
            }
        }

        // Now we should have only hex digits in the input data.
        // Check that there is an even number of them.
        guard
            inputData.count % 2 == 0
        else {
            print("Error: Malformed hex string")
            throw ExitCode.failure
        }

        // Split the hex digits into pairs.
        // Then convert each pair to a byte.
        let pairs = inputData.chunked(into: 2)
        let byteData = pairs.map { UInt8(String($0), radix: 16)! }

        let outputData = Data(byteData)
        do {
            let outputFileURL = URL(fileURLWithPath: outputFile)
            try outputData.write(to: outputFileURL)
        } catch let error {
            print(error.localizedDescription)
            throw ExitCode.failure
        }
    }
}
