//
//  QuoteView.swift
//  BBQuotes18
//
//  Created by Tomáš Dušek on 05.10.2024.
//

import SwiftUI

struct FetchView: View {
    let vm = ViewModel()
    let show: String
    
    @State private var showDetail = false
    @State private var showRandomDetail = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(show.removeCaseAndSpace())
                    .resizable()
                    .frame(width: geo.size.width * 2.7, height: geo.size.height * 1.2)
                
                VStack {
                    // the second VStack is here because of the button which would jump up with every new request. If you wrap it to a Vstack, it takes the whole available sreecn space up to the third spacer and the button, so it behaves the same as with loaded data
                    //just remember that Space() devides the whole stack to parts with exactly the same height
                    VStack {
                        Spacer(minLength: 60)
                        
                        // this switch is here to prevent errors, basically just to show data when the fetching of it was succesful
                        switch vm.status {
                        case .succesCharacterQuote:
                            EmptyView()
                        case .notStarted:
                            EmptyView()
                        case .fetching:
                            ProgressView()
                        case .succesQuote:
                            Text("\"\(vm.quote.quote)\"")
                            // scales the text when needed to minimum 50%, just to be safe with longer quotes
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(.rect(cornerRadius: 25))
                                .padding(.horizontal)
                            ZStack (alignment: .bottom) {
                                AsyncImage(url: vm.character.images.randomElement()) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .onTapGesture {
                                    showDetail.toggle()
                                }
                                .frame(width: geo.size.width/1.1, height: geo.size.height/1.8)
                                Text(vm.quote.character)
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                            }
                            .frame(width: geo.size.width/1.1, height: geo.size.height/1.8)
                            .clipShape(.rect(cornerRadius: 50))
                            
                        case .successEpisode:
                            EpisodeView(episode: vm.episode)
                            
                        case .successCharacter:
                            HStack {
                                RandomCharacterView(character: vm.randomCharacter)
                            }
                            .onTapGesture {
                                showRandomDetail.toggle()
                            }
                            
                        case .failed(let error):
                                
                            Text(error.localizedDescription)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    HStack {
                        Button {
                            Task {
                                await vm.getQuoteData(for: show)
                            }
                        } label: {
                            Text("Random Quote")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color("\(show.removeSpaces())Button"))
                                .clipShape(.rect(cornerRadius: 7))
                                .shadow(color: Color("\(show.removeSpaces())Shadow"), radius: 2)
                        }
                        
                        Spacer ()
                        
                        Button {
                            Task {
                                await vm.getCharacter(for: show)
                            }
                        } label: {
                            Text("Random Character")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color("\(show.removeSpaces())Button"))
                                .clipShape(.rect(cornerRadius: 7))
                                .shadow(color: Color("\(show.removeSpaces())Shadow"), radius: 2)
                        }
                        
                        Spacer ()
                        
                        Button {
                            Task {
                                await vm.getEpisode(for: show)
                            }
                        } label: {
                            Text("Random Episode")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color("\(show.removeSpaces())Button"))
                                .clipShape(.rect(cornerRadius: 7))
                                .shadow(color: Color("\(show.removeSpaces())Shadow"), radius: 2)
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer(minLength: 110)
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
                
            }
            // this has to be done in order to make the ZStack centered - geometry reader is always based from the top left
            .frame(width: geo.size.width, height: geo.size.height)
            
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showDetail) {
            CharacterView(character: vm.character, show: show)
                .presentationBackground(.black)
        }
        .sheet(isPresented: $showRandomDetail) {
            CharacterView(character: vm.randomCharacter, show: show)
                .presentationBackground(.black)
        }
        .onAppear {
            Task {
                await vm.getQuoteData(for: show)
            }
        }
    }
    
}

#Preview {
    FetchView(show: Constants.bcsName)
        .preferredColorScheme(.dark)
}
