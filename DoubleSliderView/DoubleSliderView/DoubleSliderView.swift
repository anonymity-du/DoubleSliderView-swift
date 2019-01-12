//
//  DPDoubleSliderView.swift
//  DatePlay
//
//  Created by DU on 2018/11/19.
//  Copyright © 2018年 DU. All rights reserved.
//

import UIKit

class DoubleSliderView: UIView {

    var minNum: CGFloat = 0
    var maxNum: CGFloat = 0

    var curMinValue: CGFloat = 0
    var curMaxValue: CGFloat = 0

    var needAnimated = false
    var dragType: Int = 0 // 0 没有在按钮上 1 左边按钮 2 右边按钮 3两者中间
    
    private var minCenter: CGPoint = CGPoint.zero
    private var maxCenter: CGPoint = CGPoint.zero
    
    private var marginCenterX: CGFloat = 0
    var sliderBtnLocationChangeBlock: ((_ isLeft: Bool, _ finish: Bool)->())?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if self.height < 35 + 20 {
            self.height = 55
        }
        self.marginCenterX = 17.5
        self.createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        self.addSubview(self.minLineView)
        self.addSubview(self.midLineView)
        self.addSubview(self.maxLineView)
        self.addSubview(self.minSliderBtn)
        self.addSubview(self.maxSliderBtn)
        
        self.curMinValue = 0
        self.curMaxValue = 1
        
        self.minSliderBtn.centerY = self.height * 0.5
        self.maxSliderBtn.centerY = self.height * 0.5
        self.minSliderBtn.x = 0
        self.maxSliderBtn.right = self.width
        
