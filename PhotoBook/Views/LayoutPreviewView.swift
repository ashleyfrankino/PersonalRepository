import SwiftUI

struct LayoutPreviewView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var layoutEngine: LayoutEngine
    @State private var selectedStyle: LayoutStyle = .classic
    @State private var currentPageIndex = 0

    var body: some View {
        NavigationView {
            VStack {
                if photoManager.selectedPhotos.isEmpty {
                    emptyStateView
                } else if let layout = layoutEngine.currentLayout {
                    layoutView(layout)
                } else {
                    generateLayoutView
                }
            }
            .navigationTitle("Preview")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Layout Generated")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Select photos first to generate your photobook layout")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }

    private var generateLayoutView: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Choose Your Style")
                .font(.title)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(LayoutStyle.allCases, id: \.self) { style in
                        StyleCard(
                            style: style,
                            isSelected: selectedStyle == style,
                            action: { selectedStyle = style }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Text("\(photoManager.selectedPhotos.count) photos selected")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                Task {
                    await layoutEngine.generateLayout(
                        from: photoManager.selectedPhotos,
                        style: selectedStyle
                    )
                }
            }) {
                HStack {
                    if layoutEngine.isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Generating...")
                    } else {
                        Image(systemName: "wand.and.stars")
                        Text("Generate Layout")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(layoutEngine.isGenerating ? Color.gray : Color.accentColor)
                .cornerRadius(12)
            }
            .disabled(layoutEngine.isGenerating)
            .padding(.horizontal)

            Spacer()
        }
    }

    private func layoutView(_ layout: LayoutModel) -> some View {
        VStack {
            TabView(selection: $currentPageIndex) {
                ForEach(Array(layout.pages.enumerated()), id: \.element.id) { index, page in
                    PagePreviewView(
                        page: page,
                        photos: photoManager.selectedPhotos
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            HStack {
                Text("Page \(currentPageIndex + 1) of \(layout.pages.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    layoutEngine.currentLayout = nil
                }) {
                    Text("Change Style")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct StyleCard: View {
    let style: LayoutStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)

                stylePreviewImage
            }

            Text(style.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .onTapGesture(perform: action)
    }

    @ViewBuilder
    private var stylePreviewImage: some View {
        switch style {
        case .classic:
            VStack(spacing: 4) {
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 50)
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 50)
            }
            .padding(8)

        case .modern:
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 4) {
                ForEach(0..<4) { _ in
                    Rectangle().fill(Color.gray.opacity(0.4))
                }
            }
            .padding(8)

        case .magazine:
            HStack(spacing: 4) {
                Rectangle().fill(Color.gray.opacity(0.4))
                    .frame(width: 60)
                VStack(spacing: 4) {
                    Rectangle().fill(Color.gray.opacity(0.4))
                    Rectangle().fill(Color.gray.opacity(0.4))
                }
            }
            .padding(8)

        case .collage:
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 4) {
                ForEach(0..<6) { _ in
                    Rectangle().fill(Color.gray.opacity(0.4))
                }
            }
            .padding(8)

        case .minimal:
            Rectangle().fill(Color.gray.opacity(0.4))
                .padding(20)
        }
    }
}

#Preview {
    LayoutPreviewView()
        .environmentObject(PhotoManager())
        .environmentObject(LayoutEngine())
}
