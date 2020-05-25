;;; package --- defines keybindings
;; describes keybindings and configures evil mode

;;; Commentary:
;; this file replaces my init-editor file.  i think it's a little less ambiguous
;; and i moved some visual elements to the main init.el for now.

;;; Code:

(require 'use-package)

(use-package evil
  :ensure t
  :config
  (evil-set-leader '(normal visual) (kbd "<SPC>"))
  (use-package evil-surround
    :ensure t
    :init (global-evil-surround-mode))
  ;; (use-package evil-magit
  ;;   :requires magit)
  (use-package evil-collection
    :ensure t
    :config
    (setq evil-want-keybinding nil)
    (evil-collection-init))
  (evil-mode 1)
  )

(use-package hydra
  :ensure t
  :requires evil
  :config
  ; TODO replace broken dependencies and customize docstring
  (defhydra hydra-window ()
    "
Movement^^        ^Split^         ^Switch^		^Resize^
----------------------------------------------------------------
_h_ ←       	_v_ertical    	_b_uffer		_q_ X←
_j_ ↓        	_x_ horizontal	_f_ind files	_w_ X↓
_k_ ↑        	_z_ undo      	_a_ce 1		_e_ X↑
_l_ →        	_Z_ reset      	_s_wap		_r_ X→
_F_ollow		_D_lt Other   	_S_ave		max_i_mize
_SPC_ cancel	_o_nly this   	_d_elete
"
    ("h" windmove-left )
    ("j" windmove-down )
    ("k" windmove-up )
    ("l" windmove-right )
    ("q" hydra-move-splitter-left)
    ("w" hydra-move-splitter-down)
    ("e" hydra-move-splitter-up)
    ("r" hydra-move-splitter-right)
    ("b" helm-mini)
    ("f" helm-find-files)
    ("F" follow-mode)
    ("a" (lambda ()
	   (interactive)
	   (ace-window 1)
	   (add-hook 'ace-window-end-once-hook
		     'hydra-window/body))
     )
    ("v" (lambda ()
	   (interactive)
	   (split-window-right)
	   (windmove-right))
     )
    ("x" (lambda ()
	   (interactive)
	   (split-window-below)
	   (windmove-down))
     )
    ("s" (lambda ()
	   (interactive)
	   (ace-window 4)
	   (add-hook 'ace-window-end-once-hook
		     'hydra-window/body)))
    ("S" save-buffer)
    ("d" delete-window)
    ("D" (lambda ()
	   (interactive)
	   (ace-window 16)
	   (add-hook 'ace-window-end-once-hook
		     'hydra-window/body))
     )
    ("o" delete-other-windows)
    ("i" ace-maximize-window)
    ("z" (progn
	   (winner-undo)
	   (setq this-command 'winner-undo))
     )
    ("Z" winner-redo)
    ("SPC" nil)
    )

  (defhydra hydra-lsp (:exit t :hint nil)
    "
lsp
  buffer^^                  ^symbol^            server^^
--------------------------------------------------------------------
  _f_ormat                  _d_efinition        _C-r_estart
  e_x_ecute code action     _r_eferences        _C-d_escribe session
  i_m_enu                   _i_mplementations
                          _R_ename
"
    ("f" lsp-format-buffer)
    ("x" lsp-execute-code-action)
    ("d" lsp-ui-peek-find-definition)
    ("r" lsp-ui-peek-find-references)
    ("i" lsp-ui-peek-find-implementation)
    ("R" lsp-rename)
    ("m" lsp-ui-imenu)
    ("C-r" lsp-restart-workspace)
    ("C-d" lsp-describe-session)
    )

  (defhydra hydra-project (:exit t :hint nil)
    "
project
 compile^^    navigation^^
---------------
 _b_uild      _f_ind file
 _r_un
 _t_est
"
    ("f" projectile-find-file)
    ("t" projectile-test-project)
    ("r" projectile-run-project)
    ("b" projectile-compile-project))

  (defhydra hydra-leader
    (:exit t :hint nil)
    "
main menu
 buffer^^      ^navigate^          ^command^              ^code^
------------------------------------------------------------------------
 _s_ave        _b_uffer list       _<SPC>_ M-x run        _g_it status
 _f_ind file   _p_roject hydra     ^^                     _l_sp hydra
 ^^            _n_eotree
 ^^            _w_indow hydra

_<ESC>_, _C-[_, _C-g_: cancel
"
    ("s" save-buffer :color red)
    ("b" helm-buffers-list)
    ; projectile
    ("f" projectile-find-file)
    ("p" hydra-project/body)
    ; TODO hydra-magit
    ("g" magit-status)
    ("I" cov-edit-init)
    ; TODO explore treemacs
    ("n" neotree-toggle :color red)
    ; lsp
    ("l" hydra-lsp/body)
    ("<SPC>" helm-M-x)
    ("w" hydra-window/body)
    ("C-g" nil)
    ("<ESC>" nil)
    ("C-[" nil))

  (evil-define-key '(normal visual) 'global (kbd "<SPC>") 'hydra-leader/body)

  (evil-define-key 'normal 'global (kbd "C-w") 'hydra-window/body)
  )

(provide 'cov-keybind)
;;; cov-keybind.el ends here
