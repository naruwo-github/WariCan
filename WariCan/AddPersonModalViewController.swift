//
//  AddPersonModalViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/11/04.
//

import UIKit

class AddPersonModalViewController: UIViewController {

    @IBOutlet private weak var nameTextField: UITextField!
    private var addPersonButtonAction: ((UITextField) -> Void)?
    private var initText: String = ""
    
    func setup(action: ((UITextField) -> Void)?, text: String) {
        self.addPersonButtonAction = action
        self.initText = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.text = self.initText
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.nameTextField, action: #selector(self.nameRegisterKeyboardCloseButtonTapped))
        // 入力済みの場合は、全選択されるように指定
        self.nameTextField.selectAll(self.nameTextField.text)
        // モーダルを開いたときにフォーカスが当たっているように指定
        self.nameTextField.becomeFirstResponder()
    }
    
    @objc private func nameRegisterKeyboardCloseButtonTapped() {
        self.nameTextField.endEditing(true)
        self.nameTextField.resignFirstResponder()
    }
    
    @IBAction func addPersonButtonTapped(_ sender: Any) {
        self.addPersonButtonAction?(self.nameTextField)
        self.dismiss(animated: true)
    }
    
}
