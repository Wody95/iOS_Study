# [Automatic Reference Counting](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html#ID49)

자동 참조 카운팅

Swift는 ARC(Automatic Reference Counting)을 사용하여 앱의 메모리 사용량을 추적하고 관리합니다. 그렇기 때문에 Swift에선 ARC 덕분에 메모리 관리에 대해 생각할 필요가 없습니다. 조금 자세하게 말하자면, ARC는 해당 인스턴스가 더 이상 필요하지 않을 때 클래스 인스턴스에서 사용하는 메모리를 자동으로 해제합니다.

그런데 ARC도 만능은 아닙니다. 몇몇의 경우에 대해선 ARC도 메모리를 관리하기 위해 코드 부분 간의 관계에 대해 추가 정보가 필요로 합니다.(메모리 제어를 위해 추가 조작이 필요합니다) 그렇기 때문에 우리는 ARC의 작동 방식을 이해해야 할 필요가 있습니다.

Reference Counting은 클래스의 인스턴스에만 적용됩니다. 구조 및 열거형은 참조 유형이 아닌 Value(값) 유형이며 참조에 의한 저장 및 전달되지 않습니다.

([기존의 Objective-C 에서 Swift-ARC로 전환에 대해 참고할만한 문서](https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html))

![https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Art/ARC_Illustration.jpg](https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Art/ARC_Illustration.jpg)

기존의 프로그래밍은 참조에 대해 관리(retain/release)하는 코드가 필요해 코드 작성이 어려웠지만, ARC의 도입으로 관리 코드를 작성하지 않아도 자동으로 관리되기 때문에 코딩 난이도가 낮아졌다.

## ARC의 작동 방식

ARC는 클래스의 새 인스턴스를 생성할 때마다, 해당 인스턴스에 대한 정보를 저장하기 위해 메모리 청크를 할당합니다. 이 메모리는 해당 인스턴스와 관련된 저장된 속성 값과 함께 인스턴스 유형에 대한 정보를 보유합니다.

또한 인스턴스가 더 이상 필요하지 않은 경우 ARC는 해당 인스턴스가 사용하는 메모리를 해제하여 메모리를 대신 다른 용도로 사용할 수 있도록 합니다. 이렇게 하면 클래스 인스턴스가 더 이상 필요하지 않을 때 메모리 공간을 차지하지 않습니다.

그런데 ARC가 여전히 사용 중인 인스턴스의 할당을 해제하는 경우 더 이상 해당 인스턴스의 속성에 엑세스하거나 해당 인스턴스의 메서드를 호출할 수 없습니다. 실제로 인스턴스에 엑세스하려고 하면 앱이 충돌할 가능성이 높습니다.

(언제 사용중인 인스턴스 할당을 해제하는 경우가 생길까? → 인스턴스를 더 이상 사용하지 않을 때 할당을 해제한다.)

인스턴스가 여전히 필요한 동안 사라지지 않도록 하기 위해 ARC는 현재 각 클래스 인스턴스를 참조하는 속성, 상수 및 변수의 수를 추적합니다. ARC는 해당 인스턴스에 대한 활성 참조가 하나 이상 존재하는 한 인스턴스 할당은 해제하지 않습니다.

이를 가능하게 하기 위해 속성, 상수 또는 변수에 클래스 인스턴스 할당할 때 마다 해당 속성, 상수 또는 변수는 인스턴스에 대한 **강력한 참조**를 만듭니다. 참조는 해당 인스턴스를 확고하게 유지하고 강력한 참조가 남아있는 한 할당 해제를 허용하지 않기 때문에 "강력한 참조"라고 합니다.

→ 무분별한 참조 해제를 막기 위해 ARC는 인스턴스를 추적한다!

## 작동중인 ARC

ARC의 작동방식 예입니다!

```swift
class Person {
		let name: String
		init(name: String) {
				self.name = name
				print("\\(name) is being initalized")
		}
		deinit {
				print("\\(name) is being deinitalized")
		}
}
```

Person 클래스의 인스턴스를 `이니셜라이저`가 name 프로퍼티를 `print` 및 초기화를 하고 있습니다. 또한 인스턴스 할당이 해제될 때에도 `print` 가 동작합니다.

자 그러면 `Person` 클래스의 인스턴스를 다음과 같이 생성하면 어떻게 될까요?

