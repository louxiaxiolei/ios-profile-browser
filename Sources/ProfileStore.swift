import Foundation
import WebKit

final class ProfileStore: ObservableObject {
    @Published var profiles: [BrowserProfile] = [] {
        didSet { save() }
    }

    private let storageKey = "profiles.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BrowserProfile].self, from: data),
           !decoded.isEmpty {
            profiles = decoded
        } else {
            profiles = [BrowserProfile(name: "Profile 1")]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func add(_ profile: BrowserProfile) {
        profiles.append(profile)
    }

    func update(_ profile: BrowserProfile) {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
        }
    }

    func delete(_ profile: BrowserProfile) {
        clearData(for: profile)
        profiles.removeAll { $0.id == profile.id }
    }

    /// 清空某个 profile 的全部网站数据（cookie / localStorage / 缓存），profile 本身保留。
    func clearData(for profile: BrowserProfile) {
        let dataStore = WKWebsiteDataStore(forIdentifier: profile.id)
        dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                             modifiedSince: Date(timeIntervalSince1970: 0)) { }
    }
}
