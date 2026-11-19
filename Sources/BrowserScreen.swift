import SwiftUI

struct BrowserScreen: View {
    let profile: BrowserProfile
    @StateObject private var state = WebState()
    @State private var addressText: String = ""
    @FocusState private var addressFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            WebView(profile: profile, state: state)
                .id(profile.id)
            Divider()
            toolbar
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            addressText = profile.homePage
        }
        .onChange(of: state.urlText) { _, newValue in
            if !addressFocused {
                addressText = newValue
            }
        }
    }

    private var toolbar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                TextField("输入网址或搜索", text: $addressText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .focused($addressFocused)
                    .onSubmit {
                        state.load(addressText)
                        addressFocused = false
                    }
                if state.isLoading {
                    ProgressView()
                }
            }
            HStack(spacing: 28) {
                Button {
                    state.webView?.goBack()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!state.canGoBack)

                Button {
                    state.webView?.goForward()
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!state.canGoForward)

                Button {
                    if state.isLoading {
                        state.webView?.stopLoading()
                    } else {
                        state.webView?.reload()
                    }
                } label: {
                    Image(systemName: state.isLoading ? "xmark" : "arrow.clockwise")
                }

                Button {
                    state.load(profile.homePage)
                } label: {
                    Image(systemName: "house")
                }

                Spacer()
            }
            .font(.title3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
