import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey = ""
    @State private var showAPIKey = false
    @State private var showSubscription = false

    var body: some View {
        NavigationStack {
            List {
                Section("AI Configuration") {
                    HStack {
                        if showAPIKey {
                            TextField("OpenAI API Key", text: $apiKey)
                                .textContentType(.password)
                        } else {
                            SecureField("OpenAI API Key", text: $apiKey)
                        }
                        Button {
                            showAPIKey.toggle()
                        } label: {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                        }
                    }
                    .onAppear {
                        apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
                    }
                    .onChange(of: apiKey) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "openai_api_key")
                    }
                }

                Section("Subscription") {
                    NavigationLink {
                        SubscriptionView()
                    } label: {
                        Label("Manage Subscription", systemImage: "crown.fill")
                    }
                }

                Section("Legal") {
                    NavigationLink {
                        ContactSupportView()
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    Link("Privacy Policy", destination: URL(string: "https://zzoutuo.github.io/TripForge/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://zzoutuo.github.io/TripForge/terms")!)
                    Link("Support Page", destination: URL(string: "https://zzoutuo.github.io/TripForge/support")!)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SubscriptionView: View {
    @State private var purchaseManager = PurchaseManager()

    var body: some View {
        List {
            Section("TripForge Pro") {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.forgeOrange)
                    Text("Unlock Full AI Power")
                        .font(.title2.bold())
                    Text("Unlimited AI planning, weather alerts, sharing, and more")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            if purchaseManager.isLoading {
                Section {
                    ProgressView()
                }
            } else {
                if let monthly = purchaseManager.monthlyProduct {
                    Section {
                        SubscriptionRow(title: "Monthly", product: monthly, isPurchased: purchaseManager.purchasedProductIDs.contains(monthly.id))
                    }
                }
                if let yearly = purchaseManager.yearlyProduct {
                    Section {
                        SubscriptionRow(title: "Yearly", product: yearly, isPurchased: purchaseManager.purchasedProductIDs.contains(yearly.id), badge: "Best Value")
                    }
                }
            }

            Section {
                Button("Restore Purchases") {
                    Task {
                        await purchaseManager.restorePurchases()
                    }
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Free tier includes:")
                        .font(.caption.bold())
                    Text("• 10 AI plans per month")
                        .font(.caption2)
                    Text("• Unlimited trip creation")
                        .font(.caption2)
                    Text("• Map view & offline access")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Subscription")
    }
}

struct SubscriptionRow: View {
    let title: String
    let product: Product
    let isPurchased: Bool
    var badge: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                    if let badge {
                        Text(badge)
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.forgeOrange)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                Text(product.displayPrice)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button("Subscribe") {
                    Task {
                        _ = try? await PurchaseManager().purchase(product)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
