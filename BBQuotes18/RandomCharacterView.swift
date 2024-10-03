//
//  RandomCharacterView.swift
//  BBQuotes18
//
//  Created by Tomáš Dušek on 06.10.2024.
//

import SwiftUI

struct RandomCharacterView: View {
    var character: Character
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                AsyncImage(url: character.images.randomElement()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Make sure it fills the frame
                        .frame(width: geo.size.width/1.2, height: geo.size.height/1.4)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text("Portrayed By: \(character.portrayedBy)")
                    .font(.subheadline)
                Text("Appeared In: \(character.productions.joined(separator: ", "))")
                    .font(.subheadline)
                
            }
            .padding()
            .foregroundStyle(.white)
            .background(Color.black.opacity(0.6))
            .clipShape(.rect(cornerRadius: 25))
            .padding(.horizontal, 20)
        }
    }
}
#Preview {
    RandomCharacterView(character: ViewModel().character)
}
