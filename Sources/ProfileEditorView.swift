import SwiftUI

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: BrowserProfile
    let onSave: (BrowserProfile) -> Void

    init(profile: BrowserProfile, onSave: @escaping (BrowserProfile) -> Void) {
        _draft = State(initialValue: profile)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本") {
                    TextField("名称", text: $draft.name)
                    TextField("主页", text: $draft.homePage)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
                Section("User Agent") {
                    Picker("预设", selection: $draft.uaPreset) {
                        ForEach(PresetData.uaPresetOptions) { item in
                            Text(item.label).tag(item.key)
                        }
                    }
                    if draft.uaPreset == "custom" {
                        TextField("自定义 UA", text: $draft.customUA, axis: .vertical)
                            .lineLimit(3...6)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
                Section("语言与时区") {
                    Picker("语言", selection: $draft.language) {
                        ForEach(PresetData.languageOptions) { item in
                            Text(item.label).tag(item.key)
                        }
                    }
                    Picker("时区", selection: $draft.timeZoneId) {
                        ForEach(PresetData.timeZoneOptions) { item in
                            Text(item.label).tag(item.key)
                        }
                    }
                }
                Section("屏幕") {
                    Picker("尺寸", selection: $draft.screenPreset) {
                        ForEach(PresetData.screenOptions) { item in
                            Text(item.label).tag(item.key)
                        }
                    }
                }
                Section {
                    Text("说明：每个 profile 的 cookie 与本地存储独立隔离；UA 为原生设置，语言 / 时区 / 屏幕为 JS 层表面参数，引擎级指纹（canvas / WebGL 等）在 iOS 上无法修改。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile 设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if draft.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            draft.name = "Profile"
                        }
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
    }
}
