//
//  CustomTableViewCell.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 13.10.2023.
//

import UIKit
import RxCocoa
import RxSwift

class CustomTableViewCell: UITableViewCell {
    
    var dayNameLabel = UILabel()
    var iconImageView = UIImageView()
    var maxTLabel = UILabel()
    var stackView = UIStackView()
    let disposeBag = DisposeBag()
    let viewModel = ViewModelCustomTableViewCell()
    var index: Int = 0
    var city: String = ""
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(dayNameLabel)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(maxTLabel)
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        backgroundColor = #colorLiteral(red: 0.1674273908, green: 0.3572465479, blue: 0.7674372792, alpha: 1)
        dayNameLabel.textAlignment = .center
        dayNameLabel.textColor = .black
        dayNameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        maxTLabel.textColor = .black
        maxTLabel.font = UIFont.boldSystemFont(ofSize: 21)
        maxTLabel.textAlignment = .center

        iconImageView.contentMode = .scaleAspectFit
 
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    func reloadData() {
        viewModel.fetchData(index: index, city: city)
        
        viewModel.dayName.bind(to: dayNameLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.maxTemp.bind(to: maxTLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.icon.bind(to: iconImageView.rx.image).disposed(by: disposeBag)
    }
}
