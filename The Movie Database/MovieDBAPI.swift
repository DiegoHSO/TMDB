//
//  MovieDBAPI.swift
//  The Movie Database
//
//  Created by Diego Henrique on 01/07/21.
//

import Foundation
import UIKit

// MARK: Movie Struct
struct Movie: CustomStringConvertible {
    let id: Int
    let title: String
    let description: String
    let rating: Double
    let posterURL: String
    var poster: UIImage?
    var genreIDs: [Int]
    var genres: [String]?
}

struct Genre {
    let id: Int
    let name: String
}

// MARK: MovieDB Service
struct MovieDBService {
    
    let movieDBParser = MovieDBParser()
    let movieDBAPI = MovieDBAPI()
    
    func getPopularMovies(page: Int, completionHandler: @escaping ([Movie]) -> Void) {
        movieDBAPI.requestPopularMovies(page: page) { (moviesDictionary) in
            let movies = moviesDictionary.compactMap{ movieDBParser.parseMovieDictionary(dictionary: $0) }
            completionHandler(movies)
        }
    }
    
    func getNowPlayingMovies(page: Int, completionHandler: @escaping ([Movie]) -> Void) {
        movieDBAPI.requestNowPlayingMovies(page: page) { (moviesDictionary) in
            let movies = moviesDictionary.compactMap{ movieDBParser.parseMovieDictionary(dictionary: $0) }
            completionHandler(movies)
        }
    }
    
    
    func getMoviePoster(url: String, completionHandler: @escaping ((UIImage?) -> Void)) {
        movieDBAPI.requestMoviePoster(url: url) { (poster) in
            completionHandler(poster)
        }
    }
    
    func getGenres(genreIDs: [Int], completionHandler: @escaping (([String]) -> Void)) {
        movieDBAPI.requestGenres { (genreDictionary) in
            let allGenres = genreDictionary.compactMap{ movieDBParser.parseGenreDictionary(dictionary: $0) }
            
            var movieGenres: [String] = []
            for genre in allGenres {
                for genreID in genreIDs {
                    if genre.id == genreID {
                        movieGenres.append(genre.name)
                    }
                }
            }
            completionHandler(movieGenres)
        }
    }
    
    func getTotalPages(url: String, completionHandler: @escaping ((Int) -> Void)) {
        movieDBAPI.requestTotalPages(url: url) { (value) in
            completionHandler(value)
        }
    }
}

// MARK: MovieDB Parser
struct MovieDBParser {
    
    func parseMovieDictionary(dictionary: [String: Any]) -> Movie? {
        guard let id = dictionary["id"] as? Int,
              let title = dictionary["title"] as? String,
              let description = dictionary["overview"] as? String,
              let rating = dictionary["vote_average"] as? Double,
              let posterURL = dictionary["poster_path"] as? String,
              let genreIDs = dictionary["genre_ids"] as? [Int]
        else { return nil }
        
        return Movie(id: id, title: title, description: description, rating: rating, posterURL: posterURL, genreIDs: genreIDs)
    }
    
    func parseGenreDictionary(dictionary: [String: Any]) -> Genre? {
        guard let id = dictionary["id"] as? Int,
              let name = dictionary["name"] as? String
        else { return nil }
        
        return Genre(id: id, name: name)
    }
    
}

//struct RickAndMortyParser {
//
//    func parseCharacterDictionary(dictionary: [String: Any]) -> Character? {
//        guard let id = dictionary["id"] as? Int,
//              let name = dictionary["name"] as? String
//        else { return nil }
//
//        return Movie(id: id, name: name)
//    }
//
//}

// MARK: MovieDB API
struct MovieDBAPI {
    
    func requestGenres(completionHandler: @escaping (([[String: Any]]) -> Void)) {
        let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=2c84bee7ec597369d0b15bc1d8b7d41e&language=en-US")!
        
        typealias WebGenres = [String: Any]
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let genresDictionary = json["genres"] as? [WebGenres]
            else {
                completionHandler([])
                return
            }
            completionHandler(genresDictionary)
        }
        .resume()
    }
    
    func requestTotalPages(url: String, completionHandler: @escaping ((Int) -> Void)) {
        let url = URL(string: url)!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let totalPages = json["total_pages"] as? Int
            else {
                completionHandler(0)
                return
            }
            completionHandler(totalPages)
        }
        .resume()
    }
    
    func requestMoviePoster(url: String, completionHandler: @escaping ((UIImage?) -> Void)) {
        let url = URL(string: "https://image.tmdb.org/t/p/original" + url)!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data
            else {
                completionHandler(nil)
                return
            }
            let poster = UIImage(data: data)
            completionHandler(poster)
        }
        .resume()
    }
    
    func requestPopularMovies(page: Int, completionHandler: @escaping ([[String: Any]]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=2c84bee7ec597369d0b15bc1d8b7d41e&language=en-US&page=" + String(page))!
        
        typealias WebMovie = [String: Any]
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let moviesDictionary = json["results"] as? [WebMovie]
            else {
                completionHandler([])
                return
            }
            completionHandler(moviesDictionary)
        }
        .resume()
    }
    
    func requestNowPlayingMovies(page: Int, completionHandler: @escaping ([[String: Any]]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=2c84bee7ec597369d0b15bc1d8b7d41e&language=en-US&page=" + String(page))!
        
        typealias WebMovie = [String: Any]
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let moviesDictionary = json["results"] as? [WebMovie]
            else {
                completionHandler([])
                return
            }
            completionHandler(moviesDictionary)
        }
        .resume()
    }
    
    //    func requestCharacters(completionHandler: @escaping ([[String: Any]]) -> Void) {
    //        let url = URL(string: "https://rickandmortyapi.com/api/character")!
    //
    //        typealias WebCharacter = [String: Any]
    //
    //        URLSession.shared.dataTask(with: url) { (data, response, error) in
    //            guard let data = data,
    //                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
    //                  let charactersDictionary = json["results"] as? [WebCharacter]
    //            else {
    //                completionHandler([])
    //                return
    //            }
    //            completionHandler(charactersDictionary)
    //        }
    //        .resume()
    //    }
    
    //    func requestCharactersResult(completionHandler: @escaping (Result<[[String: Any]], Error>) -> Void) {
    //        let url = URL(string: "https://rickandmortyapi.com/api/character")!
    //
    //        URLSession.shared.dataTask(with: url) { (data, response, error) in
    //            guard let data = data,
    //                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
    //                  let charactersDictionary = json["results"] as? [[String: Any]]
    //            else {
    //                completionHandler(Result.failure(error!))
    //                return
    //            }
    //            completionHandler(Result.success(charactersDictionary))
    //        }
    //        .resume()
    //    }
    //
}
