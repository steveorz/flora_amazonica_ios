import SwiftUI

struct AppDatePicker: View {
    let title: String
    @Binding var date: Date
    var components: DatePickerComponents = .date

    var body: some View {
        DatePicker(selection: $date, displayedComponents: components) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .tint(.brand)
    }
}
