//
//  ViewModelCustomCollectionCell.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 14.10.2023.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModelCustomCollectionCell {
    
    private let disposeBag = DisposeBag()
    let networkDataFetcher = NetworkDataFetcher()
    
    private(set) var timeText = PublishSubject<String>()
    private(set) var maxTemp = PublishSubject<String>()
    
    
    func fetchData(index: Int, city: String) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=27d247ae696845fd99092609231210&q=\(city)&days=10"
        networkDataFetcher.fetchJson(urlString: urlString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.parseData(data: data.forecast, index: index)
            case .failure(let error):
                print("Failed to fetch data: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func parseData(data: Forecast, index: Int) {
        DispatchQueue.main.async {
            guard
                let dayString = data.forecastday.first?.hour?[index].time,
                let tempDouble = data.forecastday.first?.hour?[index].temp
            else { return }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            if let date = dateFormatter.date(from: dayString) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH"
                let timeString = timeFormatter.string(from: date)
                self.timeText.onNext(timeString)
            }

            let tempString = String(Int(tempDouble))
            self.maxTemp.onNext(tempString + "°")
        }
    }
}
