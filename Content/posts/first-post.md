---
date: 2020-07-05 15:24
description: A description of my first post.
tags: first, article
---
# Hej!

My first post's text.

```
class LoginViewController: UIViewController {
    let viewModel = LoginViewModel()
    
    lazy var emailField: UITextField ...
    lazy var passwordField: UITextField ...
    lazy var infoLabel: UILabel ...
    lazy var indicator: UIActivityIndicatorView ...
    lazy var loginButton: UIButton ...
    
    private func setupBindings() {
        //view model inputs
        loginButton.addTarget(viewModel, action: #selector(viewModel.didPressLoginButton), for: .touchUpInside)
        emailField.addTarget(viewModel, action: #selector(viewModel.emailDidChange(_:)), for: .editingChanged)
        passwordField.addTarget(viewModel, action: #selector(viewModel.passwordDidChange(_:)), for: .editingChanged)
        
        //view model outputs
        viewModel.outputs.userInputIsValid = { [unowned self] isValid in
            self.loginButton.isEnabled = isValid
            self.loginButton.backgroundColor = isValid ? .green : .gray
        }
        
        viewModel.outputs.changedLoadingState = { [unowned self] state in
            switch state {
            case .loading:
                self.indicator.startAnimating()
            case .doneLoading(_):
                self.indicator.stopAnimating()
                self.infoLabel.isHidden = true
            case .failedLoading(let error) where error == .invalidCredentials:
                self.indicator.stopAnimating()
                self.infoLabel.isHidden = false
                self.infoLabel.text = "Invalid credentials"
                self.infoLabel.sizeToFit()
            default:
                ...
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
}
```

Let's continue...
