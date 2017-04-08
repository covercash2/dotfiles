(require 'init-elpa)
(require-package 'evil)
(require-package 'rainbow-delimiters)
(require-package 'flycheck)
(require-package 'company)

;; show mathcing parentheses
(show-paren-mode 1)
;; show current line
(global-hl-line-mode 1)

(evil-mode 1)

(add-hook 'after-init-hook
	  (lambda()
	    (global-flycheck-mode)))

;; rainbow-delimiters
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; put backups in ./backups
(setq cov-backup-dir (concat user-emacs-directory "backups"))
(setq backup-directory-alist `(("." . ,cov-backup-dir)))
(setq auto-save-default nil)

(setq company-tooltip-align-annotations t)
(setq company-idle-delay .3)
(add-hook 'prog-mode-hook 'company-mode)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (company-mode)
	    (linum-mode)
	    (electric-pair-mode 1)))

(provide 'init-editor)