```swift
var reference1: Person?
var reference2: Person?
var reference3: Person?
```

세 변수는 전부 `optional`한 `Person` 타입이기 때문에 자동 초기화되어 `nil` 값을 갖게 됩니다. 고로 Person 인스턴스를 참조하지 않습니다.

그럼 Person 클래스를 할당해보겠습니다.

```swift
reference1 = Person(name: "Wody")
// Prints "Wody is being initalized"
```

`nil` 값이었던 변수 `reference1`에게 `Person` 클래스를 참조하여 할당했습니다

이에 따라 Person의 `initalizer` 가 동작해 프린트문이 출력되었습니다.

(현재 Person reference count: 1)

reference1에 Person 인스턴스가 할당되었으므로 이제 reference1에는 Person 인스턴스에 대한 강력한 참조 관계가 되었습니다. 하나 이상의 강력한 참조가 되었기 때문에 ARC는 Person 메모리가 유지되고, 할당 해제되지 않도록 합니다.

동일한 Person 인스턴스를 두 개의 더 많은 변수에 할당하면 해당 인스턴스에 대한 두 개의 더 강력한 참조가 설정됩니다.

```swift
reference2 = reference1
reference3 = reference1
```

(현재 Person reference count: 3)

그런데 이런 상황에서 `reference1` 에 nil값을 할당하면 어떻게 될까요?

그리고 `reference1` 을 참조하고 있던 `reference2`에도 nil을 할당하면 어떻게 될까요?

```swift
reference1 = nil
reference2 = nil
```

`Person` 클래스를 참조하고 있던 `reference1`의 메모리가 `nil`이 되어도 `Person`은 `deinitalized` 되지 않습니다

(현재 Person reference count: 1)

reference3 가 아직 Person 인스턴스를 사용하고 있기 때문입니다. 즉 ARCsms Person의 세번째 참조이자 마지막 강력한 참조인 reference3의 값이 Person이 아닐 때, Person 인스턴스를 더 이상 사용하지 않는다고 판단하고 메모리 할당을 해제합니다.

```swift
reference3 = nil
// Prints "Wody is being deinitalized"
```

(현재 Person reference count: 0)

## 클래스 인스턴스 간의 순환 참조

위의 `Person` 클래스를 통해 알아본 ARC의 참조 주기는, 클래스를 생성한 인스턴스에 대한 참조 수를 추적하고

Person 클래스가 더 이상 필요하지 않을 때(reference count가 0일 때) 인스턴스를 할당 해제할 수 있었습니다.

그러나 클래스의 인스턴스의 **참조 카운트가 0인 지점에 도달하지 않는 코드**를 만들 수도 있습니다. 이는 두 클래스의 인스턴스가 순환 참조를 형성하여, 각 인스턴스가 다른 인스턴스를 계속 유지하는 경우를 발생할 수 있습니다. 이것을 `강력한 참조 사이클(Strong Reference Cycle)`이라고 부릅니다.

강한 참조 대신 약한 참조(weak) 혹은 소유되지 않은 참조(unowned)로 클래스 간의 관계 중 일부를 정의하여 순환 참조를 해결할 수 있습니다. [클래스 인스턴스간 순환 참조을 해결하는 문서를 참고해주세요](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html#ID52)

방법은 위 문서에 나와있으니 어떻게 생성될 수 있는지 예시를 알아보겠습니다. 예시는 사람과 아파트 블록에 거주하는 관계를 클래스로 정의합니다.

```swift
class Person {
    let name: String
    init(name: String) {
        self.name = name
    }

    var apartment: Apartment?
    deinit {
        print("\\(name) is being deinitalized")
    }
}

class Apartment {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }

    var tenant: Person?
    deinit {
        print(" Apartment \\(unit) is being deinitalized")
    }
}
```

`Person` 은 사람을 이름과 옵셔널한 값인 거주하는 아파트를 클래스 인스턴스로 갖고 있습니다.

`Apartment` 는 아파트의 동과 옵셔널한 값인 세입자를 클래스 인스턴스로 갖고 있습니다.

이제 변수를 만들어 두 클래스를 각각 할당해보도록 하겠습니다.

```swift
var wody: Person?
var unit101A: Apartment?

wody = Person(name: "Wody")
unit101A = Apartment(unit: "101A")
```

이렇게 생성된 인스턴스는 다음과 같은 구조를 갖습니다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/90b06aa7-4493-4ed4-aeb2-3b1fb3612971/Untitled.png)

