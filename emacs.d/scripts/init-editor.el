(require 'init-elpa)

;; show mathcing parentheses
(show-paren-mode 1)
;; show current line
(global-hl-line-mode 1)

;; put backups in ./backups
(setq cov-backup-dir (concat user-emacs-directory "backups"))
(setq backup-directory-alist `(("." . ,cov-backup-dir)))
(setq auto-save-default nil)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (linum-mode)
	    (electric-pair-mode 1)))

(provide 'init-editor)
