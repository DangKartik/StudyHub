import SwiftUI

/// A numeric text field that selects its entire existing value the moment it gains
/// focus — matching standard iOS behavior for tap-to-replace numeric entry. SwiftUI's
/// native `TextField` has no public API for this, so this wraps `UITextField` directly.
/// Works for both `Int` and `Double` fields; pass `.decimalPad` for `Double` values that
/// need a decimal point.
struct SelectAllNumberField<Value: Numeric & LosslessStringConvertible>: UIViewRepresentable {
    @Binding var value: Value
    var keyboardType: UIKeyboardType = .numberPad

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = keyboardType
        textField.textAlignment = .right
        textField.text = String(value)
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.value = $value
        let text = String(value)
        if !uiView.isFirstResponder && uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var value: Binding<Value>

        init(value: Binding<Value>) {
            self.value = value
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                textField.selectAll(nil)
            }
        }

        @objc func textChanged(_ textField: UITextField) {
            value.wrappedValue = Value(textField.text ?? "") ?? .zero
        }
    }
}
