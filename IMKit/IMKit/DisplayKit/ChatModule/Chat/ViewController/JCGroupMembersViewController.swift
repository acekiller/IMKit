//
//  JCGroupMembersViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/5/10.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

class JCGroupMembersViewController: IMBaseViewController {

    var group: JMSGGroup!

    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }

    fileprivate lazy var searchController: JCSearchController = JCSearchController(searchResultsController: nil)
    fileprivate lazy var searchView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
    private var collectionView: UICollectionView!

    fileprivate var count = 0
    fileprivate var sectionCount = 0
    fileprivate lazy var users: [JMSGUser] = []

    fileprivate lazy var filteredUsersArray: [JMSGUser] = []

//    let disposeBag = DisposeBag()

    private func _init() {
        self.title = "群成员"
        view.backgroundColor = .white
        definesPresentationContext = true

        users = group.memberArray()
        filteredUsersArray = users
        count = filteredUsersArray.count

        searchView.backgroundColor = UIColor(netHex: 0xe8edf3)
//        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchView.addSubview(searchController.searchBar)

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 1
        flowLayout.itemSize = CGSize.init(width: view.frame.width, height: 60)
//        flowLayout.headerReferenceSize = CGSize(width: view.width, height: 45)
        collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 88), collectionViewLayout: flowLayout)
        collectionView.bounces = true
//        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "kHeaderView")

        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WKGroupMemberCell.self, forCellWithReuseIdentifier: "WKGroupMemberCell")

        view.addSubview(collectionView)
        // TODO: FXJ 搜索逻辑处理
//        _ = searchController.searchBar.rx.cancelButtonClicked.subscribe(onNext: { (_) in
//            self.filter("")
//        })
//            .disposed(by: disposeBag)

    }

    fileprivate func filter(_ searchString: String) {
        if searchString.isEmpty || searchString == "" {
            filteredUsersArray = users
            collectionView.reloadData()
            return
        }

        filteredUsersArray = _JCFilterUsers(users: users, string: searchString)
        collectionView.reloadData()
    }

}

extension JCGroupMembersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsersArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.frame.size.width / 5), height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "WKGroupMemberCell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? WKGroupMemberCell else {
            return
        }
        cell.backgroundColor = UIColor.init(red: 250, green: 250, blue: 250)
        cell.bindDate(user: filteredUsersArray[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "kHeaderView", for: indexPath)
        if kind == UICollectionView.elementKindSectionHeader {
            header.backgroundColor = UIColor(netHex: 0xe8edf3)
            header.addSubview(searchView)
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let user = filteredUsersArray[indexPath.row]
//        let vc = JCUserInfoViewController()
//        vc.user = user
//        navigationController?.pushViewController(vc, animated: true)
//        searchController.isActive = false
//        filter("")
    }
}

// extension JCGroupMembersViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filter(searchText)
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        filter("")
//    }
// }
