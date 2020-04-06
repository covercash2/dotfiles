;;; package --- defines keybindings
;; describes keybindings and configures evil mode

;;; Commentary:
;; this file replaces my init-editor file.  i think it's a little less ambiguous
;; and i moved some visual elements to the main init.el for now.

;;; Code:

(require 'use-package)

(defun cov--config-evil-leader ()
  "Config leader keys etc."
  (evil-leader/set-leader ",")
  (evil-leader/set-key
    "." 'golden-ratio
    "b" 'helm-buffers-list
    "E" 'eval-buffer
    "f" 'projectile-find-file
    "g" 'magit-status
    "I" 'cov-edit-init
    "n" 'neotree-toggle
    "o" 'projectile-find-file-other-window
    "p" 'projectile-switch-project
    "t" 'multi-term-dedicated-toggle
    "x" 'helm-M-x
    ))

(defun cov--config-evil ()
  "Config evil mode states and keybindings."
  ;; configure terminals
  (delete 'multi-term evil-insert-state-modes)
  (delete 'eshell-mode evil-insert-state-modes))

(use-package evil
  :config
  (use-package evil-leader
    :init (global-evil-leader-mode)
    :config (cov--config-evil-leader))
  (use-package evil-surround
    :init (global-evil-surround-mode))
  (use-package evil-magit)
  (cov--config-evil)
  (evil-mode 1)
  )

(add-hook 'evil-mode-hook 'cov--config-evil)

(provide 'cov-keybind)
;;; cov-keybind.el ends here
