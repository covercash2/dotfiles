;;; init.el --- Summary
;;; Commentary:
;;; Code:
;(package-initialize)
(require 'cask (concat (getenv "HOME") "/.cask/cask.el"))
(cask-initialize)

(require 'pallet)
(pallet-mode t)

;; load scripts directory
(add-to-list 'load-path (expand-file-name "scripts" user-emacs-directory))

(require 'cov-keybind)

(require 'cask)
(cask-initialize)

;; exec=path-from-shell
(when (eq system-type 'darwin)
  (require 'exec-path-from-shell)
  (exec-path-from-shell-initialize))

(if (eq system-type 'gnu/linux)
    (setq select-enable-clipboard t))

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
	    (global-company-mode)
	    (add-hook 'prog-mode-hook 'company-mode)))

(require 'flycheck)
(setq-default flycheck-emacs-lisp-load-path 'inherit)
(add-hook 'after-init-hook
	  (lambda()
	    (global-flycheck-mode)))

(require 'indium)

(require 'git-gutter)
(global-git-gutter-mode +1)

(require 'gruvbox-theme)
(load-theme 'gruvbox t)

(require 'helm)
(require 'helm-ls-git)
(add-hook 'after-init-hook
	  (lambda()
	    (helm-mode 1)
	    (global-set-key (kbd "M-x") 'helm-M-x)))

(require 'linum)
(require 'magit)

(require 'powerline)
(powerline-center-evil-theme)

(require 'projectile)
(projectile-mode)

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode-enable)

(require 'recentf)
(add-hook 'after-init-hook
	  (lambda()
	    (setq recentf-save-file (concat user-emacs-directory ".recentf"))
	    (setq recentf-max-menu-items 30)
	    (recentf-mode 1)))

(require 'restart-emacs)

(require 'yasnippet)
(add-hook 'after-init-hook
	  (lambda()
	    (setq yas-snippet-dirs
		  '("~/code/libraries/yasnippet-snippets/"))))
(add-hook 'prog-mode-hook 'yas-minor-mode)

(require 'web-mode)

; using cask now.
; leaving for backwards compatibility
; TODO remove
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(require 'diminish)
(require 'bind-key)

;; init ui
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; set agenda key
(global-set-key (kbd "C-c a") 'org-agenda)

;; font/face config
(set-face-attribute 'default nil :height 120)
(setq-default line-spacing 0.2)

;; highlight todos
(defun cov--highlight-todos ()
  "Highlight a bunch of well known comment annotations.
This functions should be added to the hooks of major modes for programming."
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|OPTIMIZE\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(add-hook 'text-mode-hook 'cov--highlight-todos)
(add-hook 'text-mode-hook 'cov--highlight-todos)

;; turn off error bell
(setq ring-bell-function 'ignore)

;; set tab width
(setq tab-width 4)

(require 'init-editor)

(require 'cov-java)
(require 'cov-kotlin)
(require 'cov-go)
(require 'cov-groovy)
(require 'cov-rust)
(require 'cov-py)

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-engines-alist
	'(("go" . "\\.tmpl\\'"))))

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

(add-hook 'c++-mode-hook (lambda() (setq flycheck-clang-language-standard "c++14")))

;; go stuff
(defun cov-go-mode-hook ()
  "Golang config."
  ; format before save
  (add-hook 'before-save-hook 'gofmt-before-save)
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
	   "go build -v && go test -v && go vet"))
  (set (make-local-variable 'company-backends) '(company-go))
  (company-mode)
  (go-projectile-derive-gopath))

(add-hook 'go-mode-hook 'cov-go-mode-hook)

;; c stuff
(setq c-default-style "linux"
      c-basic-offset 4)

;; c++
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode 'irony-mode)

;; syntax checker
(add-hook 'c++-mode-hook
	  (lambda () (setq flycheck-clang-include-path
			   (list (expand-file-name "~/code/projects/bbsp/include")))))

;; use irony-mode instead of default emacs completions
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files (quote ("~/notes/orgmode.org"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
