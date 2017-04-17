;;; Code:
(require 'init-elpa)

(use-package rust-mode
  :ensure t
  :config
  (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

  (defvar rust-platform-dir (concat (getenv "HOME") "/.rustup/toolchains/stable-x86_64-"
				    (if (eq system-type 'darwin)
					"apple-darwin/"
				      ;; else
				      "unknown-linux-gnu/")))

  (use-package cargo
    :ensure t
    :config
    (add-hook 'rust-mode-hook 'cargo-minor-mode))

  (use-package racer
    :ensure t
    :init
    (setq racer-cmd (concat (getenv "HOME") "/.cargo/bin/racer"))
    :config
    (setq racer-rust-src-path (concat rust-platform-dir "lib/rustlib/src/rust/src/"))
    (add-hook 'rust-mode-hook #'racer-mode)
    (add-hook 'rust-mode-hook #'eldoc-mode)
    (add-hook 'racer-mode-hook #'company-mode))

  (use-package flycheck-rust
    :ensure t
    :config
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))

(provide 'cov-rust)

