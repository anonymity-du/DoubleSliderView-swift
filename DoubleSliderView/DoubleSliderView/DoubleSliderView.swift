//
//  DPDoubleSliderView.swift
//  DatePlay
//
//  Created by DU on 2018/11/19.
//  Copyright © 2018年 DU. All rights reserved.
//

import UIKit

class DoubleSliderView: UIView {
    //当前最小的值
    var curMinValue: CGFloat = 0
    //当前最大的值
    var curMaxValue: CGFloat = 0
    //是否需要动画
    var needAnimation = false
    //手势起手位置类型 0 未在按钮上 not on button ; 1 在左边按钮上 on left button ; 2 在右边按钮上 on right button ; 3 两者重叠 overlap
    var dragType: Int = 0
    //间隔大小
    var minInterval: CGFloat = 0
    private var minIntervalWidth: CGFloat = 0
    
    //左侧按钮的中心位置 left btn's center
    private var minCenter: CGPoint = CGPoint.zero
    //右侧按钮的中心位置 right btn's center
    private var maxCenter: CGPoint = CGPoint.zero

    private var marginCenterX: CGFloat = 0
    
    //滑块位置改变后的回调 isLeft 是否是左边 finish手势是否结束
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
        
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(sliderBtnPanAction(gesture:))))
    }

    //MARK:- actions
    
    @objc func sliderBtnPanAction(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let point = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            
            let minSliderFrame = CGRect.init(x: self.minSliderBtn.x - 10, y: self.minSliderBtn.y - 10, width: self.minSliderBtn.width + 20, height: self.minSliderBtn.height + 20)
            let maxSliderFrame = CGRect.init(x: self.maxSliderBtn.x - 10, y: self.maxSliderBtn.y - 10, width: self.maxSliderBtn.width + 20, height: self.maxSliderBtn.height + 20)
            
            let inMinSliderBtn = minSliderFrame.contains(location)
            let inMaxSliderBtn = maxSliderFrame.contains(location)
            if inMinSliderBtn && !inMaxSliderBtn {
                print("从左边开始触摸 start drag from left")
                self.dragType = 1
            }else if !inMinSliderBtn && inMaxSliderBtn {
                print("从右边开始触摸 start drag from right")
                self.dragType = 2
            }else if !inMaxSliderBtn && !inMinSliderBtn {
                print("没有触动到按钮 not on button")
                self.dragType = 0
            }else {
                let leftOffset = abs(location.x - self.minSliderBtn.centerX)
                let rightOffset = abs(location.x - self.maxSliderBtn.centerX)
                if  leftOffset > rightOffset {
                    print("挨着，往右边 start drag from right")
                    self.dragType = 2
                }else if leftOffset < rightOffset {
                    print("挨着，往左边 start drag from left")
                    self.dragType = 1
                }else {
                    print("正中间 overlap")
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
            if self.minInterval > 0  {
                self.minIntervalWidth = (self.width - self.marginCenterX * 2) * CGFloat(self.minInterval)
            }
            
        case .changed:
            if self.dragType == 3 {
                if point.x > 0 {
                    self.dragType = 2
                    self.maxCenter = self.maxSliderBtn.center
                    self.bringSubviewToFront(self.maxSliderBtn)
                    print("从中间往右 from center to right")
                }else if point.x < 0 {
                    self.dragType = 1
                    print("从中间往左 from center to left")
                    self.minCenter = self.minSliderBtn.center
                    self.bringSubviewToFront(self.minSliderBtn)
                }
            }
            if dragType != 0 && dragType != 3 {
                if self.dragType == 1 {
                    self.minSliderBtn.center = CGPoint.init(x: self.minCenter.x + point.x, y: self.minCenter.y)
                    if self.minSliderBtn.right > self.maxSliderBtn.right - self.minIntervalWidth {
                        self.minSliderBtn.right = self.maxSliderBtn.right - minIntervalWidth
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
                    if self.maxSliderBtn.x < self.minSliderBtn.x + self.minIntervalWidth {
                        self.maxSliderBtn.x = self.minSliderBtn.x + self.minIntervalWidth
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
            //重置 reset
            self.dragType = 0
        default:
            break
        }
    }
    
    //改变值域的线宽
    private func changeLineViewWidth() {
        self.minLineView.width = self.minSliderBtn.centerX
        self.minLineView.x = 0
        
        self.maxLineView.width = self.width - self.maxSliderBtn.centerX
        self.maxLineView.right = self.width
        
        self.midLineView.width = self.maxSliderBtn.centerX - self.minSliderBtn.centerX
        self.midLineView.x = self.minLineView.right
    }
    //根据滑块位置改变当前最小和最大的值
    private func changeValueFromLocation() {
        let contentWidth: CGFloat = self.width - self.marginCenterX * 2
        self.curMinValue = (self.minSliderBtn.centerX - self.marginCenterX)/contentWidth
        self.curMaxValue = (self.maxSliderBtn.centerX - self.marginCenterX)/contentWidth
    }
    //根据当前最小和最大的值改变滑块位置
    func changeLocationFromValue() {
        let contentWidth: CGFloat = self.width - self.marginCenterX * 2

        if needAnimation {
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
