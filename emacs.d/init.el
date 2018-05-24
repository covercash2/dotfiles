;;; init.el --- Summary
;;; Commentary:
;;; Code:
;(package-initialize)
(if (eq system-type 'gnu/linux)
    (setq select-enable-clipboard t))

;;(add-to-list 'default-frame-alist '(font . "Hack-14"))

(set-face-attribute 'default nil
		    :family "Input Mono"
		    :height 180)

;; init ui
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(blink-cursor-mode 0)

;; org mode settings
; set agenda key
(global-set-key (kbd "C-c a") 'org-agenda)

;; fontify (?) code blocks
(setq org-src-fontify-natively t)

; todo keywords
(setq org-todo-keywords
      '((sequence "TODO" "STARTED" "|" "DONE")))

;; font/face config
(set-face-attribute 'default nil :height 120)
(setq-default line-spacing 0.2)

;; highlight todos
(defun cov--highlight-todos ()
  "Highlight a bunch of well known comment annotations.
This functions should be added to the hooks of major modes for programming."
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|OPTIMIZE\\|HACK\\|REFACTOR\\)"
          1 font-lock-warning-face t))))

(add-hook 'prog-mode-hook 'cov--highlight-todos)

;; turn off error bell
(setq ring-bell-function 'ignore)

;; set tab width
(setq tab-width 4)

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

;; log tag
(defvar cov--tag-error "[E] : ")

(defun switch-to-minibuffer ()
  "Switch to minibuffer."
  (interactive)
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))
    (error (concat cov--tag-error "minibuffer not active"))))

;; my functions and keybindings
(defun cov-edit-init ()
  "Open init.el for editing."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(require 'cask (concat (getenv "HOME") "/.cask/cask.el"))
(cask-initialize)

(require 'pallet)
(pallet-mode t)

(require 'ample-theme)
(load-theme 'ample t t)
(enable-theme 'ample)

(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)

;; load scripts directory
(add-to-list 'load-path (expand-file-name "scripts" user-emacs-directory))

(require 'cov-keybind)

(require 'all-the-icons)

(require 'company)
(add-hook 'after-init-hook
	  (lambda()
	    (setq company-tooltip-limit 15)
	    (setq company-tooltip-align-annotations t)
	    (setq company-idle-delay .1)
	    (setq company-echo-delay 0) ; stops blinking
	    ; start autocomplete only when typing
	    (setq company-begin-commands '(self-insert-command))
	    ;; turn on company mode for all buffers
	    (add-hook 'prog-mode-hook 'company-mode)))

(require 'company-ansible)
(add-to-list 'company-backends 'company-ansible)

(require 'flycheck)
(setq-default flycheck-emacs-lisp-load-path 'inherit)
(add-hook 'after-init-hook
	  (lambda()
	    (global-flycheck-mode)))

(require 'indium)

(require 'helm)
(require 'helm-ls-git)
(add-hook 'after-init-hook
	  (lambda()
	    (helm-mode 1)
	    (global-set-key (kbd "M-x") 'helm-M-x)))

(require 'linum)
(require 'magit)

(require 'neotree)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)

(require 'projectile)
(projectile-mode)
;; TODO this is a workaround for a lag issue
(setq projectile-mode-line
      '(:eval (format " Projectile[%s]"
		      (projectile-project-name))))


(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode-enable)

(require 'recentf)
(add-hook 'after-init-hook
	  (lambda()
	    (setq recentf-save-file (concat user-emacs-directory ".recentf"))
	    (setq recentf-max-menu-items 30)
	    (recentf-mode 1)))

(require 'restart-emacs)
;
;; TODO this doesn't work in remacs
;(require 'telephone-line)
;(setq telephone-line-primary-left-separator 'telephone-line-gradient
;     telephone-line-secondary-left-separator 'telephone-line-nil
;     telephone-line-primary-right-separator 'telephone-line-gradient
;     telephone-line-secondary-right-separator 'telephone-line-nil)
;(setq telephone-line-height 20
;     telephone-line-evil-use-short-tag t)
;(telephone-line-mode 1)
;
(require 'yaml-mode)

(require 'yasnippet)
(add-hook 'after-init-hook
	  (lambda()
	    (setq yas-snippet-dirs
		  '("~/code/libraries/yasnippet-snippets/"))))
(add-hook 'prog-mode-hook 'yas-minor-mode)


(require 'sublimity)
(sublimity-mode 1)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-engines-alist
      '(("go" . "\\.tmpl\\'")))

(require 'diminish)
(require 'bind-key)

;(require 'cov-java)
;(require 'cov-kotlin)
(require 'cov-go)
;(require 'cov-groovy)
(require 'cov-rust)
;(require 'cov-py)

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (cask elpy evil flycheck helm helm-core ivy lsp-mode magit-popup pyvenv gitter ample-theme yasnippet yaml-mode web-mode telephone-line sublimity restart-emacs rainbow-delimiters racer projectile pallet neotree magit lsp-rust indium helm-ls-git go-eldoc flycheck-rust exec-path-from-shell evil-surround evil-leader diminish company-go company-ansible cargo bind-key all-the-icons))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
