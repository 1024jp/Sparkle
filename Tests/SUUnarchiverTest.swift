//
//  SUUnarchiverTest.swift
//  Sparkle
//
//  Created by Mayur Pawashe on 9/4/15.
//  Copyright © 2015 Sparkle Project. All rights reserved.
//

import XCTest

class SUUnarchiverTest: XCTestCase
{
    func unarchiveTestAppWithExtension(_ archiveExtension: String, password: String? = nil, resourceName: String = "SparkleTestCodeSignApp", expectingSuccess: Bool = true) {
        let appName = resourceName
        let archiveResourceURL = Bundle(for: type(of: self)).url(forResource: appName, withExtension: archiveExtension)!

        let fileManager = FileManager.default

        // Do not remove this temporary directory
        // If we do want to clean up and remove it (which isn't necessary but nice), we'd have to remove it
        // after *both* our unarchive success and failure calls below finish (they both have async completion blocks inside their implementation)
        let tempDirectoryURL = try! fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: NSHomeDirectory()), create: true)

        let unarchivedSuccessExpectation = super.expectation(description: "Unarchived Success (format: \(archiveExtension))")
        let unarchivedFailureExpectation = super.expectation(description: "Unarchived Failure (format: \(archiveExtension))")

        let extractedAppURL = tempDirectoryURL.appendingPathComponent(appName).appendingPathExtension("app")

        self.unarchiveTestAppWithExtension(archiveExtension, appName: appName, tempDirectoryURL: tempDirectoryURL, archiveResourceURL: archiveResourceURL, password: password, expectingSuccess: expectingSuccess, testExpectation: unarchivedSuccessExpectation)
        self.unarchiveNonExistentFileTestFailureAppWithExtension(archiveExtension, tempDirectoryURL: tempDirectoryURL, password: password, testExpectation: unarchivedFailureExpectation)

        super.waitForExpectations(timeout: 30.0, handler: nil)

        if !archiveExtension.hasSuffix("pkg") {
            XCTAssertTrue(fileManager.fileExists(atPath: extractedAppURL.path))
            XCTAssertEqual("6a60ab31430cfca8fb499a884f4a29f73e59b472", hashOfTree(extractedAppURL.path))
        }
    }

    func unarchiveNonExistentFileTestFailureAppWithExtension(_ archiveExtension: String, tempDirectoryURL: URL, password: String?, testExpectation: XCTestExpectation) {
        let tempArchiveURL = tempDirectoryURL.appendingPathComponent("error-invalid").appendingPathExtension(archiveExtension)
        let unarchiver = SUUnarchiver.unarchiver(forPath: tempArchiveURL.path, extractionDirectory: tempDirectoryURL.path, updatingHostBundlePath: nil, decryptionPassword: password)!

        unarchiver.unarchive(completionBlock: {(error: Error?) -> Void in
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }, progressBlock: nil)
    }

    // swiftlint:disable function_parameter_count
    func unarchiveTestAppWithExtension(_ archiveExtension: String, appName: String, tempDirectoryURL: URL, archiveResourceURL: URL, password: String?, expectingSuccess: Bool, testExpectation: XCTestExpectation) {
        let unarchiver = SUUnarchiver.unarchiver(forPath: archiveResourceURL.path, extractionDirectory: tempDirectoryURL.path, updatingHostBundlePath: nil, decryptionPassword: password)!

        unarchiver.unarchive(completionBlock: {(error: Error?) -> Void in
            if expectingSuccess {
                XCTAssertNil(error)
            } else {
                XCTAssertNotNil(error)
            }
            testExpectation.fulfill()
        }, progressBlock: nil)
    }

    func testUnarchivingZip()
    {
        self.unarchiveTestAppWithExtension("zip")
    }

    func testUnarchivingTarDotGz()
    {
        self.unarchiveTestAppWithExtension("tar.gz")
    }

    func testUnarchivingTar()
    {
        self.unarchiveTestAppWithExtension("tar")
    }

    func testUnarchivingTarDotBz2()
    {
        self.unarchiveTestAppWithExtension("tar.bz2")
    }

    func testUnarchivingTarDotXz()
    {
        self.unarchiveTestAppWithExtension("tar.xz")
    }

    func testUnarchivingDmg()
    {
        self.unarchiveTestAppWithExtension("dmg")
    }

    func testUnarchivingEncryptedDmg()
    {
        self.unarchiveTestAppWithExtension("enc.dmg", password: "testpass")
    }
    
    func testUnarchivingFlatPackage()
    {
        self.unarchiveTestAppWithExtension("pkg", resourceName: "test")
        
        self.unarchiveTestAppWithExtension("pkg", resourceName: "test.sparkle_interactive", expectingSuccess: false)
    }
}
