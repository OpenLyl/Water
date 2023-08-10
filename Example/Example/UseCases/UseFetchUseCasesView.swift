//
//  UseFetchUseCasesView.swift
//  Example
//

import SwiftUI
import Water

func UseFetchUseCasesView() -> some View {
    let (isFetching, error, data) = useFetch(url: "https://httpbin.org/get")
    
    return View {
        VStack {
            Text(isFetching.value ? "is fetching" : "fetch completed")
            Text("error = \(error.value)")
            if let data = data.value, let responseString = String(data: data, encoding: .utf8) {
                Text("data is \(responseString)")
            }
        }
    }
}

struct UseAsyncStateUseCaseView: View {
    var body: some View {
        UseAsyncStateView()
    }
}

extension UseAsyncStateUseCaseView {
    struct Todo: Codable {
        let id: Int
        let todo: String
        let completed: Bool
    }
    
    func fetchTodos() async -> [Todo] {
        let url = "https://dummyjson.com/todos"
        var request = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.data(for: request)
            if let res = response as? HTTPURLResponse, res.statusCode == 200 {
                let decoder = JSONDecoder()
                let todos = try decoder.decode([Todo].self, from: data, keyPath: "todos")
                return todos
            } else {
                print("response failed = \(response.description)")
                return []
            }
        } catch {
            print("request todos data error = \(error.localizedDescription)")
            return []
        }
    }
}

extension UseAsyncStateUseCaseView {
    func UseAsyncStateView() -> some View {
        let (state, isLoading) = useAsyncState(fetchTodos, [] as [Todo])
        
        var todos: [Todo] {
            state.value
        }

        return View {
            if isLoading.value {
                Text("loading...")
            } else {
                List(todos, id: \.id) { todo in
                    Text(todo.todo)
                }
            }
        }
    }
}

public extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data, keyPath: String) throws -> T {
        let toplevel = try JSONSerialization.jsonObject(with: data)
        if let nestedJson = (toplevel as AnyObject).value(forKeyPath: keyPath) {
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson)
            return try decode(type, from: nestedJsonData)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Nested json not found for key path \"\(keyPath)\""))
        }
    }
}

struct UseAsyncStateUseCaseView_Preivews: PreviewProvider {
    static var previews: some View {
        UseAsyncStateUseCaseView()
    }
}
