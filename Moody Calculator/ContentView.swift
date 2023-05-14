//
//  ContentView.swift
//  Moody Calculator
//
//  Created by Matthews Ma on 2023-05-10.
//

import SwiftUI

enum CalcButton: String {
    case one        = "1"
    case two        = "2"
    case three      = "3"
    case four       = "4"
    case five       = "5"
    case six        = "6"
    case seven      = "7"
    case eight      = "8"
    case nine       = "9"
    case zero       = "0"
    
    case add        = "+"
    case subtract   = "-"
    case divide     = "÷"
    case multiply   = "×"
    case equal      = "="
    case clear      = "AC"
    case decimal    = "."
    case percent    = "%"
    case negative   = "⁺∕₋"
    
    var buttonColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return Color(.orange)
        case .clear, .negative, .percent:
            return Color(.lightGray)
        default:
            return Color(UIColor(red: 55/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1))
        }
    }
    
    var textColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return Color(.white)
        case .clear, .negative, .percent:
            return Color(.black)
        default:
            return Color(.white)
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, equal, none
}

struct ContentView: View {
    let MAX_INPUT_LENGTH = 11
    
    @State var value = "0"
    @State var runningNumber = 0.0
    @State var currentOperation: Operation = .none
    @State var showAlert = false
    @State var alertMessage = "Default"
    
