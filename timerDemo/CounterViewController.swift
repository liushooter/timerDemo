//
//  CounterViewController
//  timerDemo
//
//  Created by shooter on 10/3/14.
//  Copyright (c) 2014 shooter. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        setupTimeLabel()
        setuptimeButtons()
        setupActionButtons()

        remainingSeconds = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        timeLabel!.frame = CGRectMake(10, 40, self.view.bounds.size.width-20, 120)

        let gap = ( self.view.bounds.size.width - 10*2 - (CGFloat(timeButtons!.count) * 64) ) / CGFloat(timeButtons!.count - 1)

        for (index, button) in enumerate(timeButtons!) {
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)

            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height-120, 64, 44)
        }

        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height - 60, self.view.bounds.size.width-20-120, 44)

        clearButton!.frame = CGRectMake(10+self.view.bounds.size.width-20-100+20, self.view.bounds.size.height-60, 80, 44)
    }

    ///UI Element
    var timeLabel: UILabel? //显示剩余时间
    var timeButtons: [UIButton]? //设置时间的按钮数组
    var startStopButton: UIButton? //启动/停止按钮
    var clearButton: UIButton? //复位按钮
    let timeButtonInfos = [("1分", 60), ("3分", 180), ("5分", 300), ("秒", 1)]


    //启动或停止倒计时
    //使用Swift的方式来解决状态跟UI的同步问题：使用属性的willSet或didSet方法
    var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
                timer = nil
            }

            setSettingButtonsEnabled(!newValue)
        }
    }

    var timer: NSTimer? // 设置定时器

    //使用Swift的方式来解决状态跟UI的同步问题：使用属性的willSet或didSet方法
    var remainingSeconds: Int = 0 {

        willSet(newSeconds) {
            let mins = newSeconds / 60
            let seconds =  newSeconds % 60

            timeLabel!.text = NSString(format: "%02d:%02d", mins, seconds)

            if newSeconds <= 0 {
                isCounting = false
                startStopButton!.alpha = 0.3
                startStopButton!.enabled = false
            } else{
                startStopButton!.alpha = 1.0
                startStopButton!.enabled = true
            }
        }
    }

    //UI Controls

    func setupTimeLabel() {
        timeLabel = UILabel()
        timeLabel!.textColor = UIColor.whiteColor()
        timeLabel!.font = UIFont(name: "Helvetica", size: 80)
        timeLabel!.backgroundColor = UIColor.blackColor()
        timeLabel!.textAlignment = NSTextAlignment.Center

        self.view.addSubview(timeLabel!)
    }

    func setuptimeButtons() {
        var buttons: [UIButton] = []

        for (index, (title, _)) in enumerate(timeButtonInfos) {

            let button: UIButton = UIButton()
            button.tag = index //保存按钮的index
            button.setTitle("\(title)", forState: UIControlState.Normal)

            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)

            button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)

            buttons += [button]
            self.view.addSubview(button)

        }

        timeButtons = buttons
    }

    func setupActionButtons() {
        //create start/stop button

        startStopButton = UIButton()

        startStopButton!.setTitle("启动/停止", forState: UIControlState.Normal)

        startStopButton!.backgroundColor = UIColor.redColor()

        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        // 为button绑定TouchUpInside事件
        startStopButton!.addTarget(self, action: "startStopButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(startStopButton!)

        /////////////////////clearButton/////////////////////

        clearButton = UIButton()

        clearButton!.setTitle("复位", forState: UIControlState.Normal)

        clearButton!.backgroundColor = UIColor.redColor()

        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)

        clearButton!.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(clearButton!)

    }

    ///Actions & Callbacks
    func startStopButtonTapped(sender: UIButton) {
        isCounting = !isCounting //切换了isCounting的状态

        if isCounting {
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }

    func clearButtonTapped(sender: UIButton) {
        remainingSeconds = 0  //复位按钮将时间置0
    }

    //累加时间
    func timeButtonTapped(sender: UIButton) {
        let (_, seconds) = timeButtonInfos[sender.tag]
        remainingSeconds += seconds
    }

    func updateTimer(timer: NSTimer) {
        remainingSeconds -= 1

        // 弹出警告窗口,提示倒计时完成
        if remainingSeconds <= 0 {
            let alert = UIAlertView()

            alert.title = "计时完成"
            alert.message = ""
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }

    ///

    func setSettingButtonsEnabled(enabled: Bool) {
        for button in timeButtons! {
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }

        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
    }

    //注册系统通知
    func createAndFireLocalNotificationAfterSeconds(seconds: Int) {

        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()

        let timeIntervalSinceNow = Double(seconds)

        notification.fireDate = NSDate(timeIntervalSinceNow:timeIntervalSinceNow);

        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.alertBody = "计时完成！"

        UIApplication.sharedApplication().scheduleLocalNotification(notification)

    }

}

