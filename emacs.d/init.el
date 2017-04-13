
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(add-to-list 'load-path (expand-file-name "scripts" user-emacs-directory))
(require 'init-elpa)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

;; obsolete: needs to be moved here
(require 'init-editor)
(require 'init-ui)
;;

(require 'cov-java)
(require 'cov-kotlin)
(require 'cov-groovy)
(require 'cov-rust)

(use-package exec-path-from-shell
  :if (eq system-type 'darwin)
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(use-package restart-emacs
  :ensure t)

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook
	    (lambda()
	      (global-flycheck-mode))))

(use-package company
  :ensure t
  :config
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay .2)
  (add-hook 'prog-mode-hook 'company-mode))

(use-package evil
  :ensure t
  ;; :commands (evil-mode)
  :config
  (evil-mode 1)
  (use-package evil-leader
    :ensure t
    :config
    (global-evil-leader-mode))
  (use-package evil-surround
    :ensure t
    :config
    (global-evil-surround-mode)))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode-enable))

(use-package helm
  :ensure t
  :bind ("M-x" . helm-M-x)
  :config
  (helm-mode 1)
  (use-package helm-ls-git
    :ensure t))

(use-package golden-ratio
  :ensure t
  :config
  (golden-ratio-mode 1))

(use-package recentf
  :ensure t
  :init
  (setq recentf-save-file (concat user-emacs-directory ".recentf"))
  (setq recentf-max-menu-items 40)
  :config
  (recentf-mode 1))

(use-package projectile
  :ensure t
  :config
  (projectile-global-mode))

(use-package powerline
  :ensure t
  :config
  (powerline-center-evil-theme))

(use-package yasnippet
  :ensure t
  :init
  (setq yas-snippet-dirs
	'("~/code/libraries/yasnippet-snippets/"))
  :config
  (yas-global-mode))

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox t))

;; my functions and keybindings
(defun cov-edit-init ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(add-hook 'c++-mode-hook (lambda() (setq flycheck-clang-language-standard "c++14")))

;; web-mode
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-engines-alist
      '(("go" . "\\.tmpl\\'"))
)

;; go stuff
(defun cov-go-mode-hook ()
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

;; turn on company mode for all buffers
(add-hook 'after-init-hook 'global-company-mode)

(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))

(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (groovy-mode kotlin-mode racer flycheck-rust rust-mode jdee yasnippet web-mode rainbow-delimiters powerline multi-term memoize helm-projectile helm-ls-git gruvbox-theme golden-ratio go-projectile flycheck exec-path-from-shell evil-magit company-irony company-go auto-complete atom-one-dark-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
