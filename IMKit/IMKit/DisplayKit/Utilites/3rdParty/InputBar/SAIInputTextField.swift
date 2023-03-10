//
//  SAIInputTextField.swift
//  SAIInputBar
//
//  Created by SAGESSE on 7/23/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import UITextView_Placeholder

public class SAIInputTextField: UITextView {

    public override var contentSize: CGSize {
        didSet {
            item.contentSizeChanged()
        }
    }

    public override var text: String! {
        set {
            super.text = newValue
            delegate?.textViewDidChange?(self)
        }
        get {
            return super.text
        }
    }
    public override var attributedText: NSAttributedString! {
        set {
            super.attributedText = newValue
            delegate?.textViewDidChange?(self)
        }
        get {
            return super.attributedText
        }
    }

//    override func becomeFirstResponder() -> Bool {
//        super.becomeFirstResponder()
//        return self.becomeFirstResponder()
//    }

    func insertAttributedText(_ attributedText: NSAttributedString) {
        let currnetTextRange = selectedTextRange ?? UITextRange()
        let newTextLength = attributedText.length

        // read postion
        let location = offset(from: beginningOfDocument, to: currnetTextRange.start)
        let length = offset(from: currnetTextRange.start, to: currnetTextRange.end)
        let newRange = NSRange(location: location, length: newTextLength)

        // update text
        let att = convertFromNSAttributedStringKeyDictionary(typingAttributes)
        textStorage.replaceCharacters(in: NSRange(location: location, length: length), with: attributedText)
        textStorage.addAttributes(convertToNSAttributedStringKeyDictionary(att), range: newRange)

        // update new text range
        let newPosition = position(from: beginningOfDocument, offset: location + newTextLength) ?? UITextPosition()
        selectedTextRange = textRange(from: newPosition, to: newPosition)
    }

    lazy var item: SAIInputTextFieldItem = SAIInputTextFieldItem(textView: self, backgroundView: self.backgroundView)
    public lazy var backgroundView: UIImageView = UIImageView()
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
