import Foundation

// Test function to verify that ** characters are removed from API responses
func testCleanText() {
    let testCases = [
        "This is **bold** text",
        "**Important** information here",
        "Multiple **bold** words in **one** sentence",
        "No bold text here",
        "**",
        "****",
        "Text with ** in the middle",
        "**Start and end**"
    ]
    
    print("Testing cleanText function:")
    print(String(repeating: "=", count: 50))
    
    for testCase in testCases {
        let cleaned = testCase.replacingOccurrences(of: "**", with: "")
        print("Original: '\(testCase)'")
        print("Cleaned:  '\(cleaned)'")
        print("---")
    }
}

// Run the test
testCleanText()
