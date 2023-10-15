//
//  ViewModelCustomTableViewCell.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 14.10.2023.
//

import Foundation
import RxCocoa
import RxSwift

class ViewModelCustomTableViewCell {
    
    private let disposeBag = DisposeBag()
    let networkDataFetcher = NetworkDataFetcher()
    
    private(set) var dayName = PublishSubject<String>()
    private(set) var icon = PublishSubject<UIImage>()
    private(set) var maxTemp = PublishSubject<String>()
    let imageDownloader = ImageDownloader()
    
    func fetchData(index: Int, city: String) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=27d247ae696845fd99092609231210&q=\(city)&days=10"
        networkDataFetcher.fetchJson(urlString: urlString) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let dateStrE = self.getDayName(index: index, forecast: data.forecast)
                    self.dayName.onNext(dateStrE)
                    
                    guard let maxTempDouble = data.forecast.forecastday[index].day.maxTemp else { return }
                    self.maxTemp.onNext("\(Int(maxTempDouble))°")
                    let dataImage = data.forecast.forecastday[index].day.condition.icon
                    guard let dataImage else { return }
                    let url = "https:" + dataImage
                    DispatchQueue.global().async {
                        self.imageDownloader.requestImage(urlString: url) { [weak self] result in
                            guard let self else { return }
                            switch result {
                            case .success(let image):
                                self.icon.onNext(image)
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        
                    }
                }
            case .failure(let error):
                print("Failed to fetch data: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func getDayName(index: Int, forecast: Forecast) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let dateUnix = forecast.forecastday[index].dateEpoch
        let timestamp = TimeInterval(dateUnix!)
        let date = Date(timeIntervalSince1970: timestamp)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        let todayStr = dateFormatter.string(from: Date())
        
        guard todayStr == dateStr else {
            dateFormatter.dateFormat = "EE"
            return dateFormatter.string(from: date)
        }
        
        return "Today"
    }
}

