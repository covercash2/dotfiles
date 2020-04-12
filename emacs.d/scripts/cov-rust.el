;;; cov-rust --- Summary
;;; Commentary:
;;; configure Rust and its modes
;;;
;;; Code:

(require 'use-package)

(use-package rust-mode
  :commands rust-enable-format-on-save
  :init
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
  :config
  (rust-enable-format-on-save))

(use-package lsp-mode
  :hook (rust-mode . lsp)
  :commands lsp
  :config
  (setq lsp-signature-auto-activate t)
  (setq lsp-signature-doc-lines 1)
  (setq lsp-rust-server 'rust-analyzer)
  (setq lsp-rust-analyzer-server-command '("/usr/bin/rust-analyzer"))
  (require 'lsp-clients))
(use-package lsp-ui
  :hook (rust-mode . lsp-ui-mode)
  :requires lsp-mode)

(use-package cargo
  :commands cargo-minor-mode
  :hook (rust-mode . cargo-minor-mode))

(use-package company
  :hook (prog-mode . company-mode))
(use-package company-lsp
  :commands company-lsp
  :requires company)

(use-package eldoc-mode
  :hook (rust-mode . eldoc-mode))

(use-package flycheck
  :commands flycheck-mode
  :hook (rust-mode . flycheck-mode))
(use-package flycheck-rust
  :requires flycheck
  :hook (flycheck-mode . flycheck-rust-setup))

(defun cov-add-autoformat-hook ()
     "Add lsp autoformat to the save hook."
     (interactive)
     (add-hook 'before-save-hook 'lsp-format-buffer))

(add-hook 'rust-mode-hook 'cov-add-autoformat-hook)

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
