(add-to-list 'load-path (expand-file-name "scripts" user-emacs-directory))

(require 'init-elpa)
(require 'init-editor)
(require 'init-ui)
(require 'init-nav)

(require 'cov-rust)

(when (eq system-type 'darwin)
  (exec-path-from-shell-initialize))

;; my functions and keybindings
(defun cov-edit-init ()
  (interactive)
  (find-file-other-window "~/.emacs.d/init.el"))

;; powerline is the bar at the bottom. helps with vim mode
(require 'powerline)
(powerline-center-evil-theme)

(add-hook 'c++-mode-hook (lambda() (setq flycheck-clang-language-standard "c++14")))

;; snippets
(setq yas-snippet-dirs
      '("~/code/libraries/yasnippet-snippets"))
(yas-global-mode)

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
