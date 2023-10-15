//
//  NetworkDataFetcher.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 11.10.2023.

import Foundation

class NetworkDataFetcher {
    private let networkService = NetworkManager()
    
    func fetchJson(urlString: String, closure: @escaping (Result<Response, Error>) ->Void) {
        networkService.request(urlString: urlString) { result in
            switch result {
            case.success(let data):
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    closure(.success(response))
                } catch let error {
                    closure(.failure(error))
                }
            case.failure(let error):
                closure(.failure(error))
            }
        }
    }
}
