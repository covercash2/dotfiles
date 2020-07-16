;;; cov-py --- Summary:
;;; Commentary:
;;; Code:
(require 'package)

(defun require-package (package)
  "Install PACKAGE if not installed."
  (if (package-installed-p package)
      t
    (progn
      (unless (assoc package package-archive-contents)
	(package-refresh-contents))
      (package-install package))))

(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))

(package-initialize)

(provide 'init-elpa)