        self.minLineView.centerY = self.height * 0.5
        self.midLineView.centerY = self.height * 0.5
        self.maxLineView.centerY = self.height * 0.5
        self.changeLineViewWidth()
        
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(minSliderBtnPanAction(gesture:))))
    }

    //MARK:- action
    
    @objc func minSliderBtnPanAction(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let point = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            let inMinSliderBtn = self.minSliderBtn.frame.contains(location)
            let inMaxSliderBtn = self.maxSliderBtn.frame.contains(location)
            if inMinSliderBtn && !inMaxSliderBtn {
                print("从左边开始触摸")
                self.dragType = 1
            }else if !inMinSliderBtn && inMaxSliderBtn {
                print("从右边开始触摸")
                self.dragType = 2
            }else if !inMaxSliderBtn && !inMinSliderBtn {
                print("没有触动")
                self.dragType = 0
            }else {
                let leftOffset = abs(location.x - self.minSliderBtn.centerX)
                let rightOffset = abs(location.x - self.maxSliderBtn.centerX)
                if  leftOffset > rightOffset {
                    print("挨着，往右边")
                    self.dragType = 2
                }else if leftOffset < rightOffset {
                    print("挨着，往左边")
                    self.dragType = 1
                }else {
                    print("正中间")
                    self.dragType = 3
                }
            }
            if self.dragType == 1 {
                self.minCenter = self.minSliderBtn.center
                self.bringSubviewToFront(self.minSliderBtn)
            }else if self.dragType == 2 {
                self.maxCenter = self.maxSliderBtn.center
                self.bringSubviewToFront(self.maxSliderBtn)
            }
            
        case .changed:
            if self.dragType == 3 {
                if point.x > 0 {
                    self.dragType = 2
                    self.maxCenter = self.maxSliderBtn.center
                    self.bringSubviewToFront(self.maxSliderBtn)
                    print("从中间往右")
                }else if point.x < 0 {
                    self.dragType = 1
                    print("从中间往左")
                    self.minCenter = self.minSliderBtn.center
                    self.bringSubviewToFront(self.minSliderBtn)
                }
            }
            if dragType != 0 && dragType != 3 {
                if self.dragType == 1 {
                    self.minSliderBtn.center = CGPoint.init(x: self.minCenter.x + point.x, y: self.minCenter.y)
                    if self.minSliderBtn.right > self.maxSliderBtn.right {
                        self.minSliderBtn.right = self.maxSliderBtn.right
                    }else {
                        if self.minSliderBtn.centerX < self.marginCenterX {
                            self.minSliderBtn.centerX = self.marginCenterX
                        }
                        if self.minSliderBtn.centerX > self.width - self.marginCenterX {
                            self.minSliderBtn.centerX = self.width - self.marginCenterX
                        }
                    }
                    self.changeLineViewWidth()
                    self.changeValueFromLocation()
                    if self.sliderBtnLocationChangeBlock != nil {
                        self.sliderBtnLocationChangeBlock!(true, false)
                    }
                }else {
                    self.maxSliderBtn.center = CGPoint.init(x: self.maxCenter.x + point.x, y: self.maxCenter.y)
                    if self.maxSliderBtn.x < self.minSliderBtn.x {
                        self.maxSliderBtn.x = self.minSliderBtn.x
                    }else {
                        if self.maxSliderBtn.centerX < self.marginCenterX {
                            self.maxSliderBtn.centerX = self.marginCenterX
                        }
                        if self.maxSliderBtn.centerX > self.width - self.marginCenterX {
                            self.maxSliderBtn.centerX = self.width - self.marginCenterX
                        }
                    }
                    self.changeLineViewWidth()
                    self.changeValueFromLocation()
                    if self.sliderBtnLocationChangeBlock != nil {
                        self.sliderBtnLocationChangeBlock!(false, false)
                    }
                }
            }
        case .ended:
            if self.dragType == 1 {
                self.changeValueFromLocation()
                if self.sliderBtnLocationChangeBlock != nil {
                    self.sliderBtnLocationChangeBlock!(true, true)
                }
            }else if self.dragType == 2 {
                self.changeValueFromLocation()
                if self.sliderBtnLocationChangeBlock != nil {
                    self.sliderBtnLocationChangeBlock!(false, true)
                }
            }
            self.dragType = 0
        default:
            break
        }
    }
    
    private func changeLineViewWidth() {
        self.minLineView.width = self.minSliderBtn.centerX
        self.minLineView.x = 0
        
        self.maxLineView.width = self.width - self.maxSliderBtn.centerX
        self.maxLineView.right = self.width
        
        self.midLineView.width = self.maxSliderBtn.centerX - self.minSliderBtn.centerX
        self.midLineView.x = self.minLineView.right
    }
    
    private func changeValueFromLocation() {
        let contentWidth: CGFloat = self.width - self.marginCenterX * 2
        self.curMinValue = (self.minSliderBtn.centerX - self.marginCenterX)/contentWidth
        self.curMaxValue = (self.maxSliderBtn.centerX - self.marginCenterX)/contentWidth
    }
    
    func changeLocationFromValue() {
        let contentWidth: CGFloat = self.width - self.marginCenterX * 2

        if needAnimated {
            UIView.animate(withDuration: 0.2) {
                self.minSliderBtn.centerX = self.marginCenterX + self.curMinValue * contentWidth
                self.maxSliderBtn.centerX = self.marginCenterX + self.curMaxValue * contentWidth
                self.changeLineViewWidth()
            }
        }else {
            self.minSliderBtn.centerX = self.marginCenterX + self.curMinValue * contentWidth
            self.maxSliderBtn.centerX = self.marginCenterX + self.curMaxValue * contentWidth
            self.changeLineViewWidth()
        }
        if self.curMinValue == self.curMaxValue {
            if self.curMaxValue == 0 {
                self.bringSubviewToFront(self.maxSliderBtn)
            }else {
                self.bringSubviewToFront(self.minSliderBtn)
            }
        }
    }
    
    //MARK:- setter & getter
    
    var minTintColor: UIColor? {
        didSet {
            if minTintColor != nil {
                self.minLineView.backgroundColor = minTintColor!
            }
        }
    }
    var maxTintColor: UIColor? {
        didSet {
            if maxTintColor != nil {
                self.maxLineView.backgroundColor = maxTintColor!
            }
        }
    }
    var midTintColor: UIColor? {
        didSet {
            if midTintColor != nil {
                self.midLineView.backgroundColor = midTintColor!
            }
        }
    }
    
    private lazy var minSliderBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.size = CGSize.init(width: 35, height: 35)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 17.5
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        btn.layer.shadowOpacity = Float(0.15)
        btn.layer.shadowRadius = 5
//        btn.showsTouchWhenHighlighted = true
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    private lazy var maxSliderBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.size = CGSize.init(width: 35, height: 35)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 17.5
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        btn.layer.shadowOpacity = Float(0.15)
        btn.layer.shadowRadius = 5
//        btn.showsTouchWhenHighlighted = true
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    private lazy var minLineView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 5))
        view.backgroundColor = UIColor.init(red: 162.0/255.0, green: 141.0/255.0, blue: 255.0/255.0, alpha: 0.2)
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var maxLineView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 5))
        view.backgroundColor = UIColor.init(red: 162.0/255.0, green: 141.0/255.0, blue: 255.0/255.0, alpha: 0.2)
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var midLineView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 5))
        view.backgroundColor = UIColor.init(red: 162.0/255.0, green: 141.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        view.isUserInteractionEnabled = false
        return view
    }()
}
