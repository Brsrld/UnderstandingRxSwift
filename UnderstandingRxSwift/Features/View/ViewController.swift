//
//  ViewController.swift
//  UnderstandingRxSwift
//
//  Created by Baris Saraldi on 20.06.2021.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let service = Service()
    private let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.getRocket().share().bind(to:tableView.rx.items(cellIdentifier: "branchCell", cellType: BranchTableViewCell.self)) {
            index,rocket,cell in
            cell.branchNameLabel.text = rocket.mission_name
        }.disposed(by: disposedBag)
    }
    
    struct RocketModels: Codable {
        let mission_name: String?
    }
    
    class Service {
        private let networkService = NetworkService()
        
        func getRocket() -> Observable<[RocketModels]>  {
            return networkService.execute(url: URL(string: "https://api.spacexdata.com/v2/launches")!)
        }
    }
    
    class NetworkService {
        func execute <T:Decodable>(url:URL) -> Observable<T> {
            return Observable.create { observer -> Disposable in
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        return
                    }
                    guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                        return
                    }
                    observer.onNext(decoded)
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            }
        }
    }
}
