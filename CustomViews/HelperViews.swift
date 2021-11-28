//
//  HelperViews.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 28/11/21.
//

import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

class GlobalUITask {
    static let spinnerView = SpinnerViewController()
    
    static func showSpinner(viewController: UIViewController) {
        viewController.navigationController?.navigationBar.topItem?.leftBarButtonItem?.isEnabled = false
        viewController.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
        viewController.navigationController?.navigationBar.topItem?.backBarButtonItem?.isEnabled = false
        spinnerView.view.frame = viewController.view.frame
        viewController.view.addSubview(spinnerView.view)
    }
    
    static func removeSpinner(viewController: UIViewController) {
        viewController.navigationController?.navigationBar.topItem?.leftBarButtonItem?.isEnabled = true
        viewController.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
        viewController.navigationController?.navigationBar.topItem?.backBarButtonItem?.isEnabled = true
        spinnerView.view.removeFromSuperview()
    }
}
