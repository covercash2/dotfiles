;;; init.el --- Summary
;;; Commentary:
;;; Code:

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(if (eq system-type 'gnu/linux)
    (setq select-enable-clipboard t))

;;(add-to-list 'default-frame-alist '(font . "Hack-14"))

(set-face-attribute 'default nil
		    :family "Input Mono"
		    :weight 'semi-light
		    :height 130)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;; font/face config
(setq-default line-spacing 0.0)

;; init ui
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(setq initial-scratch-message "")

(blink-cursor-mode 0)

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox t))

;; org mode settings
; set agenda key
(global-set-key (kbd "C-c a") 'org-agenda)

;; fontify (?) code blocks
(setq org-src-fontify-natively t)

; todo keywords
(setq org-todo-keywords
      '((sequence "TODO" "STARTED" "|" "DONE")))

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

(global-display-line-numbers-mode 1)

;(require 'git-gutter-fringe)
(setq git-gutter-fr:side 'right-fringe)

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

(use-package exec-path-from-shell
  :config (exec-path-from-shell-initialize))

(setq shell-file-name "/bin/bash")

;; load scripts directory
(add-to-list 'load-path (expand-file-name "scripts" user-emacs-directory))

(require 'cov-keybind)

(use-package all-the-icons)

(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-tooltip-limit 15)
   (setq company-tooltip-align-annotations t)
   (setq company-idle-delay .1)
   (setq company-echo-delay 0)
   (setq company-begin-commands '(self-insert-command)))

(use-package company-ansible
  :config (add-to-list 'company-backends 'company-ansible))

(use-package flycheck)
(setq-default flycheck-emacs-lisp-load-path 'inherit)
(add-hook 'after-init-hook
	  (lambda()
	    (global-flycheck-mode)))


(use-package helm
  :commands (helm-mode helm-M-x)
  :bind
  ("M-x" . 'helm-M-x)
  :config
  (helm-mode 1))
(use-package helm-ls-git
  :requires helm)

(use-package linum)
(use-package magit)

(use-package neotree
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)

(use-package projectile
  :config
  (setq projectile-mode-line
	'(:eval (format " project[%s]"
			(projectile-project-name))))
  (projectile-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode-enable))

(use-package recentf)
(add-hook 'after-init-hook
	  (lambda()
	    (setq recentf-save-file (concat user-emacs-directory ".recentf"))
	    (setq recentf-max-menu-items 30)
	    (recentf-mode 1)))

(use-package restart-emacs)

(use-package yaml-mode)

(use-package yasnippet)
(add-hook 'after-init-hook
	  (lambda()
	    (setq yas-snippet-dirs
		  '("~/system/dotfiles/yasnippet-snippets/"))))
(add-hook 'prog-mode-hook 'yas-minor-mode)


(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-engines-alist
	'(("go" . "\\.tmpl\\'"))))

(use-package bind-key)

;(require 'cov-java)
(require 'cov-kotlin)
;(require 'cov-go)
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
 '(custom-safe-themes
   (quote
    ("a22f40b63f9bc0a69ebc8ba4fbc6b452a4e3f84b80590ba0a92b4ff599e53ad0" "8f97d5ec8a774485296e366fdde6ff5589cf9e319a584b845b6f7fa788c9fa9a" "1436d643b98844555d56c59c74004eb158dc85fc55d2e7205f8d9b8c860e177f" default)))
 '(package-selected-packages
   (quote
    (rust-mode fish-mode prettier-js js3-mode company-tern 0blayout tern flymake-jslint gruvbox-theme company-lsp git-gutter-fringe evil-smartparens evil-cleverparens gradle-mode flycheck-kotlin kotlin-mode gnuplot-mode dart-mode flymake-rust fill-column-indicator docker-compose-mode cask elpy evil flycheck helm helm-core ivy lsp-mode magit-popup pyvenv gitter ample-theme yasnippet yaml-mode web-mode telephone-line sublimity restart-emacs rainbow-delimiters racer projectile pallet neotree magit lsp-rust indium helm-ls-git go-eldoc flycheck-rust exec-path-from-shell evil-surround evil-leader diminish company-go company-ansible cargo bind-key all-the-icons))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'scroll-left 'disabled nil)
