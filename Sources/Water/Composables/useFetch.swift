//
//  useFetch.swift
//  Water
//

import Foundation

// TODO: - use Swift Macro generate tuple from this struct
public struct UseFetchReturn<T> {
    let isFinished: ReactiveValue<Bool>
}

public func useFetch(url: String) -> (ReactiveValue<Bool>, ReactiveValue<String>, ReactiveValue<Data?>)  {
    let isFetching = defValue(false)
    let error = defValue("")
    let data = defValue(nil as Data?)
    
    @Sendable func execute() async {
        guard let url = URL(string: url) else {
            error.value = "url invalidate"
            return
        }
        let urlRequest = URLRequest(url: url)
        do {
            isFetching.value = true
            let (respData, response) = try await URLSession.shared.data(for: urlRequest)
            print("the response = \(response)")
            data.value = respData
            isFetching.value = false
        } catch let e {
            error.value = e.localizedDescription
            isFetching.value = false
        }
    }
    
    Task {
        await execute()
    }
    
    return (isFetching, error, data)
}
