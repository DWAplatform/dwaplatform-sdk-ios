//
//  CardRestAPITest.swift
//  DWAplatformTests
//

import Foundation

import XCTest
@testable import DWAplatform

class CardRestAPITest : XCTestCase {

    private let hostName = "myhostname.com"
    private let  cardNumber = "1234123412341234"
    private let  expiration = "1122"
    private let  cxv = "123"
    
    override func setUp() {
        super.setUp()
    }
    
    func test_getCardSafe_Sandbox(){
        // Given
        let cardToRegister = CardRestAPI.CardToRegister(cardNumber: cardNumber, expiration: expiration, cvx: cxv)
        let jsonData = "{\"cardNumber\": \"1111222233334444\", \"expiration\": \"0120\", \"cxv\":\"111\"}".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let errorResponse: Error? = nil
        
        let session = MockURLSession(data: jsonData,
                                     urlResponse: urlResponse,
                                     error: errorResponse)
        
        let cardRestAPI = CardRestAPI(hostName: hostName, sandbox: true)
        cardRestAPI.session = session
        
        // When
        let cardSafeEpectation = expectation(description: "cardSafeEpectation")
        var catchedResult: CardRestAPI.CardToRegister? = nil
        var errorResult : Error? = nil
        cardRestAPI.getCardSafe(cardFrom: cardToRegister) { (result, error) in
            catchedResult = result
            errorResult = error
            cardSafeEpectation.fulfill()
        }
        
        // Then
        XCTAssertEqual("https://myhostname.com/rest/client/user/account/card/test", session.request?.url?.absoluteString)
        XCTAssertEqual("GET", session.request?.httpMethod)
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(errorResult)
            XCTAssertNotNil(catchedResult)
            
            XCTAssertEqual("1111222233334444", catchedResult?.cardNumber)
            XCTAssertEqual("0120", catchedResult?.expiration)
            XCTAssertEqual("111", catchedResult?.cvx)
        }
    }
    
    func test_getCardSafe_NotSandbox(){
        // Given
        let cardToRegister = CardRestAPI.CardToRegister(cardNumber: cardNumber, expiration: expiration, cvx: cxv)
        
        let jsonData = "{\"cardNumber\": \"1111222233334444\", \"expiration\": \"0120\", \"cxv\":\"111\"}".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let errorResponse: Error? = nil
        
        let session = MockURLSession(data: jsonData,
                                     urlResponse: urlResponse,
                                     error: errorResponse)
        
        let cardRestAPI = CardRestAPI(hostName: hostName, sandbox: false)
        cardRestAPI.session = session
        
        // When
        let cardSafeEpectation = expectation(description: "cardSafeEpectation")
        var catchedResult: CardRestAPI.CardToRegister? = nil
        var errorResult : Error? = nil
        cardRestAPI.getCardSafe(cardFrom: cardToRegister) { (result, error) in
            catchedResult = result
            errorResult = error
            cardSafeEpectation.fulfill()
        }
        
        // Then
        XCTAssertNil(session.request)
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(errorResult)
            XCTAssertNotNil(catchedResult)
            
            XCTAssertEqual(cardToRegister.cardNumber, catchedResult?.cardNumber)
            XCTAssertEqual(cardToRegister.cvx, catchedResult?.cvx)
            XCTAssertEqual(cardToRegister.expiration, catchedResult?.expiration)
        }
    }
    
    func test_postCardRegisterSuccess() {
        // Given
        let jsonData = "{\"cardRegistrationId\": \"22222444333\", \"url\": \"https://example.com\", \"preregistrationData\":\"111\", \"accessKey\": \"665748\", \"tokenCard\":\"99116574\"}".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let errorResponse: Error? = nil
        
        let session = MockURLSession(data: jsonData,
                                     urlResponse: urlResponse,
                                     error: errorResponse)
        let cardRestApi = CardRestAPI(hostName: hostName, sandbox: true)
        cardRestApi.session = session
        
        // When
        let cardSafeEpectation = expectation(description: "cardSafeEpectation")
        var catchedResult : CardRestAPI.CardRegistration? = nil
        var errorResult : Error? = nil
        cardRestApi.postCardRegister(token: "123token", alias: "111111XXXXXX34444", expiration: "1125") { (result, error) in
            catchedResult = result
            errorResult = error
            cardSafeEpectation.fulfill()
        }
        
        // Then
        XCTAssertEqual("https://myhostname.com/rest/client/user/account/card/register", session.request?.url?.absoluteString)
        XCTAssertEqual("POST", session.request?.httpMethod)
        XCTAssertNotNil(session.request?.httpBody)
        
        do {
            let requestJson = try JSONSerialization.jsonObject(
                with: session.request!.httpBody!,
                options: []) as? [String:String]
            
            XCTAssertEqual("111111XXXXXX34444", requestJson!["alias"]!)
            XCTAssertEqual("1125", requestJson!["expiration"]!)
            
        } catch { XCTFail() }
        
        waitForExpectations(timeout: 1, handler: {(error) in
            XCTAssertNil(errorResult)
            XCTAssertNotNil(catchedResult)
            
            XCTAssertEqual("22222444333", catchedResult?.cardRegistrationId)
            XCTAssertEqual("https://example.com", catchedResult?.url)
            XCTAssertEqual("111", catchedResult?.preregistrationData)
            XCTAssertEqual("665748", catchedResult?.accessKey)
            XCTAssertEqual("99116574", catchedResult?.tokenCard)
        })
    }
    
    func test_postCardRegisterNotSuccess() {
        // Given
        let jsonData : Data? = nil
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let errorResponse = ErrorMock.SessionError
        
        let session = MockURLSession(data: jsonData,
                                     urlResponse: urlResponse,
                                     error: errorResponse)
        let cardRestApi = CardRestAPI(hostName: hostName, sandbox: false)
        cardRestApi.session = session
        
        // When
        let cardSafeEpectation = expectation(description: "cardSafeEpectation")
        var catchedResult : CardRestAPI.CardRegistration? = nil
        var errorResult : Error? = nil
        
        cardRestApi.postCardRegister(token: "123token", alias: "111111XXXXXX34444", expiration: "1125") { (result, error) in
            catchedResult = result
            errorResult = error
            cardSafeEpectation.fulfill()
        }
        
        // Then
        XCTAssertEqual("https://myhostname.com/rest/client/user/account/card/register", session.request?.url?.absoluteString)
        session.request?.httpMethod = "GET"
        
        waitForExpectations(timeout: 1, handler: {(error) in
            XCTAssertNotNil(errorResult)
            XCTAssertTrue(errorResult is ErrorMock)
            XCTAssertEqual(errorResponse, errorResult! as! ErrorMock)
            XCTAssertNil(catchedResult)
        })
    }
    
    func test_postCardRegistrationData() {
        // Given
        let cardToReg = CardRestAPI.CardToRegister(cardNumber: cardNumber, expiration: expiration, cvx: cxv)
        let cardRegistration = CardRestAPI.CardRegistration(cardRegistrationId: "123id", url: "https://example.com", preregistrationData: "123preregData", accessKey: "123accessKey")
        let data = "STRING_REPLY".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let errorResponse: Error? = nil
        
        let session = MockURLSession(data: data,
                                     urlResponse: urlResponse,
                                     error: errorResponse)
        
        let cardRestApi = CardRestAPI(hostName: hostName, sandbox: false)
        cardRestApi.session = session
        // When
        let cardSafeEpectation = expectation(description: "cardSafeEpectation")
        var catchedResult : String? = nil
        var errorResult : Error? = nil
        
        cardRestApi.postCardRegistrationData(card: cardToReg, cardRegistration: cardRegistration, completionHandler: { (responseString, error) in
                catchedResult = responseString
                errorResult = error
                cardSafeEpectation.fulfill()
            })
        
        // Then
        let requestData = String(data: session.request!.httpBody!, encoding: .utf8)
        
        XCTAssertTrue(requestData!.contains("data=123preregData"))
        XCTAssertTrue(requestData!.contains("accessKeyRef=123accessKey"))
        XCTAssertTrue(requestData!.contains("cardNumber=1234123412341234"))
        XCTAssertTrue(requestData!.contains("cardExpirationDate=1122"))
        XCTAssertTrue(requestData!.contains("cardCvx=123"))
        
        XCTAssertEqual("https://example.com", session.request?.url?.absoluteString)
        XCTAssertEqual("POST", session.request?.httpMethod)
        
        waitForExpectations(timeout: 1, handler: {(error) in
            XCTAssertNil(errorResult)
            XCTAssertNotNil(catchedResult)
            XCTAssertEqual("STRING_REPLY", catchedResult)
        })
    }
    
    func test_putRegisterCard() {
        // Given
        let jsonData = "{\"id\": \"123id\", \"alias\": \"123XXX321\", \"expiration\":\"1224\", \"currency\": \"EUR\", \"default\" : false, \"status\" : \"CREATED\", \"token\": \"1234token\" }".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://testexample.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let errorResponse: Error? = nil
        
        let session = MockURLSession(data: jsonData,
                                     urlResponse: urlResponse,
                                     error: errorResponse)
        
        let cardRestApi = CardRestAPI(hostName: hostName, sandbox: false)
        cardRestApi.session = session
        
        // When
        let cardSafeEpectation = expectation(description: "cardSafeEpectation")
        var catchedResult : Card? = nil
        var errorResult : Error? = nil
        
        cardRestApi.putRegisterCard(token: "123token", cardRegistrationId: "123regId", registration: "123registration") { (card, error) in
            catchedResult = card
            errorResult = error
            cardSafeEpectation.fulfill()
        }
        
        // Then
        XCTAssertEqual("PUT", session.request?.httpMethod)
        XCTAssertNotNil(session.request?.httpBody)
    
        do {
            let requestJson = try JSONSerialization.jsonObject(
                with: session.request!.httpBody!,
                options: []) as? [String:String]
            
            XCTAssertEqual("123registration", requestJson!["registration"]!)
        } catch { XCTFail() }
        
        XCTAssertEqual("https://myhostname.com/rest/client/user/account/card/register/123regId", session.request?.url!.absoluteString)
        
        let headerFields = session.request?.allHTTPHeaderFields
        XCTAssertEqual("Bearer 123token", headerFields!["Authorization"])
        
        waitForExpectations(timeout: 1, handler: {(error) in
            XCTAssertNil(errorResult)
            XCTAssertNotNil(catchedResult)
            XCTAssertEqual("123id", catchedResult?.id)
            XCTAssertEqual("123XXX321", catchedResult?.alias)
            XCTAssertEqual("1224", catchedResult?.expiration)
            XCTAssertEqual("CREATED", catchedResult?.status)
            XCTAssertEqual(false, catchedResult?.defaultValue)
            XCTAssertEqual("EUR", catchedResult?.currency)
            XCTAssertEqual("1234token", catchedResult?.token)
        })
    }
}

extension CardRestAPITest {
    
    class MockURLSession: SessionProtocol {
        
        var request: URLRequest?
        var url: URL?
        private let dataTask: MockTask
        
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            dataTask = MockTask(data: data,
                                urlResponse: urlResponse,
                                error: error)
        }
        
        func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
            -> URLSessionDataTask {
                
                self.url = url
                dataTask.completionHandler = completionHandler
                return dataTask
        }
        
        func dataTask(with request: URLRequest,
                      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
            
            self.request = request
            dataTask.completionHandler = completionHandler
            return dataTask
        }
    }
    
    class MockTask: URLSessionDataTask {
        private let data: Data?
        private let urlResponse: URLResponse?
        private let responseError: Error?
        
        typealias CompletionHandler = (Data?, URLResponse?, Error?)
            -> Void
        var completionHandler: CompletionHandler?
        
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            self.data = data
            self.urlResponse = urlResponse
            self.responseError = error
        }
        
        override func resume() {
            DispatchQueue.main.async() {
                self.completionHandler?(self.data,
                                        self.urlResponse,
                                        self.responseError)
            }
        }
    }
}

enum ErrorMock: Error {
    case SessionError
}





