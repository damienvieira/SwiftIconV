//
//  SwiftIconVTests.swift
//  SwiftIconVTests
//
//  Created by C.W. Betts on 12/14/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftIconV

class SwiftIconVTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJapaneseDecoding() {
		let sjisEnc: [Int8] = [-124, 112, -127, 105, -127, 125, -124, 112, -125, 116, 0]
		let eucEnc: [Int8] = [-89, -47, -95, -54, -95, -34, -89, -47, -91, -43, 0]
		let sampJAStr = "а（±а\u{30D5}"

		if let sjisStr = try? IconV.convertCString(sjisEnc, fromEncodingNamed: "SJIS"), let eucStr = try? IconV.convertCString(eucEnc, fromEncodingNamed: "EUC-JP") {
			XCTAssertEqual(sampJAStr, sjisStr)
			XCTAssertEqual(sampJAStr, eucStr)
			XCTAssertEqual(sjisStr, eucStr)
		} else {
			XCTAssert(false, "Conversion failure")
		}
    }
    
	func testEncoderList() {
		let encs = IconV.availableEncodings()
		XCTAssertNotEqual(encs.count, 0)
		print(encs)
	}
	
	func testJapaneseDecodingFromCocoa() {
		let sampleJAStr = "а（±а\u{30D5} ∞"
		var sjisStr: String? = nil
		var eucStr: String? = nil
		
		if let sjisCStr = sampleJAStr.cString(using: String.Encoding.shiftJIS) {
			do {
				sjisStr = try IconV.convertCString(sjisCStr, fromEncodingNamed: "SJIS")
				XCTAssertEqual(sampleJAStr, sjisStr)
			} catch {
				XCTAssert(false, String(describing: error))
			}
		}
		
		if let eucCStr = sampleJAStr.cString(using: String.Encoding.japaneseEUC) {
			do {
				eucStr = try IconV.convertCString(eucCStr, fromEncodingNamed: "EUC-JP")
				XCTAssertEqual(sampleJAStr, eucStr)
			} catch {
				XCTAssert(false, String(describing: error))
			}
		}
		
		XCTAssertEqual(eucStr, sjisStr)
	}
	
	func testInfinitySymbol() {
		let infinity = "∞"
		let macOSRoman: [Int8] = [-80, 0]
		let sjis: [Int8] = [-127, -121, 0]
		let euc_JP: [Int8] = [-95, -25, 0]
		let utf8: [Int8] = [-30, -120, -98, 0]
		//let symbol: [Int8] = [-91, 0]
		let ISO2022JP: [Int8] = [27, 36, 66, 33, 103, 27, 40, 66, 0]
		let strsAndEnc: [(encodingName: String, cStr: [Int8])] = [("MACROMAN", macOSRoman),
			("SJIS", sjis),
			("EUC-JP", euc_JP),
			("UTF-8", utf8),
			("ISO-2022-JP", ISO2022JP)]
		
		for (enc, cStr) in strsAndEnc {
			do {
				let maybeInfinity = try IconV.convertCString(cStr, fromEncodingNamed: enc)
				XCTAssertEqual(infinity, maybeInfinity)
			} catch {
				XCTAssert(false, String(describing: error))
			}
		}
	}
	
	func testEncodingsList() {
		print(IconV.availableEncodings())
	}
	
	func testInvalidEncoding() {
		let macOSRoman: [Int8] = [-80, 0]
		do {
			let maybeInfinity = try IconV.convertCString(macOSRoman, fromEncodingNamed: "ASCII")
			XCTFail("Got \(maybeInfinity), expected throw")
		} catch let error as IconV.EncodingErrors {
			XCTAssertEqual(error, IconV.EncodingErrors.invalidMultibyteSequence, "Got unexpected error \"\(error)\"")
		} catch {
			XCTFail("Got unknown error \"\(error)\"")
		}
	}
	
	func testInvalidEncodingNames() {
		let invalids = ["ISO 8859-7", "Shift JIS"]
		
		for inv in invalids {
			if IconV(fromEncoding: inv) != nil {
				XCTFail("encoding \"\(inv)\" came back as valid!")
			}
		}
	}
}
