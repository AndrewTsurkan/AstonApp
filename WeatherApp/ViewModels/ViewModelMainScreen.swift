//
//  iViewModel.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 12.10.2023.
//

import Foundation
import RxCocoa
import RxSwift


class ViewModel {
    private let disposeBag = DisposeBag()
    let networkDataFetcher = NetworkDataFetcher()
    
    private(set) var nameCity = PublishSubject<String>()
    private(set) var localTemp = PublishSubject<String>()
    private(set) var localWeather = PublishSubject<String>()
    var city: String = ""
    
    
    func fetchData(city: String) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=27d247ae696845fd99092609231210&q=\(city)&days=10"
        networkDataFetcher.fetchJson(urlString: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.nameCity.onNext(data.location.name)
                    guard let double = data.current.temp else { return }
                    let localTempStrind = String(Int(double))
                    self.localTemp.onNext(localTempStrind + "°")
                    if let conditionText = data.current.condition.text {
                        self.localWeather.onNext(conditionText)
                    }                }
            case .failure(let error):
                print("Failed to fetch data: \(error.localizedDescription)")
                break
            }
        }
    }
}
