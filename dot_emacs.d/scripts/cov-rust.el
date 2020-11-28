;;; cov-rust --- Summary
;;; Commentary:
;;; configure Rust and its modes
;;;
;;; Code:

(require 'use-package)

(defun cov-rust-mode-hook ()
  "Hook for Rust."
  (set-fill-column 100))

(add-hook 'rust-mode-hook 'cov-rust-mode-hook)

(use-package rustic
  :ensure t
  :requires (lsp flycheck)
  :config
  (setq rustic-format-on-save t))

(use-package cargo
  :ensure t
  :commands cargo-minor-mode
  :hook (rust-mode . cargo-minor-mode)
  :config
  (setq compilation-ask-about-save nil)
  )

(use-package company
  :ensure t
  :hook (prog-mode . company-mode))
(use-package company-lsp
  :ensure t
  :commands company-lsp
  :requires company)

(use-package flycheck
  :ensure t
  :commands flycheck-mode
  :hook (rust-mode . flycheck-mode))

;; set rust toolchain
;; defaults to nightly
(defvar rust-toolchain "nightly")

;; architecture
(defvar rust-toolchain-dir
  (concat (getenv "HOME")
	  "/.rustup/toolchains/"
	  rust-toolchain
	  "-x86_64"
	  (if (eq system-type 'darwin)
	    "-apple-darwin/"
	    ;; else
	    "-unknown-linux-gnu/")))

(provide 'cov-rust)
;;; cov-rust.el ends here
