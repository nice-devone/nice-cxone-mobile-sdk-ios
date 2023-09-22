import Kingfisher
import SwiftUI

struct ImageCarouselView: View {
    
    // MARK: - Properties
    
    @State private var currentIndex = 0
    
    private let imageUrls: [URL]
    
    // MARK: - Init
    
    init(imageUrls: [URL]) {
        self.imageUrls = imageUrls
    }
    
    // MARK: - Builder
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                CarouselView(currentIndex: $currentIndex, imageUrls: imageUrls, geometryProxy: proxy)
                
                CarouselPageIndicator(currentIndex: $currentIndex, imageCount: imageUrls.count)
                    .offset(y: -24)
            }
        }
    }
}

// MARK: - CarouselView

private struct CarouselView: View {
    
    // MARK: - Properties
    
    @Binding var currentIndex: Int
    
    @State private var opacity = 1.0
    @State var slideGesture: CGSize = .zero
    
    let imageUrls: [URL]
    let geometryProxy: GeometryProxy
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(imageUrls, id: \.self) { url in
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.width - 100)
            }
        }
        .frame(width: geometryProxy.size.width, height: geometryProxy.size.width - 100, alignment: .leading)
        .offset(x: CGFloat(currentIndex) * -geometryProxy.size.width, y: 0)
        .animation(.spring())
        .gesture(
            DragGesture()
                .onChanged { value in
                    slideGesture = value.translation
                }
                .onEnded { _ in
                    if slideGesture.width < -50 {
                        if currentIndex < imageUrls.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        }
                    } else if slideGesture.width > 50 {
                        if currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    }
                    
                    slideGesture = .zero
                }
        )
        .opacity(opacity)
        .onAppear {
            opacity = 1
        }
        .onWillDisappear {
            opacity = 0
        }
    }
}

// MARK: - CarouselPageIndicator

private struct CarouselPageIndicator: View {
    
    // MARK: - Properties
    
    @Binding var currentIndex: Int
    
    let imageCount: Int

    // MARK: - Builder
    
    var body: some View {
        if imageCount > 1 {
            HStack(spacing: 6) {
                ForEach(0..<imageCount, id: \.self) { index in
                    Circle()
                        .frame(
                            width: index == currentIndex ? 12 : 8,
                            height: index == currentIndex ? 12 : 8
                        )
                        .foregroundColor(index == currentIndex ? .blue : Color(.systemGray4))
                        .animation(.spring())
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct ImageCarouselView_Previews: PreviewProvider {
    
    @State private static var index = 0
    
    static var previews: some View {
        Group {
            VStack {
                ImageCarouselView(
                    imageUrls: [
                        URL(string: "https://pngimg.com/uploads/iphone_14/iphone_14_PNG48.png")!,
                        URL(string: "https://pngimg.com/uploads/iphone_14/iphone_14_PNG6.png")!
                    ]
                )
            }
            .previewDisplayName("Light Mode")
            
            ImageCarouselView(
                imageUrls: [
                    URL(string: "https://pngimg.com/uploads/iphone_14/iphone_14_PNG48.png")!,
                    URL(string: "https://pngimg.com/uploads/iphone_14/iphone_14_PNG6.png")!
                ]
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        
    }
}
