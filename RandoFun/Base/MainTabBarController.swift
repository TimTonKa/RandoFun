//
//  MainTabBarController.swift
//  RandoFun
//
//  Created by Tim Tseng on 2025/6/5.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let fingerVC = FingerGameViewController()
        fingerVC.tabBarItem = UITabBarItem(title: "Finger", image: UIImage(systemName: "hand.tap"), tag: 0)

        let spinnerVC = SpinnerGameViewController()
        spinnerVC.tabBarItem = UITabBarItem(title: "Spinner", image: UIImage(systemName: "arrow.2.circlepath.circle"), tag: 1)

        let coinVC = CoinFlipGameViewController()
        coinVC.tabBarItem = UITabBarItem(title: "Coin", image: UIImage(systemName: "bitcoinsign.circle"), tag: 2)

        viewControllers = [fingerVC, spinnerVC, coinVC]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
