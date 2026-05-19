import SwiftUI

struct FolioBodyTextEditor: View {
    @Binding var text: String

    @FocusState private var isFocused: Bool

    @ScaledMetric(relativeTo: .body) private var bodyPointSize = 19

    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: bodyPointSize, weight: .regular, design: .serif))
            .lineSpacing(bodyLineSpacing)
            .foregroundStyle(editorInk)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .tint(.accentColor)
#if os(iOS)
            .textInputAutocapitalization(.sentences)
#endif
        .onAppear {
            DispatchQueue.main.async {
                isFocused = true
            }
        }
    }

    private var bodyLineSpacing: CGFloat {
        bodyPointSize * 0.42
    }

    private var editorInk: Color {
        WrimoireTheme.ink.opacity(0.92)
    }
}
