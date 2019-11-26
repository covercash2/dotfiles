;;; package --- defines keybindings
;; describes keybindings and configures evil mode

;;; Commentary:
;; this file replaces my init-editor file.  i think it's a little less ambiguous
;; and i moved some visual elements to the main init.el for now.

;;; Code:

(require 'use-package)

(use-package evil)
(use-package evil-leader
  :requires evil)
(use-package evil-surround
  :requires evil)

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
  (cov--config-evil-leader)
  ;; configure terminals
  (delete 'multi-term evil-insert-state-modes)
  (delete 'eshell-mode evil-insert-state-modes)
  ;; enable evil modes
  (global-evil-leader-mode)
  (global-evil-surround-mode))

(add-hook 'evil-mode-hook 'cov--config-evil)

(evil-mode 1)

;; (use-package evil
;;   :ensure t
;;   :config
;;   (add-hook 'evil-mode-hook 'cov--config-evil)
;;   (evil-mode 1)
;;   (use-package evil-leader
;;     :ensure t
;;     :config
;;     (global-evil-leader-mode)
;;     (cov--config-evil-leader))
;;   (use-package evil-surround
;;     :ensure t
;;     :config
;;     (global-evil-surround-mode)))

(provide 'cov-keybind)
;;; cov-keybind.el ends here
