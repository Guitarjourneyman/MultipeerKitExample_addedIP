//
//  ContentView.swift
//  MultipeerKitExample
//
//  Created by Guilherme Rambo on 29/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI
import MultipeerKit
import Combine

public final class ViewModel: ObservableObject {
    public init(){}
    @Published var message: String = ""
    @Published var selectedPeers: [Peer] = []

    func toggle(_ peer: Peer) {
        if selectedPeers.contains(peer) {
            selectedPeers.remove(at: selectedPeers.firstIndex(of: peer)!)
        } else {
            selectedPeers.append(peer)
        }
    }
}

struct ContentView: View {
    @ObservedObject private(set) var viewModel = ViewModel()
    @EnvironmentObject var dataSource: MultipeerDataSource
    
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack {
            Form {
                TextField("Message", text: $viewModel.message)
                
                Button(action: { self.sendToSelectedPeers(self.viewModel.message) }) {
                    Text("SEND")
                }
            }
            
            VStack(alignment: .leading) {
                Text("Peers").font(.system(.headline)).padding()
                
                List {
                    ForEach(dataSource.availablePeers) { peer in
                        HStack {
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundColor(peer.isConnected ? .green : .gray)
                            
                            Text(peer.name)
                            
                            Spacer()
                            
                            if self.viewModel.selectedPeers.contains(peer) {
                                Image(systemName: "checkmark")
                            }
                        }.onTapGesture {
                            self.viewModel.toggle(peer)
                        }
                    }
                }
            }
        }.alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Please select a peer"), message: nil, dismissButton: nil)
        }
    }
    
    func sendToSelectedPeers(_ message: String) {
        guard !self.viewModel.selectedPeers.isEmpty else {
            showErrorAlert = true
            return
        }
        
        let senderIP = dataSource.transceiver.getLocalIPAddress() // IP 주소 가져오기
        let payload = ExamplePayload(message: message, senderIP: senderIP) // IP 주소를 포함한 payload 생성
        dataSource.transceiver.send(payload, to: viewModel.selectedPeers) // 선택한 peers에게 payload 전송
    }
}


//Preview를 위한 코드이나 에러 발생으로 license권한 추가해야함
/*
struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}*/
