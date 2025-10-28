import SwiftUI

struct PrintOptionsView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var layoutEngine: LayoutEngine
    @State private var selectedPrintService: PrintService = .custom
    @State private var bookSize: BookSize = .standard
    @State private var paperType: PaperType = .glossy
    @State private var quantity: Int = 1
    @State private var isProcessing = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Print Service")) {
                    Picker("Service Provider", selection: $selectedPrintService) {
                        ForEach(PrintService.allCases, id: \.self) { service in
                            Text(service.rawValue).tag(service)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Book Options")) {
                    Picker("Size", selection: $bookSize) {
                        ForEach(BookSize.allCases, id: \.self) { size in
                            Text(size.displayName).tag(size)
                        }
                    }

                    Picker("Paper Type", selection: $paperType) {
                        ForEach(PaperType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                }

                Section(header: Text("Summary")) {
                    if let layout = layoutEngine.currentLayout {
                        HStack {
                            Text("Pages")
                            Spacer()
                            Text("\(layout.pages.count)")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Photos")
                            Spacer()
                            Text("\(photoManager.selectedPhotos.count)")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Estimated Price")
                            Spacer()
                            Text(estimatedPrice)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Generate a layout first to see pricing")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(action: submitOrder) {
                        HStack {
                            Spacer()
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Processing...")
                                    .padding(.leading, 8)
                            } else {
                                Text("Submit Order")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!canSubmitOrder || isProcessing)
                }
            }
            .navigationTitle("Print Options")
            .alert("Order Status", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var canSubmitOrder: Bool {
        layoutEngine.currentLayout != nil &&
        !photoManager.selectedPhotos.isEmpty
    }

    private var estimatedPrice: String {
        guard let layout = layoutEngine.currentLayout else {
            return "$0.00"
        }

        let basePrice = bookSize.basePrice
        let pagePrice = Double(layout.pages.count) * 1.50
        let totalPrice = (basePrice + pagePrice) * Double(quantity)

        return String(format: "$%.2f", totalPrice)
    }

    private func submitOrder() {
        guard let layout = layoutEngine.currentLayout else {
            return
        }

        isProcessing = true

        Task {
            do {
                let printService = PrintServiceManager.shared
                let result = try await printService.submitOrder(
                    layout: layout,
                    photos: photoManager.selectedPhotos,
                    provider: selectedPrintService,
                    size: bookSize,
                    paperType: paperType,
                    quantity: quantity
                )

                await MainActor.run {
                    isProcessing = false
                    alertMessage = "Order submitted successfully!\n\nOrder ID: \(result.orderId)\nEstimated delivery: \(result.estimatedDelivery)"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    alertMessage = "Failed to submit order: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

enum PrintService: String, CaseIterable {
    case custom = "Custom API"
    case shutterfly = "Shutterfly"
    case mixbook = "Mixbook"
    case chatbooks = "Chatbooks"
}

enum BookSize: String, CaseIterable {
    case small = "small"
    case standard = "standard"
    case large = "large"

    var displayName: String {
        switch self {
        case .small: return "6x8 inches"
        case .standard: return "8x10 inches"
        case .large: return "11x14 inches"
        }
    }

    var basePrice: Double {
        switch self {
        case .small: return 19.99
        case .standard: return 29.99
        case .large: return 39.99
        }
    }
}

enum PaperType: String, CaseIterable {
    case glossy = "Glossy"
    case matte = "Matte"
    case lustre = "Lustre"
}

#Preview {
    PrintOptionsView()
        .environmentObject(PhotoManager())
        .environmentObject(LayoutEngine())
}
