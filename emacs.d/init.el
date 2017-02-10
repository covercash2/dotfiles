(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; my functions and keybindings
(defun cov-edit-init ()
  (interactive)
  (find-file-other-window "~/.emacs.d/init.el"))

;; turn on vim bindings
(require 'evil)
(evil-mode 1)

;; global key bindings
(define-key evil-normal-state-map "," 'helm-M-x)

;; powerline is the bar at the bottom. helps with vim mode
(require 'powerline)
(powerline-center-evil-theme)
;; (powerline-default-theme)
;; (powerline-center-theme)
;; (powerline-vim-theme)
;; (powerline-nano-theme)

;; auto close pairs
(electric-pair-mode)

;; enable syntax checking
(global-flycheck-mode)

(add-hook 'c++-mode-hook (lambda() (setq flycheck-clang-language-standard "c++14")))

;; company mode completion
(setq company-idle-delay .3)

;; helm config
(require 'helm-config)
(require 'helm-ls-git)
(global-set-key (kbd "M-x") 'helm-M-x)
(helm-mode 1)

;; snippets
(setq yas-snippet-dirs
      '("~/code/libraries/yasnippet-snippets"))
(yas-global-mode)

;; gruvbox theme
(load-theme 'gruvbox t)

;; go stuff
(add-hook 'go-mode-hook (lambda ()
			  (set (make-local-variable 'company-backends) '(company-go))
			  (company-mode)))

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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("10e231624707d46f7b2059cc9280c332f7c7a530ebc17dba7e506df34c5332c4" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
