//
// This source file is part of Kombucha, an open source project by Wayfair
//
// Copyright (c) 2019 Wayfair, LLC.
// Licensed under the 2-Clause BSD License
//
// See LICENSE.md for license information
//

import Foundation
import KombuchaLib
import SPMUtility

typealias KombuchaArgs = (configuration: RunConfiguration, printErrorsOnly: Bool, recordMode: Bool, snapshotsURL: FileURL, workURL: FileURL)

func parseKombuchaArgs(_ args: [String], jsonDecoder: JSONDecoder) throws -> KombuchaArgs {
    let argumentParser = ArgumentParser(usage: "test", overview: "test")
    let parseConfigurationURL = argumentParser.add(positional: "configurationURLString", kind: String.self, optional: true)
    let parsePrintErrorsOnly = argumentParser.add(option: "--print-errors-only", shortName: "-e", kind: Bool.self, usage: nil, completion: .unspecified)
    let parseRecordMode = argumentParser.add(option: "--record", shortName: "-r", kind: Bool.self, usage: nil, completion: .unspecified)

    let parseSnapshotsDirectoryURL = argumentParser.add(option: "--snapshots-directory", shortName: "-s", kind: String.self, usage: nil, completion: .filename)
    let parseWorkDirectoryURL = argumentParser.add(option: "--work-directory", shortName: "-w", kind: String.self, usage: nil, completion: .filename)

    let parsed = try argumentParser.parse(args)

    let configuration: RunConfiguration
    if let configurationURL = parsed.get(parseConfigurationURL).flatMap(URL.init(fileURLWithPath:)) {
        let configurationData = try Data(contentsOf: configurationURL)
        configuration = try jsonDecoder.decode(RunConfiguration.self, from: configurationData)
    } else {
        let configurationURL = URL(fileURLWithPath: "./kombucha.json")
        let configurationData = try Data(contentsOf: configurationURL)
        configuration = try jsonDecoder.decode(RunConfiguration.self, from: configurationData)
    }

    let printErrorsOnly = parsed.get(parsePrintErrorsOnly) ?? false
    let recordMode = parsed.get(parseRecordMode) ?? false

    let snapshotsURL = parsed.get(parseSnapshotsDirectoryURL).flatMap(URL.init(fileURLWithPath:)) ??
        URL(fileURLWithPath: "./__Snapshots__/")

    let workURL = parsed.get(parseWorkDirectoryURL).flatMap(URL.init(fileURLWithPath:)) ??
        URL(fileURLWithPath: "./__Work__/")

    return (
        configuration: configuration,
        printErrorsOnly: printErrorsOnly,
        recordMode: recordMode,
        snapshotsURL: try FileURL(snapshotsURL),
        workURL: try FileURL(workURL)
    )
}
