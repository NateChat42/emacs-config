(require 'package) ;; NOTE: try https if M-x package-install doesn't work, or try M-x package-refresh-contents. It might take some time, but be patient
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("marmalade" . "http://marmalade-repo.org/packages/")
	("melpa" . "http://melpa.org/packages/")
        ("org" . "http://orgmode.org/elpa/")
        ("melpa-stable" . "http://stable.melpa.org/packages/")))
(package-initialize)
;(package-install 'bind-key)
(package-install 'use-package)

(eval-when-compile
  (require 'use-package))
(require 'bind-key)

(setq byte-compile-warnings '(cl-functions))


;; Prevent undo tree files from polluting your git repo
(setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))

(setq visible-bell t)
;; store back-up files in a temporary directory instead of leaving emacs-droppings
(setq temporary-file-directory "~/.emacs.d/temporary_files")
(setq backup-directory-alist (quote ((".*" . "~/.emacs.d/temporary_files"))));; Make sure this directory exists

;; MAC fix below for clojure, but shouldn't hurt any other system.
(setenv "PATH"

        (concat

         (getenv "PATH") ":usr/local/bin"))

(setq exec-path (append exec-path '("/usr/local/bin")))

(set-face-attribute 'default nil :height 150)

;;;;;;;;;;;;;;;;;;;;;;;;
;; BASIC KEY BINDINGS ;;
;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [f5] 'toggle-truncate-lines) ;; Linewrap?
(global-set-key [f6] 'global-hl-line-mode) ;; Highlight current line
(global-set-key [f7] 'linum-mode) ;; Line Numbers in margin
(global-set-key [C-f7] 'toggle-scroll-bar) ;; Toggle scroll bar 
(global-set-key [s-f11] 'toggle-frame-fullscreen)
(global-set-key (kbd "C-x C-d") 'dired) ;; so dired is both C-x C-d and C-x d
(global-set-key (kbd "C-x C-q") 'view-mode) ;; view mode
(global-set-key (kbd "M-C-;") 'comment-box)
(global-set-key (kbd "C-x M-w") 'windmove-swap-states-up)    ;; moves current buffer one up
(global-set-key (kbd "C-x M-a") 'windmove-swap-states-left)  ;; moves current buffer one left
(global-set-key (kbd "C-x M-s") 'windmove-swap-states-down)  ;; moves current buffer one down
(global-set-key (kbd "C-x M-d") 'windmove-swap-states-right) ;; moves current buffer one right
(global-linum-mode 1) ;; always show line numbers
(menu-bar-mode -1) ;; turn off menu
(tool-bar-mode -1) ;; turn off toolbar
(setq mouse-wheel-scroll-amount '(2 ((shift) .2))) ;; makes mouse less jumpy
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window that mouse hovers over
(setq scroll-step 2) ;; keyboard scroll one line at a time
(setq initial-scratch-message "")
(setq inhibit-startup-message t)

;;;;;;;;;;;;;;;;;;;
;; PACKAGE SETUP ;;
;;;;;;;;;;;;;;;;;;;
(use-package ace-popup-menu
  :ensure t
  :config
  (ace-popup-menu-mode 1))

(use-package ace-jump-mode
  :ensure t
  :bind (("C-c SPC" . ace-jump-mode))
  :config
  (setq ace-jump-mode-case-fold nil  ;; case sensitive
        ace-isearch-use-function-from-isearch nil)
  (global-ace-isearch-mode +1)
  (setq ace-jump-mode-submode-list '(ace-jump-line-mode ace-jump-char-mode ace-jump-word-mode) ;; complementary to ace-isearch
        ace-jump-mode-scope 'frame))

(use-package ace-isearch
  :ensure t
  :demand t
  :delight ace-isearch-mode
  :config
  (setq  ace-isearch-input-idle-delay 0.2
         ace-isearch-input-length 9
         ace-isearch-use-ace-jump (quote printing-char)
         ace-isearch-function 'ace-jump-word-mode
         ace-isearch-use-jump (quote printing-char)))

(use-package ace-jump-zap
  :ensure t
  :bind (("M-z" . ace-jump-zap-to-char))
  :config
  (setq ajz/zap-function 'kill-region))

(use-package anzu
  :ensure t
  :delight anzu-mode
  :config (global-anzu-mode 1)
  (setq anzu-minimum-input-length 4))

(use-package cider-hydra
  :ensure t)

(use-package clojure-mode
  :ensure t
  :init
  (use-package flycheck-joker :ensure t)

  :config
  (defun my-clojure-mode-hook () 
    (highlight-phrase "TODO" 'web-mode-comment-keyword-face) ;; TODO add a correct face that doesn't depend on web-mode
    ;(clj-refactor-mode 1)
    (yas-minor-mode 1))
  (add-hook 'clojure-mode-hook #'my-clojure-mode-hook)
  (add-hook 'clojure-mode-hook 'flycheck-mode)
  (use-package flycheck-clj-kondo :ensure t
    :config
    (dolist (checkers '((clj-kondo-clj . clojure-joker)
                    (clj-kondo-cljs . clojurescript-joker)
                    (clj-kondo-cljc . clojure-joker)))
      (flycheck-add-next-checker (car checkers) (cons 'error (cdr checkers))))))

(use-package clojure-mode-extra-font-locking
  :requires clojure-mode
  :ensure t)

(use-package company
  :ensure t
  :bind (("TAB" . company-indent-or-complete-common))
  :defer t
  :config
  (global-company-mode)
  (use-package "helm-company")
  (define-key company-mode-map (kbd "C-:") 'helm-company)
  (define-key company-active-map (kbd "C-:") 'helm-company)
  (setq company-idle-delay 0.3))

;; (use-package company-quickhelp
;;   :ensure pos-tip
;;   :config
;;   (company-quickhelp-mode 1)
;;   (setq company-quickhelp-delay 0.5))

(use-package dired-filter
  :ensure t)
(use-package dired-subtree
  :ensure t)
(use-package dired-narrow
  :ensure t
  :config 
  (bind-keys
   :map dired-mode-map
   ("C-c n" . dired-narrow)))

(use-package helm
  :ensure t
  :bind (("C-c h" . helm-command-prefix)
         ("M-y" . helm-show-kill-ring)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-mini)
         ("C-h z" . helm-resume)
         ("M-x" . helm-M-x))

  :config
  (use-package helm-config)
  (use-package helm-files)
  (use-package helm-grep)
  (global-unset-key (kbd "C-x c"))
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to do persistent action
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
  (define-key helm-find-files-map (kbd "C-c x")  'helm-ff-run-open-file-with-default-tool)
  (define-key helm-find-files-map (kbd "C-c C-x")  'helm-ff-run-open-file-with-default-tool)
  (define-key helm-find-files-map (kbd "C-c X")  'helm-ff-run-open-file-externally)
  (define-key helm-grep-mode-map (kbd "<return>")  'helm-grep-mode-jump-other-window)
  (define-key helm-grep-mode-map (kbd "n")  'helm-grep-mode-jump-other-window-forward)
  (define-key helm-grep-mode-map (kbd "p")  'helm-grep-mode-jump-other-window-backward)
  (when (executable-find "curl")
    (setq helm-google-suggest-use-curl-p t))
  (setq helm-quick-update                     t ; do not display invisible candidates
      helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)
  (helm-mode 1)
  (use-package helm-descbinds :ensure t
    :config
    (global-set-key (kbd "C-h k") 'helm-descbinds)) ;; great way to find keys
(eval-after-load "winner"
  '(progn 
    (add-to-list 'winner-boring-buffers "*helm M-x*")
    (add-to-list 'winner-boring-buffers "*helm mini*")
    (add-to-list 'winner-boring-buffers "*Helm Completions*")
    (add-to-list 'winner-boring-buffers "*Helm Find Files*")
    (add-to-list 'winner-boring-buffers "*helm mu*")
    (add-to-list 'winner-boring-buffers "*helm mu contacts*")
    (add-to-list 'winner-boring-buffers "*helm-mode-describe-variable*")
    (add-to-list 'winner-boring-buffers "*helm-mode-describe-function*"))))

(use-package hydra
  :ensure t
  :config
  
  (require 'windmove) ; also already added in my emacs-el
  (defun hydra-move-splitter-left (arg)
    "Move window splitter left."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'right))
        (shrink-window-horizontally arg)
      (enlarge-window-horizontally arg)))
  
  (defun hydra-move-splitter-right (arg)
    "Move window splitter right."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'right))
        (enlarge-window-horizontally arg)
      (shrink-window-horizontally arg)))
  
  (defun hydra-move-splitter-up (arg)
    "Move window splitter up."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'up))
        (enlarge-window arg)
      (shrink-window arg)))
  
  (defun hydra-move-splitter-down (arg)
    "Move window splitter down."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'up))
        (shrink-window arg)
      (enlarge-window arg)))
  
  
  (global-set-key [C-up] 'enlarge-window)
  (global-set-key [C-down] (lambda () (interactive)
                             (enlarge-window -1)))
  
  (bind-key* "C-M-o"
             (defhydra hydra-window ()
               "
Movement^^        ^Split^         ^Switch^		^Resize^
----------------------------------------------------------------
_h_ ←       	_v_ertical    	_b_uffer		_q_ X←
_j_ ↓        	_x_ horizontal	_f_ind files	_w_ X↓
_k_ ↑        	_z_ undo      	_a_ce 1		_e_ X↑
_l_ →        	_Z_ redo      	_s_wap		_r_ X→
_F_ollow		_D_lt Other   	_S_ave		max_i_mize
_SPC_ cancel	_o_nly this   	_d_elete	
_,_ Scroll←			_p_roject
_._ Scroll→
"
               ("h" windmove-left )
               ("C-h"  windmove-left )
               ("j" windmove-down )
               ("C-j"  windmove-down )
               ("k" windmove-up )
               ("C-k"  windmove-up )
               ("l" windmove-right )
               ("C-l"  windmove-right )
               ("q" hydra-move-splitter-left)
               ("C-q"  hydra-move-splitter-left)
               ("w" hydra-move-splitter-down)
               ("C-w"  hydra-move-splitter-down)
               ("e" hydra-move-splitter-up)
               ("C-e"  hydra-move-splitter-up)
               ("r" hydra-move-splitter-right)
               ("C-r"  hydra-move-splitter-right)
               ("b" helm-mini)
               ("C-b"  helm-mini)
               ("f" helm-find-files)
	       ("g" helm-projectile-grep :color blue)
               ("C-f"  helm-find-files)
               ("p" helm-projectile)
               ("C-p"  helm-projectile)
               ("F" follow-mode)
               ("C-F"  follow-mode)
               ("a" hydra-ace-cmd)
               ("C-a"  hydra-ace-cmd)
               ("v" hydra-split-vertical)
               ("C-v"  hydra-split-vertical)
               ("x" hydra-split-horizontal)
               ("C-x"  hydra-split-horizontal)
               ("s" hydra-swap)
               ("C-s"  hydra-swap)
               ("S" save-buffer)
               ("C-S"  save-buffer)
               ("d" delete-window)
               ("C-d"  delete-window)
               ("D" hydra-del-window)
               ("C-D"  hydra-del-window)
               ("o" delete-other-windows)
               ("C-o"  delete-other-windows)
               ("i" ace-maximize-window)
               ("C-i"  ace-maximize-window)
               ("z" (progn
                      (winner-undo)
                      (setq this-command 'winner-undo)))
               ("C-z" (progn
                        (winner-undo)
                        (setq this-command 'winner-undo)))
               ("Z" winner-redo)
               ("C-Z"  winner-redo)
               ("SPC" nil)
               ("C-SPC"  nil)
               ("." scroll-left)
               ("," scroll-right)))
  
  (global-set-key
   (kbd "M-g")
   (defhydra hydra-goto ()
     "Go To"
     ("g" goto-line "line") ; reserve for normal M-g g function (may be different in some modes)
     ("M-g" goto-line "line")
     ("TAB" move-to-column "col")
     ("a" ace-jump-mode "ace line")
     ("c" goto-char "char")
     ("n" next-error "next err")
     ("p" previous-error "prev err")
     ("r" anzu-query-replace "qrep")
     ("R" anzu-query-replace-regexp "rep regex")
     ("t" anzu-query-replace-at-cursor "rep cursor")
     ("T" anzu-query-replace-at-cursor-thing "rep cursor thing")
     ("," scroll-right "scroll leftward")
     ("." scroll-left "scroll rightward")
     ("[" backward-page "back page")
     ("]" forward-page "forward page")
     ("SPC" nil "cancel"))))

(use-package ibuffer
  :bind (("C-x C-b" . ibuffer))
  :config (autoload 'ibuffer "ibuffer" "List buffers." t))

(use-package ivy
  :ensure t)

(use-package uuidgen
  :ensure t)

(use-package magit
  :ensure t
  :config
  ;;(global-magit-file-mode)
  (global-set-key "\C-xg" 'magit-status)
  (setq magit-diff-use-overlays nil))

(use-package company-quickhelp
  :ensure pos-tip
  :config
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))

(use-package smartparens-config
  :ensure smartparens
  :demand t
  :config
  (show-smartparens-global-mode)
  (sp-use-paredit-bindings)
  (add-hook 'emacs-lisp-mode-hook 'turn-on-smartparens-strict-mode)
  (add-hook 'clojure-mode-hook 'turn-on-smartparens-strict-mode)
  (add-hook 'cider-repl-mode-hook #'turn-on-smartparens-strict-mode)
  (bind-keys
   :map smartparens-strict-mode-map
   (";" . sp-comment)
   ("M-f" . sp-forward-symbol)
   ("M-b" . sp-backward-symbol)
   ("M-a" . sp-beginning-of-sexp)
   ("M-e" . sp-end-of-sexp)))

(use-package paren
  :config
  (show-paren-mode 1))

(use-package projectile
  :ensure t
  :config
  (use-package helm-projectile :ensure t)
  (projectile-global-mode)
  (setq projectile-completion-system 'helm
        projectile-switch-project-action 'helm-projectile)
  (setq projectile-globally-ignored-directories
        (cl-union projectile-globally-ignored-directories
                  '(".git"
                    ".cljs_rhino_repl"
                    ".cpcache"
                    ".meghanada"
                    ".shadow-cljs"
                    ".svn"
                    "cljs-runtime"
                    "node_modules"
                    "out"
                    "repl"
                    "resources/public/js/compiled"
                    "target"
                    "venv")))
  (setq projectile-globally-ignored-files
        (cl-union projectile-globally-ignored-files
                  '(".DS_Store"
                    ".lein-repl-history"
		    "*.css"
                    "*.gz"
                    "*.pyc"
                    "*.png"
                    "*.jpg"
                    "*.jar"
                    "*.js"
                    "*.retry"
                    "*.svg"
                    "*.tar.gz"
                    "*.tgz"
                    "*.zip")))
  (define-key projectile-command-map (kbd "s g") 'helm-projectile-grep))

(use-package rainbow-mode
  :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package rainbow-identifiers
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-identifiers-mode))

(use-package recentf
  :ensure t
  :bind (("C-x C-r" . recentf-open-files))
  :config
  (setq recentf-max-menu-items 100)
  (recentf-mode 1))

(use-package spacemacs-common
  :ensure spacemacs-theme
  :config
  (load-theme 'spacemacs-dark t))

(use-package web-mode
  :config
  (add-to-list 'web-mode-comment-formats '("php" . "//"))
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.htm\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.htaccess\\'" . conf-mode))
  (add-to-list 'auto-mode-alist '("\\.wsgi\\'" . python-mode))
  (defun my-web-mode-hook ()
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset 2)
    (setq web-mode-code-indent-offset 2)
    (setq web-mode-indent-style 2))
  (setq-default indent-tabs-mode nil)
  (add-hook 'web-mode-hook  'my-web-mode-hook))

(use-package windmove
  :ensure t
  :config
  (setq windmove-default-keybindings t)
  (setq max-specpdl-size 10000))

(use-package yaml-mode
  :ensure t)

(use-package typescript-mode
  :ensure t)

(use-package vue-mode
  :ensure t)

(use-package yasnippet
  :ensure t
  :config
  (use-package clojure-snippets :ensure t)
  (yas-global-mode))

(use-package cider
  :ensure t
  :pin melpa-stable
  :bind (("C-c M-;" . cider-pprint-eval-last-sexp-to-comment))
  :config
  (setq cider-repl-use-clojure-font-lock t
	cider-font-lock-dynamically '(macro core function var)
	cider-default-cljs-repl 'figwheel
	cider-repl-display-help-banner nil
	cider-repl-use-pretty-printing t)
  (fset 'tsa/clojure-letvar-to-def
	(lambda (&optional arg)
	  "with cursor at a let-var, def it so you can proceed with repl debugging." 
	  (interactive "p") (kmacro-exec-ring-item (quote ([40 100 101 102 32 C-right C-right 134217734 134217734 134217734 24 5 67108911 67108911] 0 "%d")) arg)))
  (define-key clojure-mode-map (kbd "M-L") 'tsa/clojure-letvar-to-def))

(use-package undo-tree
  :ensure t
  :delight undo-tree-mode
  :bind (("C-x /" . undo-tree-visualize))
  :config
  (global-undo-tree-mode t))

(use-package wgrep
  :ensure t
  :config (use-package wgrep-helm :ensure t))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Add this line if you want to start in a particular file every time you start
;; (find-file "~/workspace/Clojure/myproject/project.clj")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(vue-mode typescript-mode yaml-mode uuidgen helm-company web-mode company-quickhelp which-key wgrep-helm wgrep undo-tree cider clojure-snippets yasnippet spacemacs-theme rainbow-identifiers rainbow-delimiters rainbow-mode helm-projectile projectile smartparens pos-tip magit ivy helm-descbinds helm dired-narrow dired-subtree dired-filter company clojure-mode-extra-font-locking flycheck-clj-kondo flycheck-joker clojure-mode cider-hydra anzu ace-jump-zap ace-isearch ace-jump-mode ace-popup-menu use-package))
 '(warning-suppress-types '((use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Similar to C-x C-e, but sends to REBL
(defun rebl-eval-last-sexp ()
  (interactive)
  (let* ((bounds (cider-last-sexp 'bounds))
         (s (cider-last-sexp))
         (reblized (concat "(cognitect.rebl/inspect " s ")")))
    (cider-interactive-eval reblized nil bounds (cider--nrepl-print-request-map))))

;; Similar to C-M-x, but sends to REBL
(defun rebl-eval-defun-at-point ()
  (interactive)
  (let* ((bounds (cider-defun-at-point 'bounds))
         (s (cider-defun-at-point))
         (reblized (concat "(cognitect.rebl/inspect " s ")")))
    (cider-interactive-eval reblized nil bounds (cider--nrepl-print-request-map))))

;; C-S-x send defun to rebl
;; C-x C-r send last sexp to rebl (Normally bound to "find-file-read-only"... Who actually uses that though?)
(add-hook 'cider-mode-hook
          (lambda ()
            (local-set-key (kbd "C-S-x") #'rebl-eval-defun-at-point)
            (local-set-key (kbd "C-x C-r") #'rebl-eval-last-sexp)))
