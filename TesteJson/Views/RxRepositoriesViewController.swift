//
//  RxRepositoriesViewController.swift
//  TesteJson
//
//  Created by alessandro on 26/09/19.
//  Copyright © 2019 Alessandro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class RxRepositoriesViewController: UIViewController  {
    
    //MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: UIView!
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let cellIdentifier = "cell"
   
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView(with: false)
        tableView.register(UINib(nibName: "RepositoriesTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        loadRepositories()
        configureKeyboardDismissesOnScroll()
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
   }
    
}

extension RxRepositoriesViewController{
    
    //MARK - TableView Functions
    
    func updateTableView(with status:Bool){
        if status{
            label.text = ""
            tableView.backgroundView = nil
            tableView.separatorColor = .gray
        }else{
            label.text = "Selecione repositórios no campo de busca!"
            tableView.backgroundView = label
            tableView.separatorColor = .white
        }
    }
    
    func configureKeyboardDismissesOnScroll() {
        let searchBar = self.searchBar
        
        tableView.rx.contentOffset
            .asDriver()
            .drive(onNext: { _ in
                if searchBar?.isFirstResponder ?? false {
                    _ = searchBar?.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func loadRepositories() {
        
        searchBar.rx.text
            .orEmpty
            .filter { query in
                return query.count > 2
            }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map{ query -> URL in
                let queryString = "https://api.github.com/search/repositories?q=\(query)"
                guard let url = URL(string: queryString) else{
                    fatalError("URL not valid")
                }
                return url
                
            }.flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
                let request = URLRequest(url: url)
                let result  = URLSession.shared.rx.response(request: request)
                return result
            }.map { (response, data) -> [Item] in
                var items:[Item] = []
                if response.statusCode == 200{
                    do{
                        items =  try JSONDecoder().decode(GitHubEntity.self, from: data).items
                    }catch{
                        items =  []
                        
                    }
                }
                if items.count == 0{
                    DispatchQueue.main.async {
                        self.updateTableView(with: false)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.updateTableView(with: true)
                    }
                }
                return items
                
            }.bind(to: tableView.rx.items) {(tableView, row, repository) in
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: IndexPath(row: row, section: 0)) as! RepositoriesTableViewCell
                cell.lblName.text = repository.name
                cell.lblLogin.text = repository.owner.login
                cell.lblStars.text = "\(repository.stargazers_count)"
                cell.imgOwner.kf.setImage(with:  URL(string:repository.owner.avatar_url))
                cell.imgOwner.kf.indicatorType = .activity
                return cell
            }
            .disposed(by: disposeBag)
    }
}
