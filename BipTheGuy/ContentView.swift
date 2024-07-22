//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Che-lun Hu on 2024/7/22.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var animateImage = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    
    var body: some View {
        VStack {
            Spacer()
            
            bipImage
                .resizable()
                .scaleEffect(animateImage ? 1.0 : 0.9)
                .scaledToFit()
                .onTapGesture {
                    playsound(soundName: "punchSound")
                    animateImage = false    // will immediately shrink using .scaleEffect to 90% of size
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        animateImage = true
                    }
                    
                }
            
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in
                // Because we cannot convert PhotosPickerItem type to Image type immediately,
                // we need to:
                // - get the data inside the PhotosPickerItem selectedPhoto
                // - use the data to create a UIImage
                // - use the UIImage to create an Image,
                // - and assign that image to bipImage
                
                // loadTransferable 中有async及throw
                // throw表示若有錯誤會丟出來，因此用do try catch
                // async則要在Task{}中並且要有await關鍵字(Threads?)
                Task {
                    do {
                        if let data = try await newValue?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                bipImage = Image(uiImage: uiImage)
                            }
                        }
                    } catch {
                        print("🥲 ERROR: loading failed \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding()
    }
    
    func playsound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("🥲 Could not read file named \(soundName) 🥲")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("🥲 ERROR: \(error.localizedDescription) creating audioPlayer.")
        }
    }
}

#Preview {
    ContentView()
}
