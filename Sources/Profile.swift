import Foundation

struct NamedOption: Identifiable, Equatable {
    let key: String
    let label: String
    var id: String { key }
}

struct BrowserProfile: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String = "新 Profile"
    var uaPreset: String = "iphone17"
    var customUA: String = ""
    var language: String = "zh-CN"
    var timeZoneId: String = "" // "" = 跟随设备
    var screenPreset: String = "device"
    var homePage: String = "https://www.bing.com"

    var userAgent: String {
        if uaPreset == "custom" {
            return customUA.isEmpty ? PresetData.defaultUA : customUA
        }
        return PresetData.uaPresets[uaPreset] ?? PresetData.defaultUA
    }

    var screenSize: (width: Int, height: Int, dpr: Double)? {
        PresetData.screenPresets[screenPreset]
    }
}

enum PresetData {
    static let defaultUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"

    static let uaPresets: [String: String] = [
        "iphone17": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1",
        "iphone18": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
        "android": "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.122 Mobile Safari/537.36",
        "macSafari": "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15",
        "winChrome": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
    ]

    static let uaPresetOptions: [NamedOption] = [
        NamedOption(key: "iphone17", label: "iPhone Safari (iOS 17)"),
        NamedOption(key: "iphone18", label: "iPhone Safari (iOS 18)"),
        NamedOption(key: "android", label: "Android Chrome (Pixel 8)"),
        NamedOption(key: "macSafari", label: "macOS Safari"),
        NamedOption(key: "winChrome", label: "Windows Chrome"),
        NamedOption(key: "custom", label: "自定义"),
    ]

    // key -> (width, height, devicePixelRatio)；"device" 不在此表中 = 不覆盖
    static let screenPresets: [String: (width: Int, height: Int, dpr: Double)] = [
        "iphone15pro": (393, 852, 3.0),
        "iphonese": (375, 667, 2.0),
        "pixel8": (412, 915, 2.625),
        "desktop": (1920, 1080, 1.0),
    ]

    static let screenOptions: [NamedOption] = [
        NamedOption(key: "device", label: "跟随设备"),
        NamedOption(key: "iphone15pro", label: "iPhone 15 Pro · 393×852"),
        NamedOption(key: "iphonese", label: "iPhone SE · 375×667"),
        NamedOption(key: "pixel8", label: "Pixel 8 · 412×915"),
        NamedOption(key: "desktop", label: "桌面 · 1920×1080"),
    ]

    static let languageOptions: [NamedOption] = [
        NamedOption(key: "zh-CN", label: "简体中文 (zh-CN)"),
        NamedOption(key: "zh-TW", label: "繁體中文 (zh-TW)"),
        NamedOption(key: "en-US", label: "English US (en-US)"),
        NamedOption(key: "en-GB", label: "English UK (en-GB)"),
        NamedOption(key: "ja-JP", label: "日本語 (ja-JP)"),
        NamedOption(key: "ko-KR", label: "한국어 (ko-KR)"),
    ]

    static let timeZoneOptions: [NamedOption] = [
        NamedOption(key: "", label: "跟随设备"),
        NamedOption(key: "Asia/Shanghai", label: "上海 (UTC+8)"),
        NamedOption(key: "Asia/Taipei", label: "台北 (UTC+8)"),
        NamedOption(key: "Asia/Singapore", label: "新加坡 (UTC+8)"),
        NamedOption(key: "Asia/Tokyo", label: "东京 (UTC+9)"),
        NamedOption(key: "Europe/London", label: "伦敦"),
        NamedOption(key: "Europe/Berlin", label: "柏林"),
        NamedOption(key: "America/New_York", label: "纽约"),
        NamedOption(key: "America/Los_Angeles", label: "洛杉矶"),
        NamedOption(key: "UTC", label: "UTC"),
    ]
}
