[원본 노션 링크](https://wodylikeios.notion.site/Optional-7551f7ca72f74bd3b84c6625b6cdf0f0)



[Apple Developer - Optional](https://developer.apple.com/documentation/swift/optional)

카테고리 : Swift - Swift Standard Library - Numbers And Basic - Optional

### 옵셔널 선언

```swift
@frozen enum Optional<Wrapped>
```

- 열거형의 내부 구조

  ```swift
  @frozen public enum Optional<Wrapped> : ExpressibleByNilLiteral {
  
      /// The absence of a value.
      ///
      /// In code, the absence of a value is typically written using the `nil`
      /// literal rather than the explicit `.none` enumeration case.
      case none
  
      /// The presence of a value, stored as `Wrapped`.
      case some(Wrapped)
  
      /// Creates an instance that stores the given value.
      public init(_ some: Wrapped)
  
      /// Evaluates the given closure when this `Optional` instance is not `nil`,
      /// passing the unwrapped value as a parameter.
      ///
      /// Use the `map` method with a closure that returns a non-optional value.
      /// This example performs an arithmetic operation on an
      /// optional integer.
      ///
      ///     let possibleNumber: Int? = Int("42")
      ///     let possibleSquare = possibleNumber.map { $0 * $0 }
      ///     print(possibleSquare)
      ///     // Prints "Optional(1764)"
      ///
      ///     let noNumber: Int? = nil
      ///     let noSquare = noNumber.map { $0 * $0 }
      ///     print(noSquare)
      ///     // Prints "nil"
      ///
      /// - Parameter transform: A closure that takes the unwrapped value
      ///   of the instance.
      /// - Returns: The result of the given closure. If this instance is `nil`,
      ///   returns `nil`.
  ```

- [ExpressibleByNilLiteral](https://developer.apple.com/documentation/swift/expressiblebynilliteral)

  Protocol이며, nil을 사용하여 초기화할 수 있는 유형을 의미

### 개요

옵셔널은 한글로 번역하면 `선택적`이라는 의미를 갖습니다.

그럼 스위프트에서 옵셔널이 하는 역할은 무엇일까요? 어떤 것을 `선택적` 으로 하는 것일까요?

공식문서에 따르면 옵셔널은 `래핑된 값` 또는 부재를 의미하는 `nil`을 나타내는 형식입니다.

래핑된 값, nil은 무엇일까요?

일단 먼저 스위프트에서 옵셔널을 선언하는 방법에 대해 알아보겠습니다.

```swift
let shortForm: Int? = Int("42")
let longForm: Optional<Int> = Int("42")

// Prints
// shortForm : Optional(42)
// longForm : Optional(42)
```

`상수 shortForm`과 `상수 longForm`의 타입 선언의 방식은 조금 다르나, 값은 Int타입인 42로 동일하게 선언됩니다. 그리고 두 상수를 프린트를 통해 알아보면 동일한 값이 출력되고 있습니다.

이제 옵셔널 선언을 분석해보겠습니다.

옵셔널의 선언은 순서대로 다음과 같습니다

1. @frozen
2. enum
3. Optional
4. <Wrapped>

## 1. @Frozen(겨울 왕국)

Swift에서 @로 시작하는건 [Attributes](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html)(속성)를 의미합니다.

그리고 속성은 두 가지 종류가 있는데 선언에 적용되는 속성과 유형에 적용되는 속성이 있습니다.

속성의 역할은 선언 또는 유형에 대한 추가 정보를 제공합니다.

속성에는 다양한 인수가 있고, 주요 속성은 공식문서에 설명하고 있으니 알아보는걸 추천드립니다.

프로즌은 구조체 혹은 열거형 선언제 적용하여 유형에 대해 변경할 수 있는 종류를 제한합니다!

또한 이 속성은 라이브러리의 evolution mode에서 컴파일링할 때만 허용됩니다.

라이브러리의 향후 버전에서는 열거형과 구조체의 저장된 인스턴스 속성을 추가, 제거 또는 재정렬하여 선언을 변경할 수 없습니다. 이러한 변경은 고정되지 않은 유형에서 허용되지만 고정 유형에 대한 ABI 호환성을 깨뜨립니다.

요약해서 말씀드리자면, 한번 만들어진 구조체와 열거형을 변경할 수 없도록 '설명' 하는 것입니다.

(이 구조체와 열거형은 이제 바꾸지마! 얼음!!)

## 2. enum 열거형

Optional은 열거형입니다. 그래서 옵셔널의 유형을 정의하는 두 가지 케이스가 있습니다.

```swift
@frozen public enum Optional<Wrapped> : ExpressibleByNilLiteral {
		...
		case none
		case some(Wrapped)

		public init(_ some: Wrapped)
}
```

위에서 언급한 `nil`을 의미하는 `none`과

`값을 래핑`한 `some`으로 이루어져 있습니다. 그래서 값이 존재할 경우 옵셔널에서 래핑한 값 some이 반환됩니다. → Optional(42)

## 3. Optional

타입의 이름입니다.

## 4. <Wrapped>

[제네릭](https://docs.swift.org/swift-book/LanguageGuide/Generics.html)하게 선언된 Wrapped는 래핑될 모든 유형의 타입을 의미합니다. `Optional`의 예제에선 `Int`타입만 옵셔널하게 만들었지만 `String` 등의 기본 타입 이외에도 사용자 정의 타입도 옵셔널을 사용할 수 있게 만들어줍니다.

# 그래서 옵셔널은 왜 사용하는거에요?



C언어부터 Java까지 유명한 프로그래밍 언어에는 null(swift에선 nil)개념이 있습니다. null은 위 사진처럼 메모리에 포인터가 빈 공간을 가리키는걸 의미합니다. (상수 혹은 변수를 통해 찾아갈 수 있는 메모리가 비어 있다.) 메모리가 비어있는데 빈 공간에 접근할 수 있다면 어떻게 될까요??

프로그램 보안상 매우매우 위험한 상황이 됩니다. 위 사진을 통해 예시를 들어보자면, 원래 휴지걸이에는 휴지만 들어와야 합니다. 그런데 만약 해커가 휴지걸이에 휴지 대신 테이프를 걸어둔다면 어떻게 될까요?

(물론 현실에서는 정상적으로 걸려있는 휴지를 빼고 테이프를 걸 수 있지만요.)

그래서 개발자들은 nil을 안전하게 처리하기 위해서 Optional이라는 개념을 만들었습니다. 비어있는 값을 이쁘게 포장해서 '있는 것 처럼' 다루게 되는거죠.



(해커가 빈 휴지걸이에 접근할 수 없도록 포장했습니다)

## 옵셔널로 포장된 값은 어떻게 사용할 수 있나요?

옵셔널로 포장된 값은 3가지 방법을 통해 사용할 수 있습니다.

1. 옵셔널 바인딩(Optional Binding)
2. 옵셔널 체이닝(Optioanl Chaining)
3. 강제 언래핑(Unconditional Unwrapping)

### 1. Optional Binding

옵셔널 바인딩은 옵셔널한 값을 새로운 변수로 할당하여 사용하는 방법입니다.

사용 방법으로는 if let, guard let, switch가 있습니다.

```swift
let optionalInt: Int? = Int("42")

if let bindingIfInt = optionalInt {
        print("bindingIfInt : \\(bindingIfInt)")
}

// Prints
// bindingIfInt : 42

func guardBinding() {
    guard let bindingGuardInt = optionalInt else { return }
    print("bindingGuardInt : \\(bindingGuardInt)")
}

guardBinding()

// Prints
// bindingGuardInt : 42
```

### 2. Optional Chaining

Chaining이라는 말 답게, 옵셔널을 연쇄적으로 사용하는걸 의미합니다. 그래서 옵셔널 체이닝을 사용한 결과 값은 언제나 옵셔널한 값이 나옵니다.

```swift
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
print("buzz's Phone: \\(buzz.phone)")

// prints
// buzz's Phone: nil

let cocoaBank = App(name: "cocoaBank")
let pineApplePhone = Phone(number: "010-xxxx-xxxx", app: cocoaBank)
let wody = Person(name: "wody", phone: pineApplePhone)

print(wody.phone?.bankApp?.name)
// prints
// Optioanl("cocoaBank")
```

만약 wody의 phone에 설치된 bankApp.name에 접근할 때 `!` 를 사용한다면 강제 언래핑이 됩니다.

### 강제 언래핑

강제 언래핑은 옵셔널한 값을 강제로 해체하여 값을 추출합니다.

옵셔널 값에 정상적으로 값이 있다면 괜찮지만, nil값을 강제 언래핑한다면 런타임 오류가 발생합니다.

```swift
// 2. optional chaining에서 사용된 wody 상수 이용

print(wody.phone!.bankApp!.name)
// prints
// cocoaBank
```