;;; chezmoi.el --- chezmoi management
;;; Commentary:
;;; Some simple commands for working with chezmoi.
;;; Code:

(defconst chezmoi-output-buffer-name "*chezmoi output*")

(defun chezmoi-edit (file)
  "Edit a file managed by chezmoi.
This function should work just like `chezmoi edit'
FILE points to the destination file."
  (interactive "fConfig file: ")
  (let ((chezmoi-file
	 (string-trim ; requires emacs 24.4
	  (shell-command-to-string
	   (concat "chezmoi source-path " file)))))
    (cond ((file-exists-p chezmoi-file)
	   (find-file chezmoi-file))
	  (t (error "Unable to find source config file: %s" chezmoi-file)))
    ))

(defun chezmoi-apply ()
  "Apply chezmoi config."
  (interactive)
  (start-process "chezmoi apply"
		 chezmoi-output-buffer-name
		 "chezmoi" "apply" "--verbose"))

(defun chezmoi-apply-dry-run ()
  "Show configuration changes in the chezmoi output buffer."
  (interactive)
  (start-process "chezmoi apply dry run"
		 chezmoi-output-buffer-name
		 "chezmoi" "apply" "--dry-run" "--verbose"))

(provide 'chezmoi)
;;; chezmoi.el ends here
