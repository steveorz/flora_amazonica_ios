import SwiftUI

struct AppSwitch: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
        }
        .tint(Color.navigationSelection)
    }
}
