//
//  Dropdown.swift
//  BlurScreen
//
//  Created by Peter Lyoo on 2023/05/05.
//

import SwiftUI

struct Dropdown: View {
    var options: [DropdownOption]
    var onSelect: ((_ key: String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(self.options, id: \.self) { option in
                DropdownOptionElement(val: option.val, key: option.key, onSelect: self.onSelect)
            }
        }

        .background(Color.white)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.primary, lineWidth: 1)
        )
    }
}

struct DropdownButton_Previews: PreviewProvider {
    static let options = [
        DropdownOption(key: "week", val: "This week"), DropdownOption(key: "month", val: "This month"), DropdownOption(key: "year", val: "This year")
    ]

    static let onSelect = { key in
        print(key)
    }

    static var previews: some View {
        Group {
            VStack(alignment: .leading) {
                DropdownButton(displayText: .constant("This month"), options: options, onSelect: onSelect)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .foregroundColor(Color.primary)

            VStack(alignment: .leading) {
                DropdownButton(shouldShowDropdown: true, displayText: .constant("This month"), options: options, onSelect: onSelect)
                Dropdown(options: options, onSelect: onSelect)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .foregroundColor(Color.primary)
        }
    }
}
