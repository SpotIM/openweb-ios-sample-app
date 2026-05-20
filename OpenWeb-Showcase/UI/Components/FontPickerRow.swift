//
//  FontPickerRow.swift
//  OpenWeb-Showcase
//
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import UIKit

struct FontPickerRow: View {
    private struct Metrics {
        static let topPadding: CGFloat = 4
        static let trailingSpacing: CGFloat = 16
    }

    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    @Binding var fontFamilyName: String?
    @State private var showFontPicker = false

    var body: some View {
        SettingsRow(title: title, subtitle: subtitle) {
            HStack {
                Text(fontFamilyName ?? "Default")
                    .font(previewFont)
                    .lineLimit(1)
                    .foregroundStyle(fontFamilyName != nil ? .primary : .secondary)
                Spacer()
                if fontFamilyName != nil {
                    Button {
                        fontFamilyName = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, Metrics.trailingSpacing)
                }
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, Metrics.topPadding)
            .contentShape(Rectangle())
            .onTapGesture { showFontPicker = true }
        }
        .sheet(isPresented: $showFontPicker) {
            SystemFontPicker(fontFamilyName: $fontFamilyName)
        }
    }

    private var previewFont: Font {
        guard let fontFamilyName else { return .body }
        return .custom(fontFamilyName, size: UIFont.labelFontSize)
    }
}

#Preview {
    List {
        FontPickerRow(
            title: "Font Family",
            subtitle: "Select which font family to use",
            fontFamilyName: .constant(nil)
        )
        FontPickerRow(
            title: "Font Family",
            subtitle: "Select which font family to use",
            fontFamilyName: .constant("Courier New")
        )
    }
}

// MARK: - UIFontPickerViewController Wrapper

private struct SystemFontPicker: UIViewControllerRepresentable {
    @Binding var fontFamilyName: String?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let picker = UIFontPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIFontPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        let parent: SystemFontPicker

        init(_ parent: SystemFontPicker) {
            self.parent = parent
        }

        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            guard let descriptor = viewController.selectedFontDescriptor else { return }
            parent.fontFamilyName = descriptor.object(forKey: .family) as? String ?? descriptor.postscriptName
            parent.dismiss()
        }

        func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            parent.dismiss()
        }
    }
}
