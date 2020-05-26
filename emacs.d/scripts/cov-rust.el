;;; cov-rust --- Summary
;;; Commentary:
;;; configure Rust and its modes
;;;
;;; Code:

(require 'use-package)

(use-package rust-mode
  :ensure t
  :commands rust-enable-format-on-save
  :init
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
  :config
  (setq cov-preferred-columns 100)
  (setq fill-column 100)
  ; emacs 27
  ;(display-fill-column-indicator-mode t)
  (rust-enable-format-on-save))

(use-package lsp-mode
  :ensure t
  :hook (rust-mode . lsp)
  :commands lsp
  :config
  (setq lsp-signature-auto-activate t)
  (setq lsp-signature-doc-lines 1)
  (setq lsp-rust-server 'rust-analyzer)
  (setq lsp-rust-analyzer-server-command '("/usr/bin/rust-analyzer"))
  (setq gc-cons-threshold 100000000)
  (require 'lsp-clients))
(use-package lsp-ui
  :ensure t
  :hook (rust-mode . lsp-ui-mode)
  :requires lsp-mode
  :config
  (setq lsp-ui-sideline-update-mode 'line)
  (setq lsp-ui-doc-position 'top))

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
