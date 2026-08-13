import Foundation
import Observation
import Supabase

enum AppConfig {
    static var supabaseURL: URL? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              !value.isEmpty, !value.hasPrefix("$(") else { return nil }
        return URL(string: value)
    }

    static var publishableKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
              !value.isEmpty, !value.hasPrefix("$(") else { return nil }
        return value
    }

    static var supabase: SupabaseClient? {
        guard let url = supabaseURL, let key = publishableKey else { return nil }
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}

@Observable
@MainActor
final class SessionStore {
    enum State: Equatable { case loading, signedOut, signedIn, demo }

    private(set) var state: State = .loading
    private(set) var email = ""
    var errorMessage: String?

    func restore() async {
        guard let client = AppConfig.supabase else {
            state = .demo
            return
        }
        do {
            let session = try await client.auth.session
            email = session.user.email ?? ""
            state = .signedIn
        } catch {
            state = .signedOut
        }
    }

    func signIn(email: String, password: String) async {
        guard let client = AppConfig.supabase else {
            self.email = email.isEmpty ? "demo@auralink.ai" : email
            state = .demo
            return
        }
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            self.email = session.user.email ?? email
            errorMessage = nil
            state = .signedIn
        } catch {
            errorMessage = "E-mail ou senha incorretos. Confira os dados e tente novamente."
        }
    }

    func signOut() async {
        try? await AppConfig.supabase?.auth.signOut()
        email = ""
        state = AppConfig.supabase == nil ? .demo : .signedOut
    }

    func enterDemo() {
        email = "demo@auralink.ai"
        state = .demo
    }

    func handle(url: URL) async {
        guard let client = AppConfig.supabase else { return }
        do {
            try await client.auth.session(from: url)
            await restore()
        } catch {
            errorMessage = "Não foi possível concluir a autenticação."
        }
    }
}
