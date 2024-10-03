//
//  CharacterView.swift
//  BBQuotes18
//
//  Created by Tomáš Dušek on 05.10.2024.
//

import SwiftUI

struct CharacterView: View {
    let character: Character
    let show: String
    let vm = CharacterViewModel()
    
    var body: some View {
        var isCalled: Bool = false
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ZStack (alignment: .top) {
                    Image(show.removeCaseAndSpace())
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            LinearGradient(stops: [Gradient.Stop(color: .clear, location: 0.5), Gradient.Stop(color: .black, location: 1)], startPoint: .top, endPoint: .bottom)
                        }
                    
                    ScrollView {
                        TabView {
                            ForEach(character.images, id: \.self) { characterImageURL in
                                
                                
                                AsyncImage(url: characterImageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(width: geo.size.width/1.2, height: geo.size.height/1.7)
                        .clipShape(.rect(cornerRadius: 25))
                        .padding(.top, 60)
                        VStack(alignment: .leading) {
                            Text(character.name)
                                .font(.largeTitle)
                            
                            Text("Portrayed By: \(character.portrayedBy)")
                                .font(.subheadline)
                            
                            Divider()
                            
                            switch vm.status {
                            case .notStarted:
                                EmptyView()
                            case .fetching:
                                ProgressView()
                            case .succes:
                                
                                Text("\"\(vm.quote.quote)\"")
                                    .onAppear() {
                                        if isCalled == true {
                                            withAnimation {
                                                proxy.scrollTo(2, anchor: .center)
                                            }
                                        }
                                        
                                    }
                                HStack {
                                    Spacer() // Pushes the button to the center horizontally
                                    Button {
                                        Task {
                                            await vm.getQuoteData(for: character.name)
                                        }
                                        isCalled = true
                                    } label: {
                                        Text("Random Quote")
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 15)
                                            .background(.white)
                                            .clipShape(.rect(cornerRadius: 10))
                                            .foregroundStyle(.black)
                                           
                                    }
                                    Spacer() // Balances the button hor
                                        
                                }
                                .padding(5)
                                .id(2)
                                Divider()
                            
                            case .failed(let error):
                                if let decodingError = error as? DecodingError {
                                    if case .dataCorrupted = decodingError {
                                        EmptyView()
                                    } else {
                                        Text(decodingError.localizedDescription)
                                    }
                                } else {
                                    Text(error.localizedDescription)
                                }
                            }

                           
                            
                            Text("\(character.name) Character Info")
                                .font(.title2)
                            
                            Text("Born: \(character.birthday)")
                            
                            Text("Occupations:")
                            
                            ForEach(character.occupations, id: \.self) { occupation in
                                Text("•\(occupation)")
                                    .font(.subheadline)
                            }
                            
                            Divider()
                            Text("Nicknames:")
                            
                            if character.aliases.isEmpty == false {
                                ForEach(character.aliases, id: \.self) { alias in
                                    Text("•\(alias)")
                                        .font(.subheadline)
                                }
                            } else {
                                Text("None")
                                    .font(.subheadline)
                            }
                                
                            
                            Divider()
                            
                            DisclosureGroup("Status (spoiler alert!)") {
                                VStack (alignment: .leading) {
                                    Text(character.status)
                                        .font(.title2)
                                    
                                    
                                    if let death = character.death {
                                        AsyncImage(url: death.image) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(.rect(cornerRadius: 15))
                                                .onAppear() {
                                                    withAnimation {
                                                        proxy.scrollTo(1, anchor: .bottom)
                                                    }
                                                    
                                                }
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        Text("How: \(death.details)")
                                            .padding(.bottom, 7)
                                        
                                        Text("Last words: \"\(death.lastWords)\"")
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            
                            .tint(.primary)
                        }
                        .frame(width: geo.size.width/1.25, alignment: .leading)
                        .padding(.bottom, 50)
                        .id(1)
                    }
                    .scrollIndicators(.hidden)
                    
                }
            }
        }
        .onAppear {
            Task {
                await vm.getQuoteData(for: character.name)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .environment(\.colorScheme, .dark)
    }
        
}

#Preview {
    CharacterView(character: ViewModel().character, show: Constants.bbName)
}
