(require 'init-elpa)

(use-package groovy-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.gradle\\'" . groovy-mode)))

(use-package gradle-mode
  :ensure t
  :config
  (add-hook 'java-mode-hook 'gradle-mode)
  (add-hook 'groovy-mode-hook 'gradle-mode)
  (add-hook 'kotlin-mode-hook 'gradle-mode))

(provide 'cov-groovy)
