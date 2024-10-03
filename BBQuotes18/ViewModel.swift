//
//  ViewModel.swift
//  BBQuotes18
//
//  Created by Tomáš Dušek on 04.10.2024.
//

import Foundation

@Observable
class ViewModel {
    enum FetchStatus {
        case notStarted
        case fetching
        case succesQuote
        case successEpisode
        case successCharacter
        case succesCharacterQuote
        case failed(error: Error)
    }
    
    private(set) var status: FetchStatus = .notStarted
    
    private let fetcher = FetchService()
    
    var quote: Quote
    var character: Character
    var randomCharacter: Character
    var episode: Episode
    
    init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let quoteData = try! Data(contentsOf: Bundle.main.url(forResource: "samplequote", withExtension: "json")!)
        quote = try! decoder.decode(Quote.self, from: quoteData)
        
        let characterData = try! Data(contentsOf: Bundle.main.url(forResource: "samplecharacter", withExtension: "json")!)
        character = try! decoder.decode(Character.self, from: characterData)
        
        let episodeData = try! Data(contentsOf: Bundle.main.url(forResource: "sampleepisode", withExtension: "json")!)
        episode = try! decoder.decode(Episode.self, from: episodeData)
        
        let randomCharacterData = try! Data(contentsOf: Bundle.main.url(forResource: "samplecharacter", withExtension: "json")!)
        randomCharacter = try! decoder.decode(Character.self, from: randomCharacterData)
        
    }
    
    func getQuoteData(for show: String) async {
        status = .fetching
        
        do {
            quote = try await fetcher.fetchQuote(from: show)
            
            character = try await fetcher.fetchCharacter(quote.character)
            
            character.death = try await fetcher.fetchDeath(for: character.name)
            
            status = .succesQuote
        } catch {
            status = .failed(error: error)
        }
    }
   
    
    func getEpisode(for show: String) async {
        status = .fetching
        
        do {
            if let unwrappedEpisode = try await fetcher.fetchEpisode(from: show) {
                episode = unwrappedEpisode
                
                status = .successEpisode
            }
    
        } catch {
            status = .failed(error: error)
        }
    }
    
    func getCharacter(for show: String) async {
        status = .fetching

        do {

            var found = false
                    
                    while !found {
                        // Fetch a random character
                        randomCharacter = try await fetcher.fetchRandomCharacter()
                    
                        // Check if the character is from the desired show
                        if randomCharacter.productions.contains(show) {
                            // If the character is from the show, fetch the death info
                            randomCharacter.death = try await fetcher.fetchDeath(for: randomCharacter.name)
                            
                            // Mark the character as found
                            found = true
                        }
                    }

            status = .successCharacter
            
        } catch {
            print(String(describing: error))
            status = .failed(error: error)
        }
    }
    
}
