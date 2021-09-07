# 네트워크와 무관한 URLSession Unit Test

## 네트워크와 무관한 URLSession Unit Test를 하는 목적

- 유닛 테스트는 빠르고 안정적으로 진행되어야 합니다. 실제 서버와 통신하게되면 단위 테스트의 속도가 느려질 뿐만 아니라 인터넷 연결에 의존하기 때문에 테스트를 신뢰할 수 없습니다.
- 실제 서버와 통신하면 의도치 않은 결과를 불러올 수 있습니다. 예를 들어 우리는 서버에 `Item` 을 등록하는 코드를 테스트하길 원합니다. 그런데 실제 서버에 코드를 호출하면 데이터가 실제로 등록되기 때문에 의도치 않은 결과를 불러올 수 있습니다.

# 구현해보기

구현해보기 전에 앞서 URLSession의 Unit Test의 포인트를 먼저 알고 가는것이 좋다.

URLSession의 Unit Test의 포인트는 dataTask작업을 **가로채는 것**이다.

기본적인 URLSession의 동작은 3가지로 나뉘어진다.

1. URLSession의 호출
2. dataTask 메서드의 호출 및 동작
3. dataTask 메서드 종료 및 escaping 클로저를 통한 결과값 반환

그러면 네트워크와 무관한 테스트를 위해선 URLSession의 동작 전부를 Mock(가짜)로 가로채야 한다.

우리의 목표는 `MockURLSession`을 만들어서 `URLSessionProvider`의 응답을 조작하는 것이다.

### 0. 진짜 URLSession 만들기

진짜와 가짜를 나누고 구분하기 위해선 진짜(기준)를 알아야 한다.

기본적으로 동작하는 URLSessionProvider를 만들어본다.

```swift
struct User: Decodable {
    let id: Int
    let name: String
}

enum CustomError: Error {
    case statusCodeError
    case unknownError
}

class URLSessionProvider {
    let session: URLSession
    let baseURL = "<https://www.testwebpage.com/>"

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func dataTask(request: URLRequest, completionHandler: @escaping (Result<Data, CustomError>) -> Void) {

        let task = session.dataTask(with: request) { data, urlResponse, error in

            guard let httpResponse = urlResponse as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return completionHandler(.failure(.statusCodeError))
            }

            if let data = data {
                return completionHandler(.success(data))
            }

            completionHandler(.failure(.unknownError))
        }
        task.resume()
    }

    func getUser(id: Int, completionHandler: @escaping (Result<Data, CustomError>) -> Void) {

        guard let url = URL(string: baseURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        dataTask(request: request, completionHandler: completionHandler)
    }
}
```

기본적으로 만든 `URLSessionProvider` 는 dataTask 메소드를 통해 `session`의 `dataTask` 메소드를 호출해 사용한다.

우리가 주목해야 할 부분은 아래 메소드다.

```swift
let task = session.dataTask(with: request) { ... }
```

URLSession의 네트워크 동작이 어떻게 동작하던 저 메소드를 통해 요청하고 결과값은 escaping 클로저를 통해 반환된다. 그렇기 때문에 `요청` 과 `응답` 의 동작을 수행하는 저 dataTask 메소드의 데이터 흐름을 제어한다면 언제든지 네트워크와 무관한 모델 테스트가 가능해진다.

- 🧐 ??? : 요청과 응답을 조작하면 테스트 하는 의미가 있습니까?

  서버와 함께 개발하다보면 서버에서 제공하는 API 상세기능이 제공된다. 우리는 상세기능에 맞게 알맞은 Mock 데이터를 통해 모델이 정상적으로 동작하는지 테스트하면 된다.

  실제로 서버를 대상으로 테스트하는 것이 신뢰도 100%의 테스트가 되겠지만 서버의 동작과 동일한 결과값을 가진 Mock 데이터로 테스트한다면, 서버가 온전히 구축되지 않아도 테스트를 할 수 있게 된다. 애초에 네트워크와 무관한 테스트이기 때문이다.

우리는 URLSession에 존재하는 저 `.dataTask(with: ...)` 메소드를 새롭게 정의해야한다.

어디서? 우리가 만들 MockURLSession에서.

어떻게? URLSessionProtocol을 이용해서.

왜? dataTask 메소드의 요청에 따른 응답을 우리의 Mock Data로 교체하기 위해서.

### 1. URLSessionProtocol 만들기

`MockURLSession`을 만드는 목적은 진짜 `URLSession`의 `dataTask` 메소드를 교체하기 위해서다. 그리고 실제 코드에 적용하려면 `URLSessionProvider`의 `let seesion: URLSession` 을 우리가 만든 어떤 것으로 교체해야 한다.

이 말은 즉, `URLSession인 척`하면서 우리가 만든 `dataTask` 메소드를 가진 가짜를 만들어야 한다.

기존의 메소드를 override 하는것도 방법이겠지만 좋은 방법은 Protocol을 이용하는 것이다.

1.1 URLSessionProtocol 이용하기

Swift의 장점 중 하나는 Protocol이다. Protocol을 이용하면 손쉽게 대리자 구현 및 메서드 재정의가 가능하다.

```swift
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
```

프로토콜인 `URLSessionProtocol`을 채택한 모델은 `dataTask`를 구현해야 한다.

