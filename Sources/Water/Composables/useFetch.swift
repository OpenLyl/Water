//
//  useFetch.swift
//  Water
//

import Foundation

// TODO: - use Swift Macro generate tuple from this struct

public struct FetchResult: CustomDebugStringConvertible, Equatable {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest?
    public let response: HTTPURLResponse?

    public init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }

    public var description: String {
        "Status Code: \(statusCode), Data Length: \(data.count)"
    }

    public var debugDescription: String { description }

    public static func == (lhs: FetchResult, rhs: FetchResult) -> Bool {
        lhs.statusCode == rhs.statusCode && lhs.data == rhs.data && lhs.response == rhs.response
    }
}

extension FetchResult {
    public func mapString() -> String? {
        return String(data: data, encoding: .utf8)
    }
}

public enum FetchError: Error {
    case invalidUrl(String)
    case dataFetchFail
    case notHttpResponse
    case underlying(Error)
}

extension FetchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl(let url):
            return "invalid request url: \(url)"
        case .dataFetchFail:
            return "data fetch failed"
        case .notHttpResponse:
            return "cast response to http url response failed"
        case .underlying(let e):
            return "http request underlying error = \(e.localizedDescription )"
        }
    }
}

public typealias ExecuteFetchFn = ( @Sendable () async -> Void )

public typealias UseFetchReturn = (isFetching: ReactiveValue<Bool>, ReactiveValue<FetchResult?>, error: ReactiveValue<FetchError?>, execute: ExecuteFetchFn)

public func useFetch(url: String) -> UseFetchReturn {
    return useFetch({ url })
}

// TDOO: - 1. url support string 2. url support func 3. url support use reactive value 4. url support use computed
public func useFetch(_ urlGetter: @escaping () -> String, immediate: Bool = true) -> UseFetchReturn {
    let isFetching = defValue(false)
    let result = defValue(nil as FetchResult?) // FIXME : - thread problem
    let error = defValue(nil as FetchError?)
    
    // FIXME: - why use sendable
    @Sendable func execute() async {
        let url = urlGetter()
        guard let url = URL(string: url) else {
            error.value = .invalidUrl(url)
            return
        }
        isFetching.value = true
        let urlRequest = URLRequest(url: url)
        do {
            let (respData, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                error.value = .notHttpResponse
                return
            }
            
            let fetchResult = FetchResult(statusCode: httpResponse.statusCode, data: respData)
            
            // FIMXE: - trigger multi times problem
            print("-> set result brefore")
            result.value = fetchResult
            print("-> set result after")
            
            print("-> set is fetching before")
            isFetching.value = false
            print("-> set is fetching after")
        } catch let e {
            error.value = .underlying(e)
            isFetching.value = false
        }
    }
    
    if (immediate) {
        Task {
            await execute()
        }
    }
    
    return (isFetching, result, error, execute)
}
