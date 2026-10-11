import SwiftUI

/// On Android, a ScrollView with `.fixedSize()` on its scroll axis crashes the app with
/// `IllegalStateException: Vertically scrollable component was measured with an infinity
/// maximum height constraints`. On iOS it sizes to its content. Each button reveals one case,
/// so a crash in one does not hide the other.
struct FixedSizeScrollViewScene: View {
    @State var showsVertical = false
    @State var showsHorizontal = false

    let items = ["Passport", "Driving licence", "Unavailable"]

    var body: some View {
        VStack(spacing: 16) {
            Button("Show vertical ScrollView, .fixedSize(horizontal: false, vertical: true)") {
                showsVertical = true
            }
            if showsVertical {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .border(Color.blue)
            }

            Button("Show horizontal ScrollView, .fixedSize(horizontal: true, vertical: false)") {
                showsHorizontal = true
            }
            if showsHorizontal {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                .border(Color.orange)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Fixed-size ScrollView")
    }
}
