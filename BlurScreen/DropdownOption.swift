//
//  DropdownOption.swift
//  BlurScreen
//
//  Created by Peter Lyoo on 2023/05/05.
//
struct DropdownOption: Hashable {
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }

    var key: String
    var val: String
}
