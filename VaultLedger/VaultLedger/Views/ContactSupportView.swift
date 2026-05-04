import SwiftUI

struct ContactSupportView: View {
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let topics = ["General", "Bug Report", "Feature Request", "Data Issue", "Import Problem", "Other"]

    var body: some View {
        Form {
            Section("Topic") {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
            }

            Section("Your Information") {
                TextField("Name (Optional)", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
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
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(email.isEmpty || message.isEmpty || isSubmitting)
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Contact Support")
        .alert("Feedback", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("success") {
                    message = ""
                    email = ""
                    name = ""
                    topic = "General"
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        let feedback = FeedbackRequest(topic: topic, name: name, email: email, message: message)

        guard let url = URL(string: Constants.feedbackBackendURL) else {
            isSubmitting = false
            alertMessage = "Failed to submit. Please email us at \(Constants.supportEmail)"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(feedback)
        } catch {
            isSubmitting = false
            alertMessage = "Failed to submit. Please email us at \(Constants.supportEmail)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Network error: \(error.localizedDescription). Please email us at \(Constants.supportEmail)"
                } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    alertMessage = "Thank you! Your feedback has been submitted successfully."
                } else {
                    alertMessage = "Failed to submit. Please email us at \(Constants.supportEmail)"
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
