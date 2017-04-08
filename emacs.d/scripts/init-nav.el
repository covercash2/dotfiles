(require 'init-elpa)
(require 'recentf)
(require-package 'helm)
(require-package 'helm-ls-git)
(require-package 'projectile)

(require 'helm-config)

(setq recentf-save-file (concat user-emacs-directory ".recentf"))
(recentf-mode 1)
(setq recentf-max-menu-items 40)

(global-set-key (kbd "M-x") 'helm-M-x)
(helm-mode 1)

(projectile-global-mode)

(provide 'init-nav)
