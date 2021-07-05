//
//  MovieDetailViewController.swift
//  The Movie Database
//
//  Created by Diego Henrique on 01/07/21.
//

import UIKit

class MovieDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var movie: Movie?
    @IBOutlet weak var movieDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieDetailTableView.dataSource = self
        movieDetailTableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "moviedetail", for: indexPath) as! MovieDetailTableViewCell
            
            guard let movie = self.movie else { return cell }
            cell.titleLabel.text = movie.title
            cell.ratingLabel.text = movie.rating == 0 ? "TBD" : String(movie.rating)
            var genres: String = ""
            guard let genresArray = movie.genres else { return cell }
            for index in 0...genresArray.count-1 {
                if (index != genresArray.count-1) {
                    genres = "\(genres)" + "\(genresArray[index]), "
                }
                else {
                    genres = "\(genres)" + "\(genresArray[index])"
                }
            }
            cell.genresLabel.text = genres
            guard let poster = movie.poster else { return cell }
            cell.posterImage.image = poster
            cell.posterImage.layer.cornerRadius = 10
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "moviedetailoverview", for: indexPath) as! MovieDetailOverviewTableViewCell
            
            guard let movie = self.movie else { return cell }
            cell.descriptionLabel.text = movie.description
            return cell
        }
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
