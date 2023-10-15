//
//  ImageDownloader.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 16.10.2023.
//

import UIKit

class ImageDownloader {

    func requestImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                guard let image = UIImage(data: data) else {
                    let error = NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Could not generate image from data"])
                    completion(.failure(error))
                    return
                }
                completion(.success(image))
            }
        }.resume()
    }
}
