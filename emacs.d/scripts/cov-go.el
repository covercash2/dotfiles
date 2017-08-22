;; golang config

(require 'go-mode)

;; configure eldoc
(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

;; format on save
(add-hook 'before-save-hook 'gofmt-before-save)

(defun cov-go-mode-hook()
  (add-hook 'before-save-hook 'gofmt-before-save)
  (set (make-local-variable 'company-backends) '(company-go))
  (setq tab-width 4)
  (go-guru-hl-identifier-mode))

(setenv "GOPATH" (concat (getenv "HOME") "/code/go"))

(provide 'cov-go)
