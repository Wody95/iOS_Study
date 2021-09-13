import UIKit

let shortForm: Int? = Int("42")
let longForm: Optional<Int> = Int("42")

print(shortForm)
print(longForm)


let optionalInt: Int? = Int("42")

if let bindingIfInt = optionalInt {
        print("bindingIfInt : \(bindingIfInt)")
}

// Prints
// bindingIfInt : 42


func guardBinding() {
    guard let bindingGuardInt = optionalInt else { return }
    print("bindingGuardInt : \(bindingGuardInt)")
}

guardBinding()

// Prints
// bindingGuardInt : 42


class Person {
    let name: String
    var phone: Phone?

    init(name: String, phone: Phone?) {
        self.name = name
        self.phone = phone
    }
}

class Phone {
    let number: String
    let bankApp: App?

    init(number: String, app: App?) {
        self.number = number
        self.bankApp = app
    }
}

class App {
    let name: String

    init(name: String) {
        self.name = name
    }
}

let buzz = Person(name: "buzz", phone: nil)
print("buzz's Phone: \(buzz.phone)")

// prints
// buzz's Phone: nil

let cocoaBank = App(name: "cocoaBank")
let pineApplePhone = Phone(number: "010-xxxx-xxxx", app: cocoaBank)
let wody = Person(name: "wody", phone: pineApplePhone)

print(wody.phone?.bankApp?.name)
// prints
// Optioanl("cocoaBank")

print(wody.phone!.bankApp!.name)
// prints
// cocoaBank

