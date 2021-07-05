//
//  MovieListViewController.swift
//  The Movie Database
//
//  Created by Diego Henrique on 01/07/21.
//

import UIKit

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var popularMoviesPage: Int = 1
    var nowPlayingMoviesPage: Int = 1
    var popularMoviesTotalPages: Int = 0
    var nowPlayingMoviesTotalPages: Int = 0
    
    let movieDBService = MovieDBService()
    
    var filteredPopularMovies: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.moviesTableView.isHidden = self.popularMovies.isEmpty
                self.activityIndicator.isHidden = !self.popularMovies.isEmpty
            }
        }
    }
    
    var filteredNowPlayingMovies: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.moviesTableView.isHidden = self.popularMovies.isEmpty
                self.activityIndicator.isHidden = !self.popularMovies.isEmpty
            }
        }
    }
    
    var popularMovies: [Movie] = []
    
    var nowPlayingMovies: [Movie] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        
        moviesTableView.isHidden = self.popularMovies.isEmpty && self.nowPlayingMovies.isEmpty
        activityIndicator.isHidden = !self.popularMovies.isEmpty && !self.nowPlayingMovies.isEmpty
        
        movieDBService.getTotalPages(url: "https://api.themoviedb.org/3/movie/popular?api_key=2c84bee7ec597369d0b15bc1d8b7d41e&language=en-US") { value in
            self.popularMoviesTotalPages = value
        }
        
        movieDBService.getTotalPages(url: "https://api.themoviedb.org/3/movie/now_playing?api_key=2c84bee7ec597369d0b15bc1d8b7d41e&language=en-US") { value in
            self.nowPlayingMoviesTotalPages = value
        }
        
        movieDBService.getPopularMovies(page: popularMoviesPage) { movies in
            self.popularMovies = movies
            for index in 0...self.popularMovies.count-1 {
                self.movieDBService.getMoviePoster(url: self.popularMovies[index].posterURL) { poster in
                    self.popularMovies[index].poster = poster
                    self.updateData()
                }
                self.movieDBService.getGenres(genreIDs: self.popularMovies[index].genreIDs) { genres in
                    self.popularMovies[index].genres = genres
                    self.updateData()
                }
            }
            //            DispatchQueue.main.async {
            //                self.updateSearchResults(for: self.navigationItem.searchController!)
            //                self.moviesTableView.reloadData()
            //            }
            self.popularMoviesPage+=1
        }
        
        movieDBService.getNowPlayingMovies(page: nowPlayingMoviesPage) { movies in
            self.nowPlayingMovies = movies
            for index in 0...self.nowPlayingMovies.count-1 {
                self.movieDBService.getMoviePoster(url: self.nowPlayingMovies[index].posterURL) { poster in
                    self.nowPlayingMovies[index].poster = poster
                    self.updateData()
                }
                self.movieDBService.getGenres(genreIDs: self.nowPlayingMovies[index].genreIDs) { genres in
                    self.nowPlayingMovies[index].genres = genres
                    self.updateData()
                }
            }
            //            DispatchQueue.main.async {
            //                self.updateSearchResults(for: self.navigationItem.searchController!)
            //                self.moviesTableView.reloadData()
            //            }
            self.nowPlayingMoviesPage+=1
        }
    }
    
    func updateData() {
        DispatchQueue.main.async {
            let searchText = self.navigationItem.searchController?.searchBar.text ?? ""
            self.updateData(searchText: searchText)
            self.moviesTableView.reloadData()
        }
    }
    
    func updateData(searchText: String) {
        if searchText.isEmpty {
            filteredPopularMovies = popularMovies
            filteredNowPlayingMovies = nowPlayingMovies
        }
        
        else {
            filteredNowPlayingMovies = []
            filteredPopularMovies = []
            for movie in (popularMovies + nowPlayingMovies) {
                if movie.title.lowercased().contains(searchText.lowercased()) {
                    if popularMovies.contains(movie) && !filteredPopularMovies.contains(movie) {
                        filteredPopularMovies.append(movie)
                    }
                    if nowPlayingMovies.contains(movie) && !filteredNowPlayingMovies.contains(movie) {
                        filteredNowPlayingMovies.append(movie)
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filteredPopularMovies.count+1
        }
        else {
            return filteredNowPlayingMovies.count+1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            if indexPath.row != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath) as! MovieTableViewCell
                
                let movie = filteredPopularMovies[indexPath.row-1]
                cell.titleLabel.text = movie.title
                cell.descriptionLabel.text = movie.description
                cell.rateLabel.text = movie.rating == 0 ? "TBD" : String(movie.rating)
                guard let poster = movie.poster else {return cell}
                cell.posterImage.image = poster
                cell.posterImage.layer.cornerRadius = 10
                return cell
            }
            
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
                cell.textLabel?.text = "Popular Movies"
                return cell
            }
        }
        
        else {
            if indexPath.row != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath) as! MovieTableViewCell
                
                let movie = filteredNowPlayingMovies[indexPath.row-1]
                cell.titleLabel.text = movie.title
                cell.descriptionLabel.text = movie.description
                cell.rateLabel.text = movie.rating == 0 ? "TBD" : String(movie.rating)
                guard let poster = movie.poster else {return cell}
                cell.posterImage.image = poster
                cell.posterImage.layer.cornerRadius = 10
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
                cell.textLabel?.text = "Now Playing"
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let movie = filteredPopularMovies[indexPath.row-1]
            performSegue(withIdentifier: "detail", sender: movie)
        }
        else {
            let movie = filteredNowPlayingMovies[indexPath.row-1]
            performSegue(withIdentifier: "detail", sender: movie)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Lembrem-se de colocar um booleano pra controlar as requisições
        // E lembrem-se de controlarem em que página estamos para pedirmos apenas a próxima
        if (indexPath.section == 0) {
            if (indexPath.row == filteredPopularMovies.count - 1 && popularMoviesPage <= popularMoviesTotalPages) {
                movieDBService.getPopularMovies(page: popularMoviesPage) { movies in
                    self.popularMovies = self.popularMovies + movies
                    for index in 0...self.popularMovies.count-1 {
                        self.movieDBService.getMoviePoster(url: self.popularMovies[index].posterURL) { poster in
                            self.popularMovies[index].poster = poster
                            self.updateData()
                        }
                        self.movieDBService.getGenres(genreIDs: self.popularMovies[index].genreIDs) { genres in
                            self.popularMovies[index].genres = genres
                            self.updateData()
                            
                        }
                    }
                    self.popularMoviesPage+=1
                }
            }
        }
        
        else {
            if (indexPath.row == filteredNowPlayingMovies.count - 1 && nowPlayingMoviesPage <= nowPlayingMoviesTotalPages) {
                movieDBService.getPopularMovies(page: nowPlayingMoviesPage) { movies in
                    
                    self.nowPlayingMovies = self.nowPlayingMovies + movies
                    for index in 0...self.nowPlayingMovies.count-1 {
                        self.movieDBService.getMoviePoster(url: self.nowPlayingMovies[index].posterURL) { poster in
                            self.nowPlayingMovies[index].poster = poster
                            self.updateData()
                        }
                        self.movieDBService.getGenres(genreIDs: self.nowPlayingMovies[index].genreIDs) { genres in
                            self.nowPlayingMovies[index].genres = genres
                            self.updateData()
                        }
                    }
                    self.nowPlayingMoviesPage+=1
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let movie = sender as? Movie else {
            return
        }
        
        let movieDetailViewController = segue.destination as? MovieDetailViewController
        movieDetailViewController?.movie = movie
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        self.updateData(searchText: searchText)
        self.moviesTableView.reloadData()
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

