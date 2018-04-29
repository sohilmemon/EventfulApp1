//
//  HomeFeedCell.swift
//  Eventful
//
//  Created by Devanshu Saini on 22/09/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class HomeFeedCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    var homeFeedController: HomeFeedController?
    let emptyView = UIView()
    var scrollTimer: Timer?
    var x : Int = 0
    private let cellId = "cellId"
    var featuredEvents: [Event]?{
        didSet {
            homeFeedCollectionView.reloadData()

        }
    }
    
    var titles: String? {
        didSet {
            guard let titles = titles else {
            return
            }
//            let attributedText = NSMutableAttributedString(string: titles, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 100)])
            sectionNameLabel.text = titles
//            sectionNameLabel.attributedText = attributedText
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"HelveticaNeue-CondensedBlack", size: 36.0)
        return sectionNameLabel
    }()
    
    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "Sorry We Currently Have No Events, \n In This Category Near You"
        emptyLabel.font = UIFont(name: "Avenir", size: 14)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        return emptyLabel
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let homeFeedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(homeFeedCollectionView)
        addSubview(sectionNameLabel)
        sectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeFeedCollectionView.anchor(top: sectionNameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeFeedCollectionView.delegate = self
        homeFeedCollectionView.dataSource = self
        homeFeedCollectionView.showsHorizontalScrollIndicator = false
        homeFeedCollectionView.register(HomeFeedEventCell.self, forCellWithReuseIdentifier: cellId)
        setTimer()
    }
    
  

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentEventCount = featuredEvents?.count else{
            return 0
        }
        if currentEventCount == 0 {
            print("no events")
            setupEmptyDataSet()
        }else{
            emptyView.removeFromSuperview()
        }
        return currentEventCount
    }
    
    @objc func setupEmptyDataSet(){
        self.addSubview(emptyView)
        emptyView.backgroundColor = .clear
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        emptyView.addSubview(iconImageView)
        iconImageView.image = UIImage(named: "icons8-face-100")
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalTo(emptyView)
        }
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconImageView.snp.bottom).offset(30)
            make.left.right.equalTo(emptyView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: frame.width - 40, height: frame.height - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventDetails = EventDetailViewController()
        eventDetails.currentEvent = featuredEvents?[indexPath.item]
    homeFeedController?.navigationController?.pushViewController(eventDetails, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeFeedEventCell
        cell.event = featuredEvents?[indexPath.item]
        return cell
    }
    
    @objc func startTimer(theTimer: Timer){
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseOut, animations: {
            if let currentIndexPath = self.homeFeedCollectionView.indexPathsForVisibleItems.last{
                
                //Check visible cell is last cell of top collection view then set first index as visible
                print(self.homeFeedCollectionView.numberOfItems(inSection: 0))
                print(currentIndexPath)
                print(currentIndexPath.item)
                if self.x == self.homeFeedCollectionView.numberOfItems(inSection: 0)-1{
                    self.x = 0
                    let nextIndexPath = NSIndexPath(item: self.x, section: 0)
                    //top collection view scroller in first item
                    self.homeFeedCollectionView.scrollToItem(at: nextIndexPath as IndexPath, at: .centeredHorizontally, animated: false)
                }else{
                    //create next index path from current index path of the top collection view
                    print(currentIndexPath.item)
                    self.x = self.x + 1
                    let nextIndexPath = NSIndexPath(item: self.x, section: 0)
                    //top collection view scroller to next item
                    self.homeFeedCollectionView.scrollToItem(at: nextIndexPath as IndexPath, at: .centeredHorizontally, animated: false)
                }
            }
        }, completion: nil)
    }
    
    @objc func setTimer(){
        scrollTimer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(self.startTimer(theTimer:)), userInfo: nil, repeats: true)
    }
    
    func removeTimer() {
        if self.scrollTimer != nil {
            self.scrollTimer?.invalidate()
        }
        self.scrollTimer = nil
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.homeFeedCollectionView.scrollToNearestVisibleCollectionViewCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.removeTimer()
            self.homeFeedCollectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }
}

