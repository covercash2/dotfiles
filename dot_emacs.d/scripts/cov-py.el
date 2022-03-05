;;; cov-py --- Summary:
;;; python settings
;;; Commentary:
;;; use elpy to extend python functions
;;; Code:

(require 'use-package)

(use-package company-jedi
  :ensure t)

(use-package elpy
  :ensure t
  :init (elpy-enable)
  :config
  (setenv "WORKON_HOME" "~/anaconda3/envs/"))

(use-package lsp-pyright
  :ensure t
  :requires lsp)

(defun cov-python-mode-hook ()
  "Python hooks."
  (require 'lsp-pyright)
  (require 'company)
  (add-to-list 'company-backends 'company-jedi)
  (lsp)
)

(add-hook 'python-mode #'cov-python-mode-hook)

(provide 'cov-py)
;;; cov-py.el ends here
