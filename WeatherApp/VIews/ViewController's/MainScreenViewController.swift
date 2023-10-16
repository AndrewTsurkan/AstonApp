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
    
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    //MARK: - Property
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var city:String = ""
    private let networkManager = NetworkManager()
    private let networkDataFetcher = NetworkDataFetcher()
    private var response: Response?
    private let searchController = UISearchController(searchResultsController: nil)
    private var horizontalCollectionView: UICollectionView!
    private var weeklyForecastTableView = UITableView()
    private var nameCityLabel = UILabel()
    private var tempCurrentLabel = UILabel()
    private var weatherLabel = UILabel()
    private var timer: Timer? = nil
    var mainCity = ""
    
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSuperView()
        startLocationManager()
        setupViews()
        setupSearchBar()
    }
    
    //MARK: - Func
    
    private func setupSuperView() {
        view.backgroundColor = #colorLiteral(red: 0.2240744233, green: 0.4819361567, blue: 1, alpha: 1)
        title = "Weather"
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.standardAppearance = appearance
    }
    
    private func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.pausesLocationUpdatesAutomatically = true
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    private func update() {
        viewModel.currentResponse.subscribe(onNext: { [weak self] response in
            self?.response = response
            DispatchQueue.main.async {
                self?.horizontalCollectionView.reloadData()
                self?.weeklyForecastTableView.reloadData()
            }
        }, onError: { error in
            print("Failed to fetch data: \(error.localizedDescription)")
        }).disposed(by: disposeBag)
        
        viewModel.updeteWeatherInfo(city)
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
    
    private func setupViews() {
        
        view.addSubview(nameCityLabel)
        nameCityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameCityLabel.textAlignment = .center
        nameCityLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameCityLabel.textColor = .black
        nameCityLabel.numberOfLines = 0
        
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
            nameCityLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            nameCityLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            
            tempCurrentLabel.topAnchor.constraint(equalTo: nameCityLabel.bottomAnchor),
            tempCurrentLabel.heightAnchor.constraint(equalToConstant: view.bounds.height / 8),
            tempCurrentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: tempCurrentLabel.bottomAnchor),
            weatherLabel.heightAnchor.constraint(equalToConstant: 50),
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
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation = false
    }
}

//MARK: - extension CLLocationManagerDelegate
extension MainScreenViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            geocoder.reverseGeocodeLocation(lastLocation) { [weak self] placemark, error in
                guard let self = self else { return }
                if let placemark = placemark?.first, let city = placemark.locality {
                    DispatchQueue.main.async {
                        let replacedStr = city.replacingOccurrences(of: " ", with: "%").replacingOccurrences(of: "-", with: "%")
                        self.city = replacedStr
                        self.viewModel.updeteWeatherInfo(city)
                        self.mainCity = replacedStr
                        self.update()
                    }
                }
                if error != nil {
                    print("Error getting location data")
                    return
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            DispatchQueue.main.async {
                let defaultCity = "Moscow"
                self.city = defaultCity
                self.viewModel.updeteWeatherInfo(defaultCity)
                self.mainCity = defaultCity
                self.update()
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

extension MainScreenViewController: UISearchBarDelegate {
    func searchBar(_ searchBAr: UISearchBar, textDidChange searchText: String){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            if searchText.isEmpty {
                return
            }
            let replacedStr = searchText.replacingOccurrences(of: " ", with: "%").replacingOccurrences(of: "-", with: "%")
            DispatchQueue.main.async {
                self.city = replacedStr
                self.update()
                self.weeklyForecastTableView.reloadData()
                self.horizontalCollectionView.reloadData()
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.city = mainCity
        self.update()
        self.weeklyForecastTableView.reloadData()
        self.horizontalCollectionView.reloadData()
    }
}

