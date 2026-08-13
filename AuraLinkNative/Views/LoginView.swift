import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @State private var email = ""
    @State private var password = ""
    @State private var working = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 70)
                VStack(spacing: 14) {
                    AuraOrb(size: 72)
                    Text("Aura Link").font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("Sua inteligência, agora nativa no iPhone.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    TextField("E-mail", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Senha", text: $password).textContentType(.password)
                    if let error = session.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button {
                        working = true
                        Task {
                            await session.signIn(email: email, password: password)
                            working = false
                        }
                    } label: {
                        HStack {
                            if working { ProgressView().controlSize(.small) }
                            Text(working ? "Entrando..." : "Continuar")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)

                    Button("Explorar o protótipo") { session.enterDemo() }
                        .buttonStyle(.borderless)
                }
                .textFieldStyle(.roundedBorder)
                .padding(22)
                .auraGlass(cornerRadius: 28)
                .frame(maxWidth: 430)
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}

