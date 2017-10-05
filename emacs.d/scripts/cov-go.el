;;; cov-go: --- Summary:
;;; configurations for go development
;;; 
;;; Commentary:
;;;
;;; Code:

(setenv "GOPATH" (concat (getenv "HOME") "/code/go"))

;; TODO come up with something better
;; make sure the go/bin directory is in the PATH
(setenv "PATH" (concat (getenv "PATH") (concat ":" (concat (getenv "GOPATH") "/bin"))))

(require 'go-mode)
(require 'company)
(require 'company-go)
(require 'go-eldoc)

(defun cov--go-mode-hook()
  (go-eldoc-setup)
  (add-hook 'before-save-hook 'gofmt-before-save)
  (setq tab-width 4)
  (set (make-local-variable 'company-backends) '(company-go))
  (go-guru-hl-identifier-mode))

(add-hook 'go-mode-hook 'cov--go-mode-hook)

(set-face-foreground 'font-lock-comment-face "light green")

(provide 'cov-go)
;;; cov-go.el ends here
