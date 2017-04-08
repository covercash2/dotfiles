(require 'init-elpa)
(require-package 'rust-mode)
(require-package 'company)
(require-package 'flycheck)
(require-package 'flycheck-rust)
(require-package 'racer)

(require 'rust-mode)

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
;; TODO add OSX compat
(setq rust-platform-dir (concat (getenv "HOME") "/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/"))

(add-hook 'rust-mode-hook
	  (lambda ()
	    (racer-mode)
	    (setq racer-cmd (concat (getenv "HOME") "/.cargo/bin/racer"))
	    (setq racer-rust-src-path (concat 'rust-platform-dir "lib/rustlib/src"))))
(add-hook 'racer-mode-hook
	  (lambda ()
	    (eldoc-mode)
	    (company-mode)))

(provide 'cov-rust)

