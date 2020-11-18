//
//  RateView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/18.
//

import UIKit

class RateView: UIView {
    
    private let rates: [Float] = [0.5, 1, 1.5, 2]
    private let tableView: UITableView
    private var current: Float?
    private let onConfirmed: (Float) -> ()
    private let onRemoved: () -> ()
    private let reuseId = "UITableViewCell"
    
    
    init(frame: CGRect,
         current: Float?,
         onConfirmed: @escaping (Float) -> (),
         onRemoved: @escaping () -> ()) {
        
        self.current = current
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        defer {
            tableView.delegate = self
            tableView.dataSource = self
            addSubview(tableView)
        }
        self.onConfirmed = onConfirmed
        self.onRemoved = onRemoved
        super.init(frame: frame)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let loc = touch.location(in: self)
        if !tableView.frame.contains(loc) {
            dismissAnimated()
        }
    }
    
    
    private func showAnimated() {
        tableView.frame = CGRect(x: frame.width, y: 0, width: 150, height: frame.height)
        let insetY = (tableView.frame.height - CGFloat(rates.count) * tableView.rowHeight) * 0.5
        if insetY > 0 {
            tableView.contentInset.top = insetY
        }
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x = self.frame.width - self.tableView.frame.width
        } completion: { (_) in
        }
    }
    
    private func dismissAnimated(rate: Float? = nil) {
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x = self.frame.width
        } completion: { (_) in
            if let rate = rate {
                self.onConfirmed(rate)
            }
            self.onRemoved()
            self.removeFromSuperview()
        }
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            showAnimated()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
//MARK: UITableViewDelegate, UITableViewDataSource
extension RateView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) {
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseId)
        cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        cell.textLabel?.frame = cell.contentView.bounds
        cell.backgroundColor = .clear
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        cell.textLabel?.text = "\(rate)X"
        cell.textLabel?.textColor = rate == current ? .orange : .white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        if rate == current {
            return
        }
        current = rate
        tableView.reloadData()
        dismissAnimated(rate: rate)
    }
}


