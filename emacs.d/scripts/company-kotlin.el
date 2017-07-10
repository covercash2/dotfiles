;;; Code:
(require 'cl-lib)
(require 'company)

(defun company-kotlin-backend (command &optional arg &rest ignored)
  "A company backend for Kotlin."
  (interactive (list 'interactive))

  (cl-case command
    (interactive (company-begin-backend 'company-kotlin-backend))
    (prefix (and (eq major-mode 'kotlin-mode)
		 (company-grab-symbol)))
    (candidates
     (cl-remove-if-not
      (lambda (c) (string-prefix-p arg c))
      kotlin-mode--keywords))))

(add-to-list 'company-backends 'company-kotlin-backend)

(provide 'company-kotlin)
;;; company-kotlin.el ends here
