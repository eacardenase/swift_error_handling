import Cocoa

enum Token: CustomStringConvertible {
    case number(Int)
    case plus
    
    var description: String {
        switch self {
        case .number(let n):
            return "Number: \(n)"
        case .plus:
            return "Symbol: +"
        }
    }
}

class Lexer {
    enum Error: Swift.Error {
        case invalidCharacter(Character)
    }
    
    let input: String
    var position: String.Index
    
    init(input: String) {
        self.input = input
        self.position = input.startIndex
    }
    
    func peek() -> Character? {
        guard position < input.endIndex else {
            return nil
        }
        
        return input[position]
    }
    
    func advance() {
        assert(position < input.endIndex, "Cannot advance past lastIndex!")
        
        position = input.index(after: position)
    }
    
    func lex() throws -> [Token] {
        var tokens = [Token]()
        
        while let nextCharacter = peek() {
            switch nextCharacter {
            case "0"..."9":
                break
            case "+":
                tokens.append(.plus)
                advance()
            case " ":
                advance()
            default:
                throw Lexer.Error.invalidCharacter(nextCharacter)
            }
        }
        
        return tokens
    }
}
