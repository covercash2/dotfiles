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

(add-to-list 'default-frame-alist '(font . "Hack-14"))

(require 'cov-keybind)

(require 'cask)
(cask-initialize)

(require 'all-the-icons)

(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)

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
	    (add-hook 'prog-mode-hook 'company-mode)))

(add-to-list 'company-backends 'company-ansible)

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

(require 'neotree)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)

(require 'powerline)
(powerline-center-evil-theme)

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

(require 'yaml-mode)

(require 'yasnippet)
(add-hook 'after-init-hook
	  (lambda()
	    (setq yas-snippet-dirs
		  '("~/code/libraries/yasnippet-snippets/"))))
(add-hook 'prog-mode-hook 'yas-minor-mode)


(require 'sublimity)
(require 'sublimity-scroll)
(require 'sublimity-attractive)
(sublimity-mode 1)

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

;; TODO keyword regex
(defvar cov--todo-regex "\\<\\(FIX\\(ME\\)?\\|TODO\\|OPTIMIZE\\|HACK\\|REFACTOR\\)")

(defun cov--collect-todos ()
  "Create an occur buffer matching a regex."
  (interactive)
  (occur cov--todo-regex))

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

;; set shell for fish compatibility
(setq shell-file-name "/bin/bash")

;; inhibit annoying messages
;; ignore a couple of common "errors"
(setq debug-ignored-errors
      '(quit
        beginning-of-line    end-of-line
        beginning-of-buffer  end-of-buffer
        end-of-file
	text-read-only
        buffer-read-only
        file-supersession) )

(defvar error-buffer-name "*Errors*" "Errors log buffer.")

(defun say-and-log-error (data _ fun)
  "This error function communicates the errors in the echo area.
It does so by means of a one-liner as to avoid being disruptive
(while still offering condensed feedback, which often is enough).
DATA is the error; FUN is where it occurred.
The errors are logged in the buffer `error-buffer-name'.
To list them, use `errors'.
To use this function, set `command-error-function' to:
\(lambda \(&rest args\) \(apply #'say-and-log-error args\)"
  (if (not (member (car data) debug-ignored-errors))
      (let*((error-str (format "%S in %S" data fun))
            (error-buffer (get-buffer-create error-buffer-name))
            (error-win (get-buffer-window error-buffer)) )
        (message "%s" error-str)           ; echo the error message
        (with-current-buffer error-buffer
          (goto-char (point-max))
          (insert error-str "\n") )        ; log it
        (discard-input) )))

(setq command-error-function
      (lambda (&rest args)
        (apply #'say-and-log-error args) ))

(defun errors ()
  "Visit the errors log buffer, `error-buffer-name'.
See `say-and-log-error' for more on this."
  (interactive)
  (switch-to-buffer (get-buffer-create error-buffer-name))
  (goto-char (point-max))
  (recenter -1) )






(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#3f3f3f" "#ea3838" "#7fb07f" "#fe8b04" "#62b6ea" "#e353b9" "#1fb3b3" "#d5d2be"])
 '(custom-enabled-themes (quote (alect-black)))
 '(custom-safe-themes
   (quote
    ("a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "ab04c00a7e48ad784b52f34aa6bfa1e80d0c3fcacc50e1189af3651013eb0d58" "04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" "7356632cebc6a11a87bc5fcffaa49bae528026a78637acd03cae57c091afd9b9" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "65d9573b64ec94844f95e6055fe7a82451215f551c45275ca5b78653d505bc42" "2b6bd2ebad907ee42b3ffefa4831f348e3652ea8245570cdda67f0034f07db93" default)))
 '(diary-entry-marker (quote font-lock-variable-name-face))
 '(emms-mode-line-icon-image-cache
   (quote
    (image :type xpm :ascent center :data "/* XPM */
static char *note[] = {
/* width height num_colors chars_per_pixel */
\"    10   11        2            1\",
/* colors */
\". c #1fb3b3\",
\"# c None s None\",
/* pixels */
\"###...####\",
\"###.#...##\",
\"###.###...\",
\"###.#####.\",
\"###.#####.\",
\"#...#####.\",
\"....#####.\",
\"#..######.\",
\"#######...\",
\"######....\",
\"#######..#\" };")))
 '(fci-rule-color "#222222")
 '(gnus-logo-colors (quote ("#2fdbde" "#c0c0c0")))
 '(gnus-mode-line-image-cache
   (quote
    (image :type xpm :ascent center :data "/* XPM */
static char *gnus-pointer[] = {
/* width height num_colors chars_per_pixel */
\"    18    13        2            1\",
/* colors */
\". c #1fb3b3\",
\"# c None s None\",
/* pixels */
\"##################\",
\"######..##..######\",
\"#####........#####\",
\"#.##.##..##...####\",
\"#...####.###...##.\",
\"#..###.######.....\",
\"#####.########...#\",
\"###########.######\",
\"####.###.#..######\",
\"######..###.######\",
\"###....####.######\",
\"###..######.######\",
\"###########.######\" };")))
 '(org-agenda-files (quote ("~/notes/orgmode.org")))
 '(package-selected-packages
   (quote
    (fish-mode sublimity web-mode use-package restart-emacs rainbow-delimiters racer projectile powerline pallet multi-term magit kotlin-mode jedi jdee indium helm-ls-git gruvbox-theme groovy-mode gradle-mode go-guru go-eldoc git-gutter flycheck-rust exec-path-from-shell evil-surround evil-leader elpy company-jedi company-go cargo)))
 '(projectile-mode t nil (projectile))
 '(vc-annotate-background "#222222")
 '(vc-annotate-color-map
   (quote
    ((20 . "#db4334")
     (40 . "#ea3838")
     (60 . "#abab3a")
     (80 . "#e5c900")
     (100 . "#fe8b04")
     (120 . "#e8e815")
     (140 . "#3cb370")
     (160 . "#099709")
     (180 . "#7fb07f")
     (200 . "#32cd32")
     (220 . "#8ce096")
     (240 . "#528d8d")
     (260 . "#1fb3b3")
     (280 . "#0c8782")
     (300 . "#30a5f5")
     (320 . "#62b6ea")
     (340 . "#94bff3")
     (360 . "#e353b9"))))
 '(vc-annotate-very-old-color "#e353b9"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