이제 사람과 아파트 인스턴스에게 각각 거주하고 있는 아파트를, 세입자의 정보를 연결할 수 있습니다.

(강제 언랩핑(!)은 wody 및 unit101A의 옵셔널한 내부 프로퍼티를 언래핑하고, 액세스하는데 사용됩니다.)

```swift
wody!.apartment = unit101A
unit101A!.tenant = wody
```

이렇게 각각 프로퍼티에 인스턴스를 할당하게 되면 참조 구조는 다음 그림과 같이 변합니다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/804ccf5d-5da3-4b7d-873b-94c8e8d1a0be/Untitled.png)

이제 두 인스턴스를 연결하여 순환 참조가 발생했습니다.

`Person 인스턴스`인 `wody 변수`의 `apartment 프로퍼티`를 보면, `Apartment 인스턴스` 참조가 있으며,

`Apartment 인스턴스`에는 `Person 인스턴스`를 참조하고 있는 `tenant 프로퍼티`가 있습니다.

즉, 꼬리에 꼬리를 무는 구조로 Reference count가 0으로 떨어지지 않는 상황이 발생합니다. 이로 인해 ARC의 자동 관리가 동작하지 않아 메모리 할당이 해제되지 않습니다.

```swift
wody = nil
unit101A = nil
```

실제로 두 변수에 `nil`을 할당하여도 `Person`, `Apartment`에 대한 `deinitalizer` 가 동작하지 않습니다.

그로 인해 메모리 누수(메모리를 할당하고 있는 정보를 더 이상 사용하지 않지만, 메모리를 차지하고 있어 해당 메모리 자원을 사용할 수 없는 상황)가 발생합니다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/1f467656-d972-4744-9d1e-a38c68823e0c/Untitled.png)

(`var wody`와 `var unit`의 클래스 인스턴스를 향한 참조는 해제되었지만, 각 클래스 프로퍼티가 서로를 순환 참조 하고 있다)

그래서 이런 경우엔 강한 순환 참조(강력한 참조 사이클)을 해결 할 수 없습니다.

## 클래스 인스턴스 간의 강력한 참조 주기 해결

Swift는 클래스 유형의 속성으로 작업할 때 순환 참조를 해결하는 두 가지 방법을 제공합니다

- weak(약한 참조)
- unowned(소유되지 않은 참조)

약한 참조 및 소유되지 않은 참조를 사용하면 참조 주기의 한 인스턴스의 참조를 유지하지 않고 다른 인스턴스를 참조할 수 있습니다. 그러면 순환 참조를 방지하면서 서로를 참조할 수 있습니다.

다른 인스턴스의 수명이 더 짧은 경우, 즉 다른 인스턴스를 먼저 할당 해제할 수 있는 경우 약한 참조를 사용합니다. 위의 `Apartment` 예시에서 `var apartment`는 어느 시점에서 세입자가 없을 수 있는 것이 적절하므로 약한 참조는 순환 참조를 막는 적절한 방법입니다. 반대로 다른 인스턴스의 수명이 같거나 더 긴 경우에는 소유되지 않은 참조를 사용합니다.

- 클래스 프로퍼티의 수명이 클래스보다 짧다면 `weak`가 권장됩니다. nil을 통해 참조되지 않을 때를 대비할 수 있기 때문입니다.
- 클래스 프로퍼티의 수명이 같거나, 더 긴 경우에는 `unowned`가 권장됩니다. 수명이 같다면 nil이 들어갈 필요가 없으며, 더 긴 경우엔 소유하지 않고 참조함으로서 순환 참조를 방지할 수 있습니다.

### 약한 참조(weak)

약한 참조(weak)는 참조하는 인스턴스를 강력하게 유지하지 않습니다. 그렇기 때문에 `weak` 키워드가 있는 인스턴스는 참조하는 동안 할당 해제될 수 있습니다. 따라서 참조가 해제될 경우 ARC는 인스턴스를 nil로 자동으로 설정합니다. 그리고 약한 참조는 런타임에 nil값으로 **변경**할 수 있어야 하기 때문에 항상 `optional한 변수`로 선언되어야 합니다.

