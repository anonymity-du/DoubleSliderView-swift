//
//  ViewController.swift
//  DoubleSliderView
//
//  Created by 杜奎 on 2019/1/12.
//  Copyright © 2019 DU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var minAge: Int = 12
    var maxAge: Int = 35
    var curMinAge: Int = 12
    var curMaxAge: Int = 35
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.ageLabel)
        self.view.addSubview(self.ageTipsLabel)
        self.view.addSubview(self.doubleSliderView)
        
        self.ageLabel.centerY = 156
        self.ageLabel.x = 52
        
        self.ageTipsLabel.centerY = self.ageLabel.centerY
        self.ageTipsLabel.x = self.ageLabel.right + 7
  
        self.doubleSliderView.x = 52
        self.doubleSliderView.y = 185 - 10
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - private func
    //根据值获取整数
    private func fetchInt(from value: CGFloat) -> CGFloat {
        var newValue: CGFloat = floor(value)
        let changeValue = value - newValue
        if changeValue >= 0.5 {
            newValue = newValue + 1
        }
        return newValue
    }

    private func sliderValueChangeAction(isLeft: Bool, finish: Bool) {
        if isLeft {
            let age = CGFloat(self.maxAge - self.minAge) * self.doubleSliderView.curMinValue
            let tmpAge = self.fetchInt(from: age)
            self.curMinAge = Int(tmpAge) + self.minAge
            self.changeAgeTipsText()
        }else {
            let age = CGFloat(self.maxAge - self.minAge) * self.doubleSliderView.curMaxValue
            let tmpAge = self.fetchInt(from: age)
            self.curMaxAge = Int(tmpAge) + self.minAge
            self.changeAgeTipsText()
        }
        if finish {
            self.changeSliderValue()
        }
    }
    //值取整后可能改变了原始的大小，所以需要重新改变滑块的位置
    private func changeSliderValue() {
        let finishMinValue = CGFloat(self.curMinAge - self.minAge)/CGFloat(self.maxAge - self.minAge)
        let finishMaxValue = CGFloat(self.curMaxAge - self.minAge)/CGFloat(self.maxAge - self.minAge)
        self.doubleSliderView.curMinValue = finishMinValue
        self.doubleSliderView.curMaxValue = finishMaxValue
        self.doubleSliderView.changeLocationFromValue()
    }
    
    private func changeAgeTipsText() {
        if self.curMinAge == self.curMaxAge {
            self.ageTipsLabel.text = "\(self.curMinAge)岁"
        }else {
            self.ageTipsLabel.text = "\(self.curMinAge)~\(self.curMaxAge)岁"
        }
        self.ageTipsLabel.sizeToFit()
        self.ageTipsLabel.centerY = self.ageLabel.centerY
        self.ageTipsLabel.x = self.ageLabel.right + 7
    }
    
    //MARK:- setter & getter

    private lazy var ageLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.text = "年龄 age"
        label.sizeToFit()
        return label
    }()
    
    private lazy var ageTipsLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.text = "\(self.minAge)~\(self.maxAge)岁"
        label.sizeToFit()
        return label
    }()
    
    private lazy var doubleSliderView: DoubleSliderView = {
        let view = DoubleSliderView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width - 52 * 2, height: 35 + 20))
        view.needAnimation = true
//        if self.maxAge > self.minAge {
//            view.minInterval = 4.0/CGFloat(self.maxAge - self.minAge)
//        }
        view.sliderBtnLocationChangeBlock = { [weak self] isLeft,finish in
            self?.sliderValueChangeAction(isLeft: isLeft, finish: finish)
        }
        return view
    }()
    
}

