//
//  TaskNetworkService.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 25.05.2025.
//

import Foundation

struct RemoteTask: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct RemoteTaskResponse: Decodable {
    let todos: [RemoteTask]
}

protocol TaskNetworkServiceProtocol {
    func fetchTasks(completion: @escaping (Result<[RemoteTask], Error>) -> Void)
}

final class TaskNetworkService: TaskNetworkServiceProtocol {
    
    private let urlString = "https://dummyjson.com/todos"

    func fetchTasks(completion: @escaping (Result<[RemoteTask], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(RemoteTaskResponse.self, from: data)
                completion(.success(decoded.todos))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
}
