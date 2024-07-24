//
//  CombineViewPage.swift
//  hundredproject
//
//  Created by Duc Tran  on 22/7/24.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let hcmc = CLLocationCoordinate2D(latitude: 10.9658681,
                                             longitude: 106.5539966)
}

struct CombineViewPage: View {
    static let rect = MKMapRect(
        origin: MKMapPoint(CLLocationCoordinate2D.hcmc),
        size: MKMapSize(width: 200000, height: 200000)
    )
    @State var locationData: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .rect(CombineViewPage.rect)
    )
    var body: some View {
        VStack {
            Map(position: $locationData)
                .ignoresSafeArea(.container ,edges: .top)
                .frame(height:300)
            
            Image("turtlerock")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .offset(x: 0, y: -100)
                .padding(.bottom, -100)

            VStack(alignment: .leading) {
                Text("Name")
                    .font(.title)
                HStack{
                    Text("Person description")
                    Spacer()
                    Text("This is my name")
                }
            }
            .padding()
            Spacer()
        }
    }
}


#Preview {
    CombineViewPage()
}
