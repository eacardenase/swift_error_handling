import Cocoa

enum Token: CustomStringConvertible {
    case number(Int)
    case plus, minus
    
    var description: String {
        switch self {
        case .number(let n):
            return "Number: \(n)"
        case .plus:
            return "Symbol: +"
        case .minus:
            return "Symbol: -"
        }
    }
}

class Lexer {
    enum Error: Swift.Error {
        case invalidCharacter(Character, String.Index)
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
    
    func getNumber() -> Int {
        var value = 0
        
        while let nextCharacter = peek() {
            switch nextCharacter {
            case "0"..."9":
                let digitValue = Int(String(nextCharacter))!
                
                value = 10 * value + digitValue
                
                advance()
            default:
                return value
            }
        }
        
        return value
    }
    
    func lex() throws -> [Token] {
        var tokens = [Token]()
        
        while let nextCharacter = peek() {
            switch nextCharacter {
            case "0"..."9":
                let value = getNumber()
                
                tokens.append(.number(value))
            case "+":
                tokens.append(.plus)
                advance()
            case "-":
                tokens.append(.minus)
                advance()
            case " ":
                advance()
            default:
                throw Lexer.Error.invalidCharacter(nextCharacter, position)
            }
        }
        
        return tokens
    }
}

class Parser {
    enum Error: Swift.Error {
        case unexpectedEndOfInput
        case invalidToken(Token)
    }
    
    let tokens: [Token]
    var position = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func getNextToken() -> Token? {
        guard position < tokens.count else {
            return nil
        }
        
        let token = tokens[position]
        position += 1
        
        return token
    }
    
    func getNumber() throws -> Int {
        guard let token = getNextToken() else {
            throw Parser.Error.unexpectedEndOfInput
        }
        
        switch token {
        case .number(let value):
            return value
        case .plus, .minus:
            throw Parser.Error.invalidToken(token)
        }
    }
    
    func parse() throws -> Int {
        var value = try getNumber()
        
        while let token = getNextToken() {
            switch token {
            case .plus:
                let nextNumber = try getNumber()
                value += nextNumber
            case .minus:
                let nextNumber = try getNumber()
                value -= nextNumber
            case .number:
                throw Parser.Error.invalidToken(token)
            }
        }
        
        return value
    }
}

func evaluate(_ input: String) {
    print("Evaluating: \(input)")
    
    let lexer = Lexer(input: input)
//    guard let tokens = try? lexer.lex() else {
//        print("Lexer failed, but I don't know why")
//        
//        return
//    }
    
    do {
        let tokens = try lexer.lex()
        print("Lexer output: \(tokens)")
        
        let parser = Parser(tokens: tokens)
        let result = try parser.parse()
        print("Parser output: \(result)")
    } catch let Lexer.Error.invalidCharacter(character, position) {
        let distanceToPosition = input.distance(from: input.startIndex, to: position)
        
        print("Input contained an invalid character at \(distanceToPosition): \(character)")
    } catch Parser.Error.unexpectedEndOfInput {
        print("Unexpected end of input during parsing")
    } catch Parser.Error.invalidToken(let token) {
        print("Invalid token during parsing: \(token)")
    } catch {
        print("An error ocurred: \(error)")
    }
}

//evaluate("10 + 3 + 5")
//evaluate("10+3+5")
//evaluate("10! + 3 + 5")
//evaluate("1 + 2 + three")
//evaluate("10 + 3 5")
//evaluate("10 + 3 +")
//evaluate("10 + 5 - 3 - 1")
//evaluate("1 + 3 + 7a + 8")
//evaluate("10 + 3 3 + 7")

let lexer = Lexer(input: "1 + 3 + 3 + 7")
let tokensResult = Result { try lexer.lex() }

switch tokensResult {
case let .success(tokens):
    print("Found \(tokens.count) tokens: \(tokens)")
case .failure(let error):
    print("Couldn't lex '\(lexer.input)': \(error)")
}

let numbersResult: Result<[Int], Error> = tokensResult.map { tokens in
    tokens.compactMap { token in
        switch token {
        case let .number(digit): return digit
        default: return nil
        }
    }
}

print(numbersResult)
