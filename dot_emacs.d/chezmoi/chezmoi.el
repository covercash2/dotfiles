;;; chezmoi.el --- chezmoi management
;;; Commentary:
;;; Some simple commands for working with chezmoi.
;;; Code:

(defun chezmoi-edit (file)
  "Edit a file managed by chezmoi.
This function should work just like `chezmoi edit'
FILE points to the destination file."
  (interactive "fConfig file: ")
  (let ((chezmoi-file
	 (string-trim
	  (shell-command-to-string
	   (concat "chezmoi source-path " file)))))
    (cond ((file-exists-p chezmoi-file)
	   (find-file chezmoi-file))
	  (t (error "Unable to find source config file: %s" chezmoi-file)))
    ))

(provide 'chezmoi)
;;; chezmoi.el ends here
