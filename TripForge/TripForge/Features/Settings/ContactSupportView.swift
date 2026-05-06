import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Account", "Other"]

    var body: some View {
        Form {
            Section("Topic") {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { Text($0) }
                }
            }
            Section("Your Information") {
                TextField("Name (optional)", text: $name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            }
            Section {
                Button {
                    submitFeedback()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(email.isEmpty || message.isEmpty || isSubmitting)
            }
        }
        .navigationTitle("Contact Support")
        .alert("Feedback", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("success") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        let feedback = FeedbackRequest(topic: topic, name: name.isEmpty ? nil : name, email: email, message: message)
        guard let url = URL(string: "https://formsubmit.co/ajax/iocompile67692@gmail.com") else {
            alertMessage = "Failed to submit. Please email us directly."
            showAlert = true
            isSubmitting = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(feedback)
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Network error: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    alertMessage = "Message sent successfully! We will get back to you soon."
                    name = ""
                    email = ""
                    message = ""
                } else {
                    alertMessage = "Failed to submit. Please try again later."
                }
                showAlert = true
            }
        }.resume()
    }
}

struct FeedbackRequest: Codable {
    let topic: String
    let name: String?
    let email: String
    let message: String
}
