;;; init-editor --- Summary:
;;; Commentary:
;;; configs for editing files
;;; Code:

;; show mathcing parentheses
(show-paren-mode 1)
;; show current line
(global-hl-line-mode 1)

(defvar cov-backup-dir (concat user-emacs-directory "backups"))
(defvar cov-autosave-dir (concat user-emacs-directory "auto-save/"))

;; put backups in ./backups
(setq backup-directory-alist `((".*" . ,cov-backup-dir)))

;; specify directory for backup files
(setq auto-save-file-name-transforms
      `((".*" ,cov-autosave-dir t)))

(add-hook 'prog-mode-hook
	  (lambda ()
	    (linum-mode)
	    (electric-pair-mode 1)))

(provide 'init-editor)
;;; init-editor.el ends here
