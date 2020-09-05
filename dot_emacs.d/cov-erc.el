;;; cov-erc.el --- Summary
;;; Commentary:
;;;
;;; Code:

(defconst cov-default-nick {{ (keepassxc "irc.rizon.net").UserName }})
(defconst cov-default-nick-password
  {{ (keepassxc "irc.rizon.net").Password }})

(erc-tls
 :server "irc.rizon.net"
 :port 6697
 :nick 'cov-default-nick
 )

(provide 'cov-erc)
;;; cov-erc.el ends here
