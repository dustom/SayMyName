//
//  CharacterViewModel.swift
//  BBQuotes18
//
//  Created by Tomáš Dušek on 07.10.2024.
//

import Foundation

@Observable
class CharacterViewModel {
    enum FetchStatus {
        case notStarted
        case fetching
        case succes
        case failed(error: Error)
    }
    
    private(set) var status: FetchStatus = .notStarted
    
    private let fetcher = FetchService()
    
    var quote: Quote
    
    init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let quoteData = try! Data(contentsOf: Bundle.main.url(forResource: "samplequote", withExtension: "json")!)
        quote = try! decoder.decode(Quote.self, from: quoteData)
    }
    
    
    func getQuoteData(for character: String) async {
        status = .fetching
        
        do {
            quote = try await fetcher.fetchCharacterQuote(for: character)
            
            status = .succes
        } catch {
            status = .failed(error: error)
        }
    }
    
}
