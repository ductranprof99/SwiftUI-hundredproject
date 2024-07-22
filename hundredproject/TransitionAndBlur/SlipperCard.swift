import SwiftUI

struct SlipperCard: View {
    
    @State var zoom = false
    
    var body: some View {
        Grid {
            if zoom {
                row
                
                Divider()
                
                row
            } else {
                getCard("Big content")
            }
            
        }
        .padding() // Add padding inside the card
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .green]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        .animation(.snappy, value: 10)
    }
    
    var row: some View {
        GridRow {
            getCard("Card in row col 0")
            getCard("Card in row col 1")
        }.padding(.zero)
    }
    
    func getCard(_ cardContent: String) -> some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(RadialGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 100))
            VStack {
                Text(cardContent)
                Image(systemName: "circle")
            }
        }
        .padding(.zero)
        .onTapGesture {
            withAnimation {
                self.zoom.toggle()
                print("Toggle")
            }
        }
    }
}

struct SlipperCard_Previews: PreviewProvider {
    static var previews: some View {
        SlipperCard()
    }
}
