;;; Code:

(require 'rust-mode)

(require 'cargo)

(require 'racer)

(require 'flycheck-rust)

;; enable rust-mode
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

;; tab to complete
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)

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

;; racer setup
(setq racer-cmd 
      (concat (getenv "HOME")
	      "/.cargo/bin/racer"))

(setq racer-rust-src-path
      (concat 
	rust-toolchain-dir
	"lib/rustlib/src/rust/src/"))

;; hooks
(add-hook 'rust-mode-hook 'cargo-minor-mode)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'rust-mode-hook #'eldoc-mode)
(add-hook 'racer-mode-hook #'company-mode)
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

(provide 'cov-rust)


