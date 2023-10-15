//
//  ViewController.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 11.10.2023.
//
import UIKit
import CoreLocation
import RxCocoa
import RxSwift

class MainScreenViewController: UIViewController {
    
    let viewModel = ViewModel()
    let disposeBag = DisposeBag()
    //MARK: - Property
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var city:String = ""
    let networkManager = NetworkManager()
    let networkDataFetcher = NetworkDataFetcher()
    var response: Response?
    var horizontalCollectionView: UICollectionView!
    var weeklyForecastTableView = UITableView()
    var nameCityLabel = UILabel()
    var tempCurrentLabel = UILabel()
    var weatherLabel = UILabel()
    
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2240744233, green: 0.4819361567, blue: 1, alpha: 1)
        startLocationManager()
        setupViews()
    }
    
    //MARK: - Func
    func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func updeteWeatherInfo(_ city: String) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=27d247ae696845fd99092609231210&q=\(city)&days=10"
        networkDataFetcher.fetchJson(urlString: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.response = data
                    self.horizontalCollectionView.reloadData()
                    self.weeklyForecastTableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch data: \(error.localizedDescription)")
                break
            }
        }
    }
    
    func update() {
        viewModel.city = city
        viewModel.fetchData(city: city)
        
        viewModel.nameCity
            .bind(to: nameCityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.localTemp
            .bind(to: tempCurrentLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.localWeather
            .bind(to: weatherLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func setupViews() {
        
        view.addSubview(nameCityLabel)
        nameCityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameCityLabel.textAlignment = .center
        nameCityLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameCityLabel.textColor = .black
        
        view.addSubview(tempCurrentLabel)
        tempCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tempCurrentLabel.textAlignment = .center
        tempCurrentLabel.font = UIFont.boldSystemFont(ofSize: 80)
        tempCurrentLabel.textColor = .black
        
        view.addSubview(weatherLabel)
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont.boldSystemFont(ofSize: 25)
        weatherLabel.textColor = .black
        
        horizontalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: setupHorizontelCollectionViewFlowLayout())
        view.addSubview(horizontalCollectionView)
        horizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.delegate = self
        horizontalCollectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        horizontalCollectionView.layer.cornerRadius = 15
        horizontalCollectionView.showsHorizontalScrollIndicator = false
        horizontalCollectionView.backgroundColor = #colorLiteral(red: 0.1722478867, green: 0.3678346872, blue: 0.7901673913, alpha: 1)
        
        view.addSubview(weeklyForecastTableView)
        weeklyForecastTableView.translatesAutoresizingMaskIntoConstraints = false
        
        weeklyForecastTableView.dataSource = self
        weeklyForecastTableView.delegate = self
        weeklyForecastTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        weeklyForecastTableView.layer.cornerRadius = 15
        weeklyForecastTableView.showsVerticalScrollIndicator = false
        weeklyForecastTableView.backgroundColor = #colorLiteral(red: 0.1722478867, green: 0.3678346872, blue: 0.7901673913, alpha: 1)
        
        
        NSLayoutConstraint.activate([
            nameCityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nameCityLabel.heightAnchor.constraint(equalToConstant: 100),
            nameCityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tempCurrentLabel.topAnchor.constraint(equalTo: nameCityLabel.bottomAnchor),
            tempCurrentLabel.heightAnchor.constraint(equalToConstant: view.bounds.height / 7),
            tempCurrentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: tempCurrentLabel.bottomAnchor),
            weatherLabel.heightAnchor.constraint(equalToConstant: 70),
            weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            horizontalCollectionView.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 20),
            horizontalCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            horizontalCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            horizontalCollectionView.heightAnchor.constraint(equalToConstant: 70),
            
            weeklyForecastTableView.topAnchor.constraint(equalTo: horizontalCollectionView.bottomAnchor, constant: 15),
            weeklyForecastTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            weeklyForecastTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            weeklyForecastTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)])
    }
    
    private func setupHorizontelCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 50, height: 50)
        
        return layout
    }
}

//MARK: - extension CLLocationManagerDelegate
extension MainScreenViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            geocoder.reverseGeocodeLocation(lastLocation) {[ weak self ] placemark, error in
                guard let self else { return }
                if let placemark = placemark?.first {
                    if let city = placemark.locality {
                        DispatchQueue.main.async {
                            self.city = city
                            self.updeteWeatherInfo(self.city)
                            self.update()
                        }
                    }
                }
                if error != nil {
                    print("ошибка в получении данных")
                    return
                }
            }
            
        }
    }
}
//MARK: - extension UICollectionViewDataSource, UICollectionViewDelegate
extension MainScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        response?.forecast.forecastday.first?.hour?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else { return UICollectionViewCell() }
        cell.index = indexPath.item
        cell.city = city
        cell.reloadData()
        return cell
    }
}
//MARK: - extension UITableViewDataSource, UITableViewDelegate
extension MainScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        response?.forecast.forecastday.first?.date?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else { return  UITableViewCell() }
        cell.index = indexPath.row
        cell.city = city
        cell.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: - Action
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