그리고 진짜 `URLSession`에게 `URLSessionProtocol`을 채택시킴으로서 `URLSessionProtocol`에 진짜 `URLSession`을 호출해도 정상적으로 돌아가게 된다 (가짜가 진짜보다 높은 계급인 척 하기)

dataTask 구현의 경우 진짜 URLSession 안에 dataTask가 이미 있으므로 구현한 것으로 친다.

1.2 URLSessionProvider에 URLSessionProtocol 적용

```swift
class URLSessionProvider {
    let session: URLSessionProtocol
    ...

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func dataTask(request: URLRequest, completionHandler: @escaping (Result<Data, CustomError>) -> Void) {
				...
    }
}
```

바뀐 부분만 써놨다. 기존의 `let session: URLSession` 이 `let session: URLSessionProtocol`

로 변했다. 초기화 안의 session 또한 변했다. 이렇게 되면 우리가 네트워크 없이 테스트 할 통신 모델 `URLSessionProvider` 의 핵심 역할인 `session`에 `MockURLSession`을 주입할 수 있게 된다.

### 2. MockURLSession 만들기

```swift
struct MockData {
    let data: Data = Data()
}

class MockURLSessionDataTask: URLSessionDataTask {
    var resumeDidCall: () -> Void = {}

    override func resume() {
        resumeDidCall
    }
}

class MockURLSession: URLSessionProtocol {
    var isRequestSuccess: Bool
    var sessionDataTask: MockURLSessionDataTask?

    init(isRequestSuccess: Bool = true) {
        self.isRequestSuccess = isRequestSuccess
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        let sucessResponse = HTTPURLResponse(url: request.url!,
                                             statusCode: 200,
                                             httpVersion: "2",
                                             headerFields: nil)
        let failureResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 402,
                                              httpVersion: "2",
                                              headerFields: nil)

        let sessionDataTask = MockURLSessionDataTask()

        if isRequestSuccess {
            sessionDataTask.resumeDidCall = {
                completionHandler(MockData().data, sucessResponse, nil)
            }
        } else {
            sessionDataTask.resumeDidCall = {
                completionHandler(nil, failureResponse, nil)
            }
        }
        self.sessionDataTask = sessionDataTask
        return sessionDataTask
    }
}
```

코드가 조금 긴데 천천히 설명하겠다.

`URLSessionProvider`의 `session` 역할을 대신 수행할 `MockURLSession`은 `URLSessionProtocol`을 채택하고 있다.

그래서 프로토콜의 요구사항에 맞게 dataTask 메소드를 구현했는데 동작 코드는 조금 다르다.

```
dataTask`의 성공 여부는 `var isRequestSuccess`에 의해 결정되고, 결과에 따른 response 내용 또한 직접 정의하고 있다. → `sucessResponse & failureResponse
```

여기서 조금 새로운건 `MockURLSessionDataTask`다. 이 클래스는 `URLSessionDataTask`를 상속받고 있고, `resume()` 메소드를 새롭게 정의하고 있다.

`resume()` 메소드를 `override` 하는 이유는 `URLSessionProvider`에서는 `dataTask`가 끝나고 네트워크 통신을 종료하기 위해 `resume()` 메소드를 호출하고 있는데 우리가 `Mock`으로 대체한 `session`을 가진 `URLSessionProvider`는 실제 통신을 하지 않았기 때문에 `resume()`의 통신 종료 메소드는 무언가 어색하다.

그래서 이 메소드를 호출할 때 클로저가 실행되도록 새롭게 정의해주는 것이다. 그리고 우리는 `resume()` 호출되는 시점을 `통신의 종료 = 응답` 의 시점으로 보고 조작한 응답값을 `completionHandler`를 통해 전달한다.

간단히 요약하자면 `dataTask`의 모든 동작을 `Mock`로 대체하기 위해 과정 중 포함되어 있는 `URLSessionDataTask`도 `Mock`으로 대체한 것이다.

### 3. Unit Test하기

이제 모든 준비는 끝났으니 열심히 테스트하면 된다.

```swift
import XCTest

class URLSessionProviderTest: XCTestCase {
    let mockSession = MockURLSession()
    var sut: URLSessionProvider!

    override func setUpWithError() throws {
    sut = .init(session: mockSession)
    }

    func test_getUser_success() {
        // 결과 data가 Json 형태라면
        let response = try? JSONDecoder().decode(User.self, from: MockData().data)

        // MockURLSession을 통해 테스트

        sut.getUser(id: 1) { result in
            switch result {
            case .success(let data):
                guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                    XCTFail("Decode Error")
                    return
                }
                XCTAssertEqual(user.id, response?.id)
                XCTAssertEqual(user.name, response?.name)
            case .failure(_):
                XCTFail("getUser failure")
            }
        }
    }

    func test_getUser_failure() {
        // MockSession이 강제로 실패하도록 설정
        sut = URLSessionProvider(session: MockURLSession(isRequestSuccess: false))

        // MockSession의 실패 응답의 httpStatus가 402로 설정되었으므로 반환되는 에러는 statusCodeError
        sut.getUser(id: 1) { result in
            switch result {
            case .success(_):
                    XCTFail("result is success")
            case .failure(let error):
                XCTAssertEqual(error, CustomError.statusCodeError)
            }
        }
    }
}
```