    @State var buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Display
                HStack {
                    Spacer()
                    Text(formatDisplay(value))
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding()
                
                // Buttons
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                didTap(button: item)
                            }, label: {
                                Text(item.rawValue)
                                    .font(.system(size: 36))
                                    .frame(width: buttonWidth(item: item), height: buttonHeight())
                                    .background(item.buttonColor)
                                    .foregroundColor(item.textColor)
                                    .cornerRadius(buttonWidth(item: item)/2)
                            })
                        }

                    }.animation(.easeInOut, value: buttons)
                }
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    func formatDisplay(_ value: String) -> String {
        let intValue = Double(value)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: intValue ?? 0)) ?? "0"
    }
    
    @State var doResetValue = true
    @State var doResetRunningNumber = true
    
    func didTap(button: CalcButton) {
        switch button {
        case .add, .subtract, .multiply, .divide, .equal:
            if button == .add {
                currentOperation = .add
                self.runningNumber += Double(self.value) ?? 0
            } else if button == .subtract {
                currentOperation = .subtract
                self.runningNumber += Double(self.value) ?? 0
            } else if button == .multiply {
                currentOperation = .multiply
                self.runningNumber += Double(self.value) ?? 0
            } else if button == .divide {
                self.currentOperation = .divide
                self.runningNumber += Double(self.value) ?? 0
            } else if button == .equal {
                // Convert to Int then exploit built in ops.
                let runningValue = self.runningNumber
                let currentValue = Double(self.value) ?? 0
                equalsCount += 1
                equalsCountReact()
                
                switch self.currentOperation {
                case .add:
                    reactAdditionAndSubtraction()
                    self.value = "\(runningValue + currentValue)"
                case .subtract:
                    reactAdditionAndSubtraction()
                    self.value = "\(runningValue - currentValue)"
                case .multiply:
                    reactMultiplicationAndDivision()
                    self.value = "\(runningValue * currentValue)"
                case .divide:
                    reactMultiplicationAndDivision()
                    self.value = "\(runningValue / currentValue)"
                default:
                    break
                }
                
                // Reset number if starting a new calculation
                doResetRunningNumber = true
            }
            // Chaining together operations after equal
            if button != .equal {
                doResetRunningNumber = false
            }
            
            doResetValue = true
        case .clear:
            self.value = "0"
            self.runningNumber = 0
        case .decimal, .negative, .percent:
            if button == .negative {
                if !self.value.starts(with:"-") {
                    self.value = "-\(self.value)"
                } else {
                }
            } else if button == .decimal {
                // Change Int conversions to Double!
                if !self.value.contains(".") {
                    self.value = "\(self.value)."
                }
            }
        default:
            let number = button.rawValue
            if doResetValue {
                self.value = number
                doResetValue = false
                if doResetRunningNumber {
                    self.runningNumber = 0
                    doResetRunningNumber = false
                }
            } else {
                // Exploit strings to tack on the number at the end
                if self.value.count < MAX_INPUT_LENGTH {
                    self.value = "\(self.value)\(number)"
                }
            }
        }
    }
    
    func buttonWidth(item: CalcButton) -> CGFloat {
        if item == .zero {
            return (UIScreen.main.bounds.width - (4 * 12)) / 2
        }
        return (UIScreen.main.bounds.width - (5 * 12)) / 4
    }
    
    func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - (5 * 12)) / 4
    }
    
    
    // Reactivity
    
    // React by # of calculations done
    @State var equalsCount = 0
    @State var simpleEqualsCount = 0

    func equalsCountReact() {
        switch equalsCount {
        case 5:
            showAlertMessage("Knock it off, I'm getting tired.")
        case 6:
            showAlertMessage("I'm serious!")
        case 7:
            showAlertMessage("Okay, you asked for it.")
            shuffleNumbers()
        case 8...11:
            shuffleNumbers()
        case 12:
            showAlertMessage("Still going??")
        case 13...15:
            shuffleNumbers()
            shuffleOperators()
        case 16:
            showAlertMessage("I bet you're not even doing real calculations. Try this:")
            setAllNumbers(to: .seven)
        case 20:
            showAlertMessage("If you're forcing me to do much, might as well make it easier on me.")
            setAllOperators(to: .add)
        case 25:
            showAlertMessage("Bored yet?")
        case 30:
            showAlertMessage("All this tapping is making me sore.")
        case 50:
            showAlertMessage("... You beat me. Go ahead and make your calculations.")
            setButtonsToDefault()
        case 100:
            showAlertMessage("I can't take it anymore, going to sleep now...")
            sleep(3)
            crashApp()
        default:
            break
        }
    }
    
    // Responses by operation
    @State var simpleOperationReactionChance = 0.25
    @State var hardOperationReactionChance = 0.10
    
    func showAlertMessage(_ message: String) {
        if !showAlert {
            alertMessage = message
            showAlert = true
        }
    }
    var simpleCalculations = [
        "Did you really wake me up to input one digit numbers?",
        "Count on your fingers! It'd be faster than this.",
        "Yawn...",
        "You really don't need a calculator for this"
    ]
    var hardCalculations = [
        "Hey, I don't have time for this. Ask someone else.",
        "Calm down, I'm running out of memory.",
        "This screen space isn't free you know",
        "I have a friend called WolframAlpha, you should meet them."
    ]
    func simpleReact() {
        if Double.random(in: 0...1) > simpleOperationReactionChance {
            return
        }
        showAlertMessage(simpleCalculations.randomElement()!)
        simpleEqualsCount += 1
    }
    func hardReact() {
        if Double.random(in: 0...1) > hardOperationReactionChance {
            return
        }
        showAlertMessage(hardCalculations.randomElement()!)
    }
    func reactAdditionAndSubtraction() {
        if Int(value) ?? 0 < 15 {
            simpleReact()
        } else if Int(value) ?? 0 > 500000 {
            hardReact()
        }
    }
    func reactMultiplicationAndDivision() {
        if -5...5 ~= Int(value) ?? 0 || -5...5 ~= Int(runningNumber) {
            simpleReact()
        } else if Int(value) ?? 0 > 100 || Int(runningNumber) > 100 {
            hardReact()
        }
    }

    
    // Button shuffling
    func shuffleNumbers() {
        var numbersArray = [
            CalcButton.one, CalcButton.two, CalcButton.three,
            CalcButton.four, CalcButton.five, CalcButton.six,
            CalcButton.seven, CalcButton.eight, CalcButton.nine
        ]
        numbersArray.shuffle()
        for i in 1...3 {
            for j in 0...2 {
                buttons[i][j] = numbersArray.popLast()!
            }
        }
    }
    
    func shuffleOperators() {
        var operatorsArray = [
            CalcButton.divide, CalcButton.multiply,
            CalcButton.add, CalcButton.subtract,
        ]
        operatorsArray.shuffle()
        for i in 0...3 {
            buttons[i][3] = operatorsArray.popLast()!
        }
    }
    
    func setAllNumbers(to value: CalcButton) {
        for i in 1...3 {
            for j in 0...2 {
                buttons[i][j] = value
            }
        }
    }
    
    func setAllOperators(to value: CalcButton) {
        for i in 0...3 {
            buttons[i][3] = value
        }
    }
    
    func setButtonsToDefault() {
        buttons = [
            [.clear, .negative, .percent, .divide],
            [.seven, .eight, .nine, .multiply],
            [.four, .five, .six, .subtract],
            [.one, .two, .three, .add],
            [.zero, .decimal, .equal]
        ]
    }
    
    // Crash app
    func crashApp() {
        fatalError()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
