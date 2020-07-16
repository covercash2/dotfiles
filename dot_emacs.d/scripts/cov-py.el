;;; cov-py --- Summary:
;;; python settings
;;; Commentary:
;;; use elpy to extend python functions
;;; Code:

(require 'jedi)
(jedi:setup)
(setq jedi:complete-on-dot t)

(require 'company-jedi)
(add-to-list 'company-backends 'company-jedi)

(require 'elpy)
(add-hook 'python-mode #'elpy-enable)

;; workaround for python repl bug. should be fixed in 25.2
(with-eval-after-load 'python
  (defun python-shell-completion-native-try ()
    "Return non-nil if can trigger native completion."
    (let ((python-shell-completion-native-enable t)
	  (python-shell-completion-native-output-timeout
	   python-shell-completion-native-try-output-timeout))
      (python-shell-completion-native-get-completions
       (get-buffer-process (current-buffer))
       nil "_"))))

(provide 'cov-py)
;;; cov-py.el ends here
