import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ProfileStore
    @State private var showingNew = false
    @State private var editing: BrowserProfile?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.profiles) { profile in
                    NavigationLink {
                        BrowserScreen(profile: profile)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(profile.name)
                                .font(.headline)
                            Text(subtitle(for: profile))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.delete(profile)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        Button {
                            editing = profile
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            store.clearData(for: profile)
                        } label: {
                            Label("清数据", systemImage: "eraser")
                        }
                        .tint(.orange)
                    }
                }
            }
            .navigationTitle("Profiles")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNew) {
                ProfileEditorView(profile: BrowserProfile()) { newProfile in
                    store.add(newProfile)
                }
            }
            .sheet(item: $editing) { profile in
                ProfileEditorView(profile: profile) { updated in
                    store.update(updated)
                }
            }
        }
    }

    private func subtitle(for profile: BrowserProfile) -> String {
        let ua = PresetData.uaPresetOptions.first { $0.key == profile.uaPreset }?.label ?? profile.uaPreset
        let tz = profile.timeZoneId.isEmpty ? "设备时区" : profile.timeZoneId
        return "\(ua) · \(profile.language) · \(tz)"
    }
}
