import SwiftUI

struct DropdownButton: View {
    @State var shouldShowDropdown = false
    @Binding var displayText: String
    var options: [DropdownOption]
    var onSelect: ((_ key: String) -> Void)?

    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            HStack {
                Text(displayText)
                Spacer()
                    .frame(width: 20)
                Image(systemName: self.shouldShowDropdown ? "chevron.up" : "chevron.down")
            }
        }
        .padding(.horizontal)
        .cornerRadius(5)
        .frame(height: 30)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.primary, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 5).fill(Color.white)
        )
    }
}
