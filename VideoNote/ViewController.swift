//
//  ViewController.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import UIKit
import AVKit
import AudioToolbox


//https://juejin.im/post/6844903796359823373#comment

class ViewController: AppViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.isMuted = !switcher.isOn
        return playerView
    }()
    var playingRow: Int?
    lazy var viewModel = ListPageViewModel()
    
    let switcher = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        viewModel.detectVideos()
    }
    
    
    func initUI() {
        navigationItem.title = "视频列表"
        viewModel.onLoadData = { [weak self] in
            self?.tableView.reloadData()
        }
        tableView.tableFooterView = UIView()
        
        switcher.addTarget(self,
                           action: #selector(switcherValueDidChange(_:)),
                           for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switcher)
    }
    
    
    @objc func switcherValueDidChange(_ switcher: UISwitch) {
        AudioServicesPlaySystemSound(1519)
        playerView.isMuted = !switcher.isOn
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let videoWidth = tableView.frame.width - 20
        let videoHeight = videoWidth * 9 / 16
        tableView.rowHeight = videoHeight + 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}


//MARK: UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return VideoItemCell.reuseForTableView(tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! VideoItemCell
        cell.video = viewModel.videos[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if playingRow == nil, indexPath.row == 0 {
            playingRow = 0
            playTheRow()
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            playTheRow()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playerView.pause()
        playerView.saveProgress()
        playerView.shouldRecordPlayed = false
        let detailController = DetailController()
        detailController.video = viewModel.videos[indexPath.row]
        detailController.didDeinit = { [weak self] in
            guard let ws = self else {
                return
            }
            ws.playerView.seekAndPlay()
            ws.playerView.shouldRecordPlayed = true
        }
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playTheRow()
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let playingRow = playingRow else {
            return
        }
        var shouldSwitch = false
        let playingIndexPath = IndexPath(row: playingRow, section: 0)
        if let cell = tableView.cellForRow(at: playingIndexPath) as? VideoItemCell {
            let playerFrame = cell.playerFrameRelatedToView(view)
            let limitedValue = playerFrame.height / 3
            if playerFrame.maxY - tableView.frame.origin.y < limitedValue {
                if playingRow < viewModel.videos.count - 1 {
                    self.playingRow! += 1
                    shouldSwitch = true
                }
            } else if tableView.frame.maxY - playerFrame.origin.y < limitedValue {
                let cells = tableView.visibleCells.sorted {
                    $0.frame.origin.x < $1.frame.origin.x
                } as! [VideoItemCell]
                if let targetCell = cells.first(where: { (cell) -> Bool in
                    cell.playerFrameRelatedToView(view).origin.y - tableView.frame.origin.y > limitedValue
                }) {
                    self.playingRow = tableView.indexPath(for: targetCell)!.row
                    shouldSwitch = true
                }
            }
        } else {
            shouldSwitch = true
        }
        
        
        if shouldSwitch {
            playerView.pause()
            playerView.removeFromSuperview()
        }
    }
    
    
    func playTheRow() {
        guard let playingRow = playingRow else {
            return
        }
        let indexPath = IndexPath(row: playingRow, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? VideoItemCell else {
            return
        }
        playerView.playUrl(viewModel.videos[playingRow].url)
        cell.insertPlayerView(playerView)
    }
}


