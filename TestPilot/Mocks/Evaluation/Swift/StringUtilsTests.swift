import XCTest

class StringUtilsTests: XCTestCase {
    func testIsPalindrome_withEmptyString() {
        XCTAssertTrue(StringUtils.isPalindrome(""), "An empty string should be considered a palindrome")
    }

    func testIsPalindrome_withSingleCharacterString() {
        XCTAssertTrue(StringUtils.isPalindrome("A"), "A single character string should be considered a palindrome")
    }
    
    func testIsPalindrome_withPalindromeWords() {
        XCTAssertTrue(StringUtils.isPalindrome("racecar"), "The word 'racecar' should be identified as a palindrome")
        XCTAssertTrue(StringUtils.isPalindrome("level"), "The word 'level' should be identified as a palindrome")
    }
    
    func testIsPalindrome_withNonPalindromeWords() {
        XCTAssertFalse(StringUtils.isPalindrome("swift"), "The word 'swift' should not be identified as a palindrome")
        XCTAssertFalse(StringUtils.isPalindrome("programming"), "The word 'programming' should not be identified as a palindrome")
    }

    func testIsPalindrome_withPalindromePhrases() {
        XCTAssertTrue(StringUtils.isPalindrome("A man a plan a canal Panama"), "The phrase 'A man a plan a canal Panama' should be identified as a palindrome, ignoring spaces and case")
        XCTAssertTrue(StringUtils.isPalindrome("No lemon, no melon"), "The phrase 'No lemon, no melon' should be identified as a palindrome, ignoring punctuation and case")
    }
    
    func testIsPalindrome_withNonPalindromePhrases() {
        XCTAssertFalse(StringUtils.isPalindrome("Hello, world!"), "The phrase 'Hello, world!' should not be identified as a palindrome")
    }

    func testIsPalindrome_withSpecialCharacters() {
        XCTAssertTrue(StringUtils.isPalindrome("Madam, I'm Adam"), "The phrase 'Madam, I'm Adam' should be identified as a palindrome, ignoring punctuation, spaces, and case")
        XCTAssertFalse(StringUtils.isPalindrome("!@#$"), "A string with special characters and no letters should not be identified as a palindrome")
    }
}

