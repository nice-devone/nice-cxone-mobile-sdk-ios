import SwiftUI

struct StoreView: View {
    
    // MARK: - Properies
    
    @ObservedObject private var viewModel: StoreViewModel
    
    @State private var searchText = ""
    @State private var isPresentingDisconnectAlert = false
    
    var searchResults: [ProductEntity] {
        if searchText.isEmpty {
            return viewModel.products
        } else {
            return viewModel.products.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // MARK: - Init
    
    init(viewModel: StoreViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Builder
    
    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading, isTransparent: .constant(true)) {
            ZStack(alignment: .bottomTrailing) {
                storeContent
                
                Button {
                    viewModel.openChat()
                } label: {
                    Image(systemName: "text.bubble.fill")
                        .imageScale(.large)
                }
                .padding(12)
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                )
                .offset(x: -12, y: -12)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .alert(isPresented: .constant(viewModel.error != nil)) {
            Alert.genericError
        }
        .alert(isPresented: $isPresentingDisconnectAlert) {
            Alert(
                title: Text(L10n.Common.attention),
                message: Text(L10n.Common.disconnectMessage),
                primaryButton: .destructive(Text(L10n.Common.signOut)) {
                    viewModel.signOut()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationBarTitle(L10n.Store.title)
        .navigationBarItems(
            leading: Button(
                action: {
                    isPresentingDisconnectAlert = true
                }, label: {
                    Asset.Common.disconnect
                }
            ),
            trailing: cartNavigationItem
        )
    }
}

// MARK: - Subviews

private extension StoreView {

    var cartNavigationItem: some View {
        Button(action: {
            viewModel.navigateToCart()
        }, label: {
            ZStack {
                Asset.Store.cart
                
                if viewModel.itemsInCart > 0 {
                    Text(viewModel.itemsInCart.description)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: 12, y: 12)
                }
            }
        })
    }
    
    var storeContent: some View {
        VStack {
            SearchBar(text: $searchText)
            
            GridStack(minCellWidth: 150, spacing: 10, numItems: searchResults.count) { index in
                let product = searchResults[index]
                
                StoreCard(
                    thumbnailUrl: product.thumbnailUrl,
                    title: product.title,
                    price: product.price
                )
                .onTapGesture {
                    viewModel.navigateToProduct(product)
                }
            }
        }
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct StoreView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            NavigationView {
                appModule.resolver.resolve(StoreView.self)!
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                appModule.resolver.resolve(StoreView.self)!
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
