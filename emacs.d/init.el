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

(use-package quelpa
  :ensure t
  :config
  (use-package quelpa-use-package
    :ensure t))

(use-package ron-mode
  :quelpa (ron-mode :fetcher github :repo "rhololkeolke/ron-mode")
  :config
  (add-to-list 'auto-mode-alist '("\\.ron\\'" . ron-mode)))

(global-visual-line-mode)
(global-eldoc-mode)

;;(add-to-list 'default-frame-alist '(font . "Hack-14"))

(set-face-attribute 'default nil
		    :family "Fira Mono"
		    :weight 'semi-light
		    :height 140)

(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "Cantarell" :slant normal :weight normal :height 150 :width normal)))))

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

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-one t)

  (doom-themes-visual-bell-config)

  (doom-themes-neotree-config)
  (doom-themes-org-config))

; fix ANSI color codes
(use-package xterm-color
  :ensure t)
(setq comint-output-filter-functions (remove 'ansi-color-process-output comint-output-filter-functions))
(add-hook 'compilation-mode-hook 'ansi-color-for-comint-mode-on)

(add-hook 'compilation-mode-hook
	;; enable ANSI filter
	  (lambda ()
	    ; disable font lock
	    (font-lock-mode -1)
	    (make-local-variable 'font-lock-function)
	    (setq font-lock-function (lambda (_) nil))
	    (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter nil t)
	    ))

(add-hook 'compilation-filter-hook 'cov-colorize-compilation-buffer)
; track the end of compilation output
(add-hook 'compilation-mode 'auto-revert-mode)

; smooth mouse scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line

(defun cov/command-error-function (data context caller)
  "Ignore the buffer-read-only, beginning-of-buffer,
end-of-buffer signals; pass the rest to the default handler."
  (when (not (memq (car data) '(quit
				buffer-read-only
				beginning-of-line
				end-of-line
                                beginning-of-buffer
                                end-of-buffer)))
    (command-error-default-function data context caller)))

(setq command-error-function #'cov/command-error-function)

;; org mode settings
; set agenda key
(add-to-list 'org-agenda-files "~/sync/notes/")

(global-set-key (kbd "C-c a") 'org-agenda)

; allow a variable width font in org mode
(use-package mixed-pitch
  :ensure t
  :hook (text-mode . mixed-pitch-mode))

;; fontify (?) code blocks
(setq org-src-fontify-natively t)

; todo keywords
(setq org-todo-keywords
      '((sequence "TODO" "WAIT" "|" "DONE")))

(defun cov/get-date ()
  "Get the current date."
  (format-time-string "%y.%m.%d %H:%M")
  )

(defun cov/on-todo ()
  "Function called when $ORG_STATE is TODO."
  (org-set-property "CREATED" (cov/get-date))
  (org-delete-property "FINISHED")
  )

(defun cov/on-done ()
  "Functino called when $ORG_STATE is DONE."
  (org-set-property "FINISHED" (cov/get-date))
  )

(defun cov/on-todo-state-changed ()
  "Function to be run when org todo state is changed."
  (cond
   ((string= org-state "TODO") (cov/on-todo))
    ((string= org-state "DONE") (cov/on-done))
    (t (message "nuthin"))))

(add-hook 'org-after-todo-state-change-hook 'cov/on-todo-state-changed)

;; end org mode

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

;; setup autosave

(defvar cov-backup-dir (concat user-emacs-directory "backups"))
(defvar cov-autosave-dir (concat user-emacs-directory "auto-save/"))

(defun cov-ensure-dir (dir-path)
  "Ensure that directory at DIR-PATH exists."
  (unless (file-directory-p dir-path)
    (make-directory dir-path)))

(cov-ensure-dir cov-backup-dir)
(cov-ensure-dir cov-autosave-dir)

;; put backups in ./backups
(setq backup-directory-alist `((".*" . ,cov-backup-dir)))

; set format for autosave file names
(setq auto-save-file-name-transforms
      `((".*" ,cov-autosave-dir t)))

(global-display-line-numbers-mode 1)

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
  :ensure t
  :config (exec-path-from-shell-initialize))

(setq shell-file-name "/bin/bash")

;; load scripts directory
(add-to-list 'load-path (expand-file-name "scripts" user-emacs-directory))

(electric-pair-mode)

(mouse-avoidance-mode 'animate)

(defvar cov-preferred-columns 80
  "Preferred number of columns in a window.
Can be changed for different modes.")

(defun cov-set-window-width (width)
  "Set current window's width to WIDTH."
  (adjust-window-trailing-edge nil (- width (window-width)) t))

(defun cov-set-window-preferred-columns ()
  "Set current window to preferred size.
Contains a reference to the variable `cov-preferred-columns'"
  (interactive)
  (cov-set-window-width cov-preferred-columns)
  (setq window-size-fixed t))

(defun cov-toggle-window-size-fixed ()
    "Emacs doesn't have a function for this for some stupid reason."
  (interactive)
  (if 'window-size-fixed
      (setq window-size-fixed nil)
    ;(setq window-size-fixed t)
    ))

(require 'cov-keybind)

(use-package evil-magit
  :ensure t
  :config
  (require 'evil-magit))

(use-package all-the-icons
  :ensure t)

(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  (setq company-tooltip-limit 15)
   (setq company-tooltip-align-annotations t)
   (setq company-idle-delay .1)
   (setq company-echo-delay 0)
   (setq company-begin-commands '(self-insert-command))
   (use-package company-box
     :ensure t
     :hook (company-mode . company-box-mode)))

(use-package company-ansible
  :ensure t
  :config (add-to-list 'company-backends 'company-ansible))

(use-package flycheck
  :ensure t)
(setq-default flycheck-emacs-lisp-load-path 'inherit)
(add-hook 'after-init-hook
	  (lambda()
	    (global-flycheck-mode)))


(use-package helm
  :ensure t
  :commands (helm-mode helm-M-x)
  :bind
  ("M-x" . 'helm-M-x)
  :config
  (use-package helm-ls-git
    :ensure t
    :requires helm)
  (helm-mode 1))

(use-package magit
  :ensure t)

;(require 'git-gutter-fringe)
(use-package diff-hl
  :ensure t
  :config
  (diff-hl-flydiff-mode)
  (global-diff-hl-mode))

(use-package neotree
  :ensure t
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)

(use-package projectile
  :ensure t
  :config
  (setq projectile-mode-line
	'(:eval (format " project[%s]"
			(projectile-project-name))))
  (projectile-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode-enable))

(use-package recentf
  :ensure t)
(add-hook 'after-init-hook
	  (lambda()
	    (setq recentf-save-file (concat user-emacs-directory ".recentf"))
	    (setq recentf-max-menu-items 30)
	    (recentf-mode 1)))

(use-package restart-emacs
  :ensure t)

(use-package yaml-mode
  :ensure t)

(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode)
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets/"
			   "~/system/dotfiles/yasnippet-snippets/"))
  (yas-reload-all))

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-engines-alist
	'(("go" . "\\.tmpl\\'"))))

(use-package bind-key
  :ensure t)

;(require 'cov-java)
;(require 'cov-kotlin)
;(require 'cov-go)
;(require 'cov-groovy)
(require 'cov-rust)
;(require 'cov-py)

(use-package doom-modeline
  :ensure t
  :requires all-the-icons
  :config
  (setq doom-modeline-icon (display-graphic-p))
  (setq find-file-visit-truename t)
  (setq doom-modeline-lsp t)
  (doom-modeline-mode 1)
  )

; emacs-purpose on github, enables purpose-mode. slightly confusing
; for setting purposes for windows to prevent unwanted resizing
(use-package window-purpose
  :ensure t
  :config
  (add-to-list 'purpose-user-mode-purposes '(prog-mode . main))
  (add-to-list 'purpose-user-mode-purposes '(conf-mode . main))
  (add-to-list 'purpose-user-mode-purposes '(text-mode . side))
  (add-to-list 'purpose-user-mode-purposes '(cargo-process-mode . side))
  (add-to-list 'purpose-user-mode-purposes '(magit-mode . side))
  (add-to-list 'purpose-user-mode-purposes '(helm-mode . side))
  (purpose-compile-user-configuration)
  (purpose-mode))

(defun cov-rename-file-and-buffer (new-name)
  "Rename the current file and buffer to NEW-NAME."
  (interactive "snew file name: ")
  (let ((name (buffer-name))
	(filename (buffer-file-name)))
    (if (not filename)
	(message "buffer '%s' is not a file" name)
      (if (get-buffer new-name)
	  (message "buffer with name '%s' already exists" new-name)
	(progn
	  (rename-file filename new-name 1)
	  (rename-buffer new-name)
	  (set-visited-file-name new-name)
	  (set-buffer-modified-p nil))))))

; debugger settings
; TODO wtf is gud


(use-package dap-mode
  :ensure t
  :requires hydra
  :config
  (add-hook 'dap-stopped-hook
	    (lambda ()
	      (call-interactively #'dap-hydra))))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(helm-completion-style (quote emacs))
 '(package-selected-packages
   (quote
    (evil-org dap-mode hydra evil-collection window-purpose company-box mixed-pitch quelpa-use-package quelpa ron-mode yasnippet yaml-mode web-mode use-package spacemacs-theme restart-emacs rainbow-delimiters projectile neotree monokai-theme lsp-ui helm-ls-git flycheck-rust exec-path-from-shell evil-surround evil-magit doom-themes doom-modeline diff-hl company-lsp company-ansible cargo))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(variable-pitch ((t (:family "Cantarell" :slant normal :weight normal :height 150 :width normal)))))
