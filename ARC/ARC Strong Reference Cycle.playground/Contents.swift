import Foundation

// weak
class Person {
    let name: String
    init(name: String) {
        self.name = name
    }

    var apartment: Apartment?
    deinit {
        print("\(name) is being deinitalized")
    }
}

class Apartment {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }

    weak var tenant: Person?
    deinit {
        print(" Apartment \(unit) is being deinitalized")
    }
}

var wody: Person?
var unit101A: Apartment?

wody = Person(name: "Wody")
unit101A = Apartment(unit: "101A")

wody!.apartment = unit101A
unit101A!.tenant = wody

wody = nil
unit101A = nil


// unowned
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit {
        print("\(name) is being deinitalized")
    }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit {
        print("Card #\(number) is being deinitalized")
    }
}

var wody: Customer?

wody = Customer(name: "wod")
wody?.card = CreditCard(number: 1234_5678_9012_3456, customer: wody!)


// unowned var
class Department {
    var name: String
    var courses: [Course]
    init(name: String) {
        self.name = name
        self.courses = []
    }
    deinit {
        print("department is deinit")
    }
}

class Course {
    var name: String
    unowned var department: Department
    unowned var nextCourse: Course?
    init(name:String, in department: Department) {
        self.name = name
        self.department = department
        self.nextCourse = nil
    }
    deinit {
        print("Course \(name) is deinit")
    }
}

var iosEducationDepartment: Department?
iosEducationDepartment = Department(name: "iOS Education")

var swift = Course(name: "Swift", in: iosEducationDepartment!)
var uikit = Course(name: "UIKit", in: iosEducationDepartment!)
var coreData = Course(name: "CoreData", in: iosEducationDepartment!)

swift.nextCourse = uikit
uikit.nextCourse = coreData

print(swift.nextCourse?.name)

iosEducationDepartment!.courses = [swift, uikit, coreData]
swift.nextCourse = nil
uikit.nextCourse = nil
print(swift.nextCourse?.name)

iosEducationDepartment = nil


// Unowned References and Implicitly Unwrapped Optional Properties

class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}

class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}

var country = Country(name: "Korea", capitalName: "Seoul")
print("\(country.name)'s capital city is called \(country.capitalCity.name)")

 Closure And Class
class HTMLElement {
    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        if let text = self.text {
            return "<\(self.name)>\(text)<\(self.name)>"
        } else {
            return "<\(self.name)>"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinit")
    }
}

let heading = HTMLElement(name: "h1")
let defaultText = "기본 문자열"
heading.asHTML = {
    return "<\(heading.name)>\(heading.text ?? defaultText)<\(heading.name)>"
}
print(heading.asHTML())

let paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())

// 클로저 순환 참조 해결 -> 캡처 목록

class HTMLElement {
    let name: String
    let text: String?

    lazy var asHTML: () -> String = { [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)<\(self.name)>"
        } else {
            return "<\(self.name)>"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinit")
    }
}