```swift
class Person {
    let name: String
    init(name: String) {
        self.name = name
    }

    var apartment: Apartment?
    deinit {
        print("\\(name) is being deinitalized")
    }
}

class Apartment {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }

    weak var tenant: Person?
    deinit {
        print(" Apartment \\(unit) is being deinitalized")
    }
}
```

이번에는 `class Apartment` 의 `var tenant` 가 약한 참조로 선언되었습니다.

그리고 두 변수 `wody` 와 `unit101A` 의 강력한 참조와 두 인스턴스 간의 링크는 여전히 같이 선언됩니다.

```swift
var wody: Person?
var unit101A: Apartment?

wody = Person(name: "Wody")
unit101A = Apartment(unit: "101A")

wody!.apartment = unit101A
unit101A!.tenant = wody
```

`Person` 인스턴스 `wody`의 프로퍼티 `var apartment`는 여전히 `Apartment` 인스턴스 `var unit101A`를 강한 참조하고 있지만, `Apartment` 프로퍼티 `weak var tenant`는 약한 참조로 선언되었기 때문에 `wody`를 nil로 참조를 중단하면 순환 참조는 발생하지 않고, Person의 참조도 해제됩니다.

```swift
wody = nil
// Prints "Wody is being deinitalized"
```

순환참조가 발생하지 않았기 때문에 `unit101A` 또한 nil로 참조 중단을 선언하면 `Apartment` 의 참조도 중단됩니다.

```swift
unit101A = nil
// Prints "Apartment 101A is being deinitalized"
```

### 소유되지 않은 참조(unowned)

소유되지 않은 참조는 참조하는 인스턴스를 강력하게 유지하지 않습니다. 그러나 약한 참조와 다르게 소유되지 않은 참조는 다른 인스턴스와 수명이 같거나 더 긴 경우에 사용됩니다. unowned 는 상수 혹은 변수 앞에 선언할 수 있습니다.

```swift
unowned let testCase1: String = "ok let"
unowned var testCase2: String?
```

소유되지 않은 참조는 약한 참조와 달리 항상 값이 유지되어야 합니다. 그래서 값을 nil로 할당할 수 없습니다.

(참조가 항상 할당 해제되지 않은 인스턴스를 참조한다고 확신하는 경우에만 소유되지 않은 참조를 사용!!)

다음 예는 은행 고객과 해당 고객의 사용 가능한 신용카드를 모델링하는 두 개의 클래스 `Customer`, `CreditCard`를 정의합니다. 두 클래스는 각각 다른 클래스를 인스턴스 속성으로 저장합니다. 이 관계는 순환 참조를 생성할 가능성이 있습니다.

그런데 이 예시는 세입자와 아파트의 관계와 다르게 볼 수 있습니다. 고객은 신용카드가 있거나 없을 수 있지만, 신용 카드는 항상 고객이 존재합니다(고객이 없다면 신용 카드는 존재하지 않습니다). 따라서 신용카드는 항상 고객과 연결됩니다.

( 신용카드의 수명 < 고객의 수명 )

```swift
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit {
        print("\\(name) is being deinitalized")
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
        print("Card #\\(number) is being deinitalized")
    }
}
```

(고객의 경우 이름은 정의되나, 신용카드가 없을 수 있기 때문에 초기값은 nil입니다)

(신용카드의 경우 만들어질 때 카드 번호와 소유자가 초기화됩니다)

```swift
var wody: Customer?

wody = Customer(name: "wody")
wody?.card = CreditCard(number: 1234_5678_9012_3456, customer: wody!)
```

`Customer`클래스의 인스턴스 `var wody` 는 신용카드를 갖게 되었습니다. 신용카드의 정보는 `number` 와 이용 고객인 `customer` 를 갖습니다.

이 상황에서 wody에 nil을 선언하여 할당을 해제하게 되면 순환 참조는 발생하지 않습니다.

1. Customer.card 의 값을 참조하여 들어가게 되면 `CreditCard(number: 1234_5678_9012_3456, customer: wody!)` 값을 알 수 있습니다.
2. 그러나 `CreditCard.customer` 인 `wody!` 를 참조하면 참조 해제된 nil 이므로 순환 참조는 발생하지 않습니다.

