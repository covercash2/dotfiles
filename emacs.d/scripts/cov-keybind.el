;;; package --- defines keybindings
;; describes keybindings and configures evil mode

;;; Commentary:
;; this file replaces my init-editor file.  i think it's a little less ambiguous
;; and i moved some visual elements to the main init.el for now.

;;; Code:

(require 'use-package)

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (use-package evil-surround
    :ensure t
    :init (global-evil-surround-mode))
  ;; (use-package evil-magit
  ;;   :requires magit)
  (use-package evil-collection
    :ensure t
    :custom (evil-collection-setup-minibuffer t)
    :init
    (evil-collection-init)
    :config)
  (evil-mode 1)
  )

(use-package hydra
  :ensure t
  :requires evil
  :config
  ; TODO replace broken dependencies and customize docstring
  (defhydra hydra-window (:hint nil)
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
    ("SPC" hydra-leader/body :color blue)
    )

  (defhydra hydra-lsp (:exit t :hint nil)
    "
lsp
  buffer^^                  ^symbol^            server^^
--------------------------------------------------------------------
  _f_ormat                  _d_efinition        _C-d_escribe session
  i_m_enu                   _i_mplementations   _C-r_estart
  e_x_ecute code action     _r_eferences
  ^^                        _R_ename
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
 ^compile^    ^navigation^      ^env^
------------------------------------------
 _b_uild      _f_ind file       _c_hange project
 _r_un        _s_earch          _k_ill buffers
 _t_est       ^^                _R_ecent files
"
    ("k" projectile-kill-buffers)
    ("R" projectile-recentf)
    ("c" projectile-switch-project)
    ("s" projectile-ag)
    ("f" projectile-find-file)
    ("t" projectile-test-project)
    ("r" projectile-run-project)
    ("b" projectile-compile-project))

  (defhydra hydra-lint (:color red :hint nil)
    "
lint
 ^navigate^
------------
 _j_,_k_ next/prev
 _gg_ first

_q_: cancel
"
    ("gg" flycheck-first-error)
    ("f" flycheck-error-list-set-filter)
    ("j" flycheck-next-error)
    ("k" flycheck-previos-error)
    ("q" nil :color blue)
    )

  (defhydra hydra-debug (:color red :hint nil)
    "
gud
 ^execution^     ^control^            ^inspect^       ^breakpoints^
--------------------------------------------------------------
  _S_tart gdb    _c_ontinue           _p_rint         _b_reakpoint insert
  _r_un          _s_tep               _v_iew change   _B_reakpoint delete
  _f_inish       _n_ext line
  ^^             _i_nstruction step
"
    ("v" gdb-many-windows)
    ("S" gdb)
    ("B" gud-remove)
    ("b" gud-break)
    ("f" gud-finish)
    ("c" gud-cont)
    ("p" gud-print)
    ("n" gud-next)
    ("s" gud-step)
    ("i" gud-stepi)
    ("r" gud-run))

  (defhydra hydra-yas
    (:color teal :hint nil)
    "
yasnippets
_i_nsert  _n_ew  _r_eload
"
    ("r" yas-reload-all)
    ("i" yas-insert-snippet)
    ("n" yas-new-snippet))

  (defhydra hydra-org (:color blue :hint nil)
    "
org mode
  ^todo^      ^headers^          ^links^
--------------------------------------------------------------
  _t_oggle    _h_eader           _l_ink insert      _y_asnippets
              _s_ubheader
              _H_eader todo
              _S_ubheader todo
"
    ("t" org-todo :exit nil)
    ("y" hydra-yas/body)
    ("l" org-insert-link)
    ("h" org-insert-heading)
    ("s" org-insert-subheading)
    ("H" org-insert-todo-heading)
    ("S" org-insert-todo-subheading))

  (defhydra hydra-leader
    (:exit t :hint nil)
    "
main menu
 buffer^^       ^navigate^          ^command^              ^code^
-------------------------------------------------------------------------
 _f_ind file    _b_uffer list       _<SPC>_ M-x run        _g_it status
 _s_ave         _n_eotree           _e_val expression      _l_sp hydra
 _y_asnippet    _p_roject hydra     ^^                     _C-l_int
 ^^             _w_indow hydra      ^^                     _d_ebug

_<ESC>_, _C-[_, _C-g_: cancel
"
    ("e" eval-expression)
    ("y" hydra-yas/body)
    ("d" hydra-debug/body)
    ("C-l" hydra-lint/body)
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

  (evil-define-key '(normal visual) 'global (kbd "C-w") 'hydra-window/body)

  (evil-define-key '(normal) 'org-mode-map (kbd "C-<SPC>") 'hydra-org/body)
  )

(provide 'cov-keybind)
;;; cov-keybind.el ends here
