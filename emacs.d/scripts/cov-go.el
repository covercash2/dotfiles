;;; cov-go: --- Summary:
;;; configurations for go development
;;; 
;;; Commentary:
;;;
;;; Code:

(setenv "GOPATH" (concat (getenv "HOME") "/code/go"))

(require 'company)
(require 'go-mode)
(require 'go-eldoc)

(defun cov--go-mode-hook()
  (add-hook 'go-mode-hook 'go-eldoc-setup)
  (add-hook 'before-save-hook 'gofmt-before-save)
  (set (make-local-variable 'company-backends) '(company-go))
  (setq tab-width 4)
  (go-guru-hl-identifier-mode))

(add-hook 'go-mode-hook 'cov--go-mode-hook)

(provide 'cov-go)
;;; cov-go.el ends here