### 소유되지 않은(unowned) 선택적(var) 참조

소유되지 않은 참조를 선택적인 참조로 사용할 수 있습니다. ARC 관점에서 소유되지 않은 선택적 참조와 약한 참조는 모두 동일한 컨텍스트에서 사용될 수 있습니다. 이 둘의 차이점은 소유되지 않은 선택적 참조를 사용할 때 항상 유효한 개체를 참조하거나(옵셔널의 유무)로 확인할 책임이 있다는 것입니다.

(그럼 weak 랑 unowned var의 차이가 뭔데...?) → [스택오버플로우](https://stackoverflow.com/questions/54852878/optional-unowned-reference-versus-weak-in-swift-5-0)

- weak 와 unowned 의 차이를 optional의 여부로 구분했으나,

  Swift 5 업데이트 이후 unowned var를 통해 optional이 가능해지면서 기능적으로 구분이 모호해졌습니다.그러나 이 둘의 차이점은 언어적 의도에 있습니다.

  weak는 ARC의 예시에도 나와 있듯이 해당 약한 참조를 하는 인스턴스가 클래스보다 먼저 해제될 경우 사용합니다. 프로퍼티의 수명에 대한 개발자의 의도를 전달할 수 있습니다.

  unowned var의 경우 인스턴스가 존재하지 않을 수 있지만, 클래스보다 먼저 해제되지 않는다는 의도로 만들 수 있습니다. 그 예로 Node를 이야기할 수 있습니다.

  ```swift
  class Node {
  		unowned var parent: Node?
  		var child: Node?
  
  		init() {
  				self.parent = nil
  				self.child = nil
  		}
  }
  ```

  물론 `unowned var` 와 같은 기능을 하는 `weak`를 통해 순환 참조를 방지할 수 있지만, 둘의 차이는 개발자가 전달하는 의도에 있다고 볼 수 있습니다.

  - weak는 인스턴스가 먼저 사라질 수 있다.
  - unowned var는 처음에 nil값으로 존재할 수 있지만, 참조가 시작되면 클래스보다 먼저 해제되진 않는다.

이번 예시는 학교의 특정 부서에서 제공하는 과정을 추적하는 예 입니다.

스위프트 학교안에 `iOS교육 부서`가 있습니다. 그리고 iOS 교육 부서에서는 iOS를 처음 배우는 사람들을 위해 `iOS Starter Camp`라는 `교육 코스`를 제공하고 있습니다. 그리고 `iOS Starter Camp` 교육 코스에는 `Swift` , `UIKit` , `CoreData` 등의 코스가 있습니다.

```swift
class Department {
    var name: String
    var courses: [Course]
    init(name: String) {
        self.name = name
        self.courses = []
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
}
```

`Department` 에서는 각 코스에 대해 강력한 참조를 유지합니다. 그렇기 때문에 `Department` 는 `coures` 안에 있는 `Course` 를 소유합니다. `Course` 는 소유하지 않은 참조가 두 개 있습니다. 하나는 부서에 대한 참조(department)이고, 다른 하나는 학생이 수강해야 하는 다음 과정(nextCourse)에 대한 참조입니다.

`Course` 는 이 두 개체를 소유하지 않습니다. 모든 과정(`Course`)은 일부 부서의 프로퍼티 이므로 `department` 는 옵셔널하지 않습니다. 그러나 일부 과정에서는 후속 코스가 없기 때문에 `nextCourse` 는 옵셔널합니다.

```swift
let iosEducationDepartment = Department(name: "iOS Education")

let swift = Course(name: "Swift", in: iosEducationDepartment)
let uikit = Course(name: "UIKit", in: iosEducationDepartment)
let coreData = Course(name: "CoreData", in: iosEducationDepartment)

swift.nextCourse = uikit
uikit.nextCourse = coreData

iosEducationDepartment.courses = [swift, uikit, coreData]
```

위 코스는 iOS 교육 부서의 교육 과정입니다. swift, uikit, coreData 코스가 존재하며 선언된 순서대로 강의를 진행합니다.

### 소유되지 않은 참조 및 암시적으로 래핑되지 않은 선택적 속성

이게 무슨 말이지...?

위의 약한 참조 및 소유되지 않은 참조에 대한 예는 순환 참조를 깨야 하는 일반적인 두 시나리오를 다룹니다.

Person과 Apartment의 예시는 weak를 통해 잘 해결할 수 있습니다. Apartment 기준으로 세입자는 있을 수도, 없을 수도 있기 때문에 optional한 상황을 유연하게 대처합니다.

Customer 및 CreditCard 예시는 unowned를 통해 잘 해결할 수 있습니다. 신용카드 입장에서 고객은 절대 사라져선 안되는 정보입니다. 고객 정보 없이 발급되는 신용카드는 없기 때문입니다. 즉 Cutomer 인스턴스는 절대 nil이 될 수 없습니다.

그러나 두 속성 모두 항상 값을 가져야 하고, nil 초기화가 완료되면 두 속성 모두 없어져야 하는 시나리오가 있습니다. 이 시나리오에서는 한 클래스의 소유되지 않은 속성을 다른 클래스의 암시적으로 래핑되지 않은 옵셔널과 결합하는게 유용합니다.

이렇게 하면 초기화가 완료되고 두 속성 모두 (옵셔널 래핑 해제 없이) 직접 엑세스 할 수 있으며 여전히 순환 참조를 피할 수 있습니다.

아래 예제는 두 클래스 `Country` 및 `City` 의 인스턴스를 속성으로 저장합니다. 이 모델에서 모든 국가에는 항상 수도가 있어야 하며, 모든 도시는 항상 국가에 속해있어야 합니다. 이를 나타내기 위해 `Country` 클래스에는 `capitalCity` 프로퍼티가 있고, `City` 클래스에는 `country` 프로퍼티가 있습니다.

```swift
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
```

클래스 Country 는 City 클래스를 capitalCity를 통해 소유하고 있습니다. 그런데 City 클래스는 Country를 초기화 할 때 필요하며, Country는 초기화 할 때 City를 초기화하고 있습니다.

어떻게 보면 순환 구조처럼 보일 수 있습니다.

1. Country를 초기화 하기 위해 City 를 초기화 합니다.
2. City를 초기화 하기 위해 Country를 참조합니다.
3. City가 Country를 참조하기 위해 Country를 초기화...?

City 클래스에 unowned 키워드가 있지만, 이 구조는 초기화 구조에서 발생합니다.

그래서 우리는 Country의 프로퍼티 capitalCity를 강제 언래핑하여 암시적으로 래핑되지 않은 옵셔널한 속성으로 선언합니다. (?를 통해 옵셔널하게 선언해도 초기화는 진행되지만, 해당 값에 접근할 때 마다 옵셔널을 해제해야 합니다)

이렇게 하면 `Country`의 초기화 단계에서 `self.capialCity`에 전달되는 " `City` 초기화 파라메터로 들어가는 `self.capitalCity`의 값"은 완전히 초기화 된걸로 간주되어 정상적으로 `City` 인스턴스가 만들어지고, `self.capitalCity`에 할당됩니다.

→ 이 과정을 [2단계 초기화](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html#ID220) 라고 합니다.

이렇게 압시적으로 래핑되지 않은(!) 선택사항을 사용하면 2단계 초기화 요구 사항이 충족되며, 순환 참조를 피하면서 옵셔널을 해제하지 않아도 값을 엑세스 할 수 있습니다.

## 클로저로 인한 순환 참조

두 클래스 인스턴스 속성이 서로에 대한 강력한 참조를 보유할 때 순환 참조가 생성되는 방법을 위에서 배웠습니다. 또한 약한 참조와 소유되지 않은 참조를 사용하여 순환 참조를 깨는 방법도 배웠습니다.

클래스 인스턴스의 속성(프로퍼티)에 클로저를 할당하고 해당 클로저의 본문이 인스턴스를 캡처하는 경우에도 순환 참조가 발생할 수 있습니다. 이 캡처는 클로저의 본문과 같은 인스턴스 속성에 엑세스하거나 클로저와 같은 인스턴스를 메서드를 호출하기 때문에 발생할 수 있습니다. 두 경우 모두 엑세스로 인해 클로저가 캡처되어 순환 참조가 발생합니다.

왜 클로져에도 순환 참조가 발생하냐면, 클로저가 클래스와 같은 `reference` 유형이기 때문입니다. 프로퍼티에 클로저를 할당하게 되면, 클로저에 대한 참조를 할당하게 됩니다. 위에서 봤던 순환 참조의 예시와 같은 문제입니다. 두 개의 강력한 참조가 서로를 유지하는데, 이번에는 두 개의 클래스 인스턴스가 아닌 서로를 유지하는 클래스 인스턴스와 클로저입니다.

실제로 코드를 통해 클래스와 클로저가 어떻게 순환 참조를 발생시키는지 알아보겠습니다.

```swift
class HTMLElement {
    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        if let text = self.text {
            return "<\\(self.name)>\\(text)<\\(self.name)>"
        } else {
            return "<\\(self.name)>"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\\(name) is being deinit")
    }
}
```

`HTMLElement` 클래스의 속성 `name` 은 `h1` 혹은 `div` 와 같은 단락 요소이거나 줄바꿈을 위한 `br` 등을 정의합니다. 그래서 HTMLElement의 프로퍼티 asHTML을 호출하면 클로저의 동작으로 `self.text` 값이 nil이 아닐 경우 `text` 값을 `name` 값과 함께 출력하고 `text`가 nil일 경우 `name` 값만 출력하게 됩니다.

(그런데 text 프로퍼티는 상수인데 optional하게 하고, 초기화에 text를 전달하지 않을 경우 nil을 전달하여 text는 nil만 갖게 됩니다)

```swift
let heading = HTMLElement(name: "h1")
let defaultText = "기본 문자열"
heading.asHTML = {
    return "<\\(heading.name)>\\(heading.text ?? defaultText)<\\(heading.name)>"
}
// prints "<h1>기본 문자열<h1>"
```

그래서 asHTML의 클로저를 새롭게 정의해줍니다.

```swift
let paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())
// Prints "<p>hello, world<p>"
```

그런데 이 경우 순환 참조가 발생합니다.

`var paragraph`는 클래스 `HTMLElement`를 강력하게 참조합니다. 그리고 인스턴스의 asHTML 속성은 클로저에 대한 강력한 참조를 보유합니다. 그리고 클로저에 선언된 self는 HTMLElement 내부를 참조하기 때문에 클로저는 self를 캡처합니다.

- HTMLElement > 강한 참조 > Closure () → String 참조
- Clouser () → String > 강한 참조 > HTMLElement (클로저가 self를 여러번 참조 ex. name, text 등 하더라도 인스턴스에 대한 강력한 참조는 하나만 캡처합니다. HTMLElement 하나에 속성이 전부 있기 때문입니다)

paragraph를 nil로 참조를 끊어도 순환 참조는 끊어지지 않습니다.

## 클로저로 인한 순환 참조 해결

클로저의 캡처 목록을 정의하여 클로저와 클래스 인스턴스간의 순환 참조를 해결합니다.

캡처 목록은 클로저 본분 내에서 하나 이상의 참조 유형을 캡처할 때 사용할 규칙을 정의합니다.

두 클래스 인스턴스 간 순환 참조 방지와 마찬가지로 약한 참조 또는 소유되지 않은 참조를 사용합니다.

### 캡처 목록 정의

캡처 목록의 각 항목은 클래스 인스턴스(ex. self) 또는 일부 값으로 초기화 된 변수(ex. delegate = self.delegate)에 대한 참조와 함께 weak 또는 unowned 키워드입니다.

코드를 통해 설명하자면,

```swift
lazy var asHTML: () -> String = { [unowned self] in
    if let text = self.text {
        return "<\\(self.name)>\\(text)<\\(self.name)>"
    } else {
        return "<\\(self.name)>"
    }
}
```

`HTMLElement`의 속성 `asHTML 클로저`에 캡처목록 `[unowned self]` 를 정의하여 `self`를 소유되지 않은 참조로 선언합니다. (캡처목록은 매개변수와 반환 유형이 있을 경우 맨 앞에 배치합니다)

이 예시의 경우 `HTMLElement`의 속성 `asHTML` 클로저가 참조하는 `self`는 `HTMLElement` 인스턴스이므로 약한 참조보다 소유되지 않은 참조로 선언하는 것이 더 바람직합니다 (결국은 클로저는 HTMLElement의 속성으로 있으므로)

