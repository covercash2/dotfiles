(require 'init-elpa)
(require-package 'evil)
(require 'evil)

(evil-mode 1)

(define-key evil-normal-state-map "," 'helm-M-x)

(provide 'init-evil)
