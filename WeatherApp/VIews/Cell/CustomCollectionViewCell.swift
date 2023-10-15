//
//  CustomCollectionViewCell.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 12.10.2023.
//

import UIKit
import RxSwift
import RxCocoa

class CustomCollectionViewCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    var index: Int = 0
    var timeLabel = UILabel()
    var temperatureLabel = UILabel()
    var viewModel = ViewModelCustomCollectionCell()
    let disposeBag = DisposeBag()
    var city: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layer.cornerRadius = 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(temperatureLabel)
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo:  topAnchor),
            timeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            timeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 25),
            
            
            temperatureLabel.topAnchor.constraint(equalTo:  timeLabel.bottomAnchor),
            temperatureLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            temperatureLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            temperatureLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
        
        timeLabel.textAlignment = .center
        timeLabel.textColor = .black
        timeLabel.layer.cornerRadius = 10
        timeLabel.layer.masksToBounds = true
        
        temperatureLabel.textAlignment = .center
        temperatureLabel.textColor = .black
        temperatureLabel.layer.cornerRadius = 10
        temperatureLabel.font = UIFont.boldSystemFont(ofSize: 20)
        temperatureLabel.layer.masksToBounds = true

    }
    
    func reloadData() {
        viewModel.fetchData(index: index, city: city)
        
        viewModel.maxTemp
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.timeText
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
