import Combine
import SwiftUI

struct ValidatedTextField: View {
    
    // MARK: - Properties
    
    let title: String
    
    let label: String?
    
    let validator: ((String) -> String?)?
    
    @Binding var text: String
    
    @State var error: String?

    // MARK: - Init
    
    init(
        _ title: String,
        text: Binding<String>,
        validator: ((String) -> String?)? = nil,
        label: String? = nil,
        error: String? = nil
    ) {
        self.title = title
        self._text = text
        self.validator = validator
        self.error = error
        self.label = label
    }
    
    // MARK: - Builder
    
    var body: some View {
        let error = validator?(text)
        
        VStack(alignment: .leading, spacing: 4) {
            if let label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                TextField(title, text: $text)
                    .font(.body)
                
                Divider()
                    .background(error == nil ? UIColor.separator.color : .red)
                
                if let error {
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - Validators

func required(_ text: String) -> String? {
    text.isEmpty ? L10n.Common.requiredField : nil
}

func numeric(_ text: String) -> String? {
    (Double(text) == nil) ? "Invalid number" : nil
}

func allOf(_ validators: ((String) -> String?)...) -> (String) -> String? {
    { text in
        validators.reduce(nil) { error, validator in
            error ?? validator(text)
        }
    }
}

// MARK: - Preview

struct ValidatedTextField_Previews: PreviewProvider {
    @State static var text: String = ""

    static var previews: some View {
        VStack(spacing: 24) {
            ValidatedTextField(
                "Placeholder",
                text: $text,
                label: "Label"
            )
            .keyboardType(.decimalPad)
            
            ValidatedTextField(
                "Placeholder",
                text: $text,
                validator: required,
                label: "Label"
            )
            
            ValidatedTextField(
                "Placeholder",
                text: $text,
                validator: numeric,
                label: "Label"
            )
            .keyboardType(.decimalPad)
        }
        .padding(.horizontal, 24)
    }
}
