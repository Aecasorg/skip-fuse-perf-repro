import SwiftUI

/// Since skip-ui 1.60.0, on Android, a resizable image whose width comes from its own aspect
/// ratio takes all the free width of its HStack and draws centred in it, in a List row, in a
/// sheet and in a toolbar. An image with a fixed frame is fine.
struct ResizableIconSheetScene: View {
    @State var isSheetPresented = false

    var body: some View {
        List {
            Section("Outside a sheet") {
                IconRows()
            }
            Section {
                Button("Present sheet") {
                    isSheetPresented = true
                }
            }
        }
        .navigationTitle("Resizable icons")
        .sheet(isPresented: $isSheetPresented) {
            IconSheet()
        }
    }
}

struct IconSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                IconRows()
                Spacer()
            }
            .padding()
            .navigationTitle("In a sheet")
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ReproIcon(height: 15)
                    }
                }
            }
        }
    }
}

struct IconRows: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Trailing icon")
                Spacer()
                ReproIcon(height: 24)
            }
            HStack {
                ReproIcon(height: 24)
                Text("Leading icon")
                Spacer()
                Text("12:00")
            }
            HStack {
                Text("Fixed frame")
                Spacer()
                Image("ReproIcon", bundle: .module)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct ReproIcon: View {
    let height: CGFloat

    var body: some View {
        Image("ReproIcon", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
    }
}
