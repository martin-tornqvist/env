;; ============================================================================
;; TODO: What does this do?
;; ============================================================================
;; (require 'cl-lib)
(require 'cl)

;; ============================================================================
;; Allow Emacs to install packages from MELPA
;; ("Milkypostman's Emacs Lisp Package Archive)
;; ============================================================================
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

;;
;; NOTE: Packages can be installed/uninstalled with M-x package-list-packages
;; U-x upgrades all packages
;;


;; ============================================================================
;; Common
;; ============================================================================
;; Helm (incremental search system, it's pretty awesome)

;; NOTE: helm-swoop seems nice, perhaps try it sometimes

(require 'helm-config)
(require 'helm-grep)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to do persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(define-key helm-grep-mode-map (kbd "<return>")  'helm-grep-mode-jump-other-window)
(define-key helm-grep-mode-map (kbd "n")  'helm-grep-mode-jump-other-window-forward)
(define-key helm-grep-mode-map (kbd "p") 'helm-grep-mode-jump-other-window-backward)

(add-to-list 'helm-sources-using-default-as-input 'helm-source-man-pages)

;; Override some common commands with Helm-style variants
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
(global-set-key (kbd "C-c h o") 'helm-occur)
(global-set-key (kbd "C-c h x") 'helm-register)
(define-key 'help-command (kbd "C-f") 'helm-apropos)
(define-key 'help-command (kbd "r") 'helm-info-emacs)
(define-key 'help-command (kbd "C-l") 'helm-locate-library)

;; Enable company globally for all mode
(require 'company)
(global-company-mode)
(setq company-idle-delay nil)
(setq company-minimum-prefix-length 1)
(setq company-tooltip-align-annotations t)

;; GNU Global source code tagging system
;; NOTE: To create tags, run "gtags" in the root folder of the project.
;; gtags is available through the apt package "global"
(require 'helm-gtags)

(setq
  helm-gtags-ignore-case t
  helm-gtags-auto-update t
  helm-gtags-pulse-at-cursor t
  helm-gtags-prefix-key "\C-c g"
  helm-gtags-suggested-key-mapping t
  helm-gtags-use-input-at-cursor t
  )

(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)

;; NOTE: type M-x helm to discover helm or helm-gtags functions

;; Map Helm key(s) to something more convenient
;; NOTE: C-x c is the 'helm-command-prefix'
;; Find files
(define-key key-translation-map [f5] (kbd "\C-x c f"))

;; Shortcut keys for helm-gtags key(s)
;; Find pattern
(define-key helm-gtags-mode-map (kbd "<f6>") 'helm-gtags-find-pattern)

;; ============================================================================
;; C/C++
;; ============================================================================
(require 'irony)
(require 'company-irony-c-headers)

(setq company-clang-executable "clang++-3.6")

;; (Yes, it really should be two dashes...)
(setq company-irony-c-headers--compiler-executable "clang++-3.6")

(setq flycheck-c/c++-clang-executable "clang++-3.6")

;; Setting up configurations when c++-mode loads
(add-hook 'c++-mode-hook
  '(lambda ()

  (irony-mode)

  (helm-gtags-mode)

  ;; Eldoc-mode - show function call signatures in echo area
  (eldoc-mode)
  (irony-eldoc)

  ;; Flycheck ("Modern on the fly syntax checking")
  (flycheck-mode)
  (flycheck-irony-setup)

  (set (make-local-variable 'company-backends) '(company-clang company-irony-c-headers company-irony))

  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)

  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async)

  (company-irony-setup-begin-commands)

  (irony-cdb-autosetup-compile-options)

  ;; Key binding to auto complete and indent
  (local-set-key (kbd "TAB") #'company-indent-or-complete-common)
  ))

;; Style
(setq c-default-style "bsd")
(setq-default c-basic-offset 4)

;; Customize C style 
(defconst my-cc-style
  '("cc-mode"
    (c-offsets-alist . ((innamespace . [0])))))

(c-add-style "my-cc-mode" my-cc-style)


;; ============================================================================
;; Rust
;; ============================================================================
;; Racer - Code completion for Rust
(setq racer-cmd "/home/martin/.cargo/bin/racer")
(setq racer-rust-src-path "/home/martin/dev/rust/src/")

;; Load rust-mode when you open `.rs` files
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

;; Setting up configurations when rust-mode loads
(add-hook 'rust-mode-hook
  '(lambda ()
  ;; Racer (Rust Auto Complete-er)
  (racer-mode)

  ;; NOTE:
  ;; M-. jumps to declaration
  ;; M-, jumps back

  ;; Hook in racer with eldoc to provide documentation
  (racer-turn-on-eldoc)

  ;; Flycheck ("Modern on the fly syntax checking")
  (flycheck-mode)

  ;; Use flycheck-rust in rust-mode
  (flycheck-rust-setup)

  ;; Use company-racer in rust mode
  (set (make-local-variable 'company-backends) '(company-racer))

  ;; Key binding to auto complete and indent
  (local-set-key (kbd "TAB") #'company-indent-or-complete-common)

  ;; Format on save
  (rustfmt-enable-on-save)
  ))

;; Bind a keyboard shortcut to rustfmt
;; (eval-after-load 'rust-mode
;;   '(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer))

;; ============================================================================
;; Misc
;; ============================================================================
;; Theme
(add-to-list 'custom-theme-load-path "/home/martin/.emacs.d/cyberpunk-theme.el")

;; Backup path
(setq backup-directory-alist `(("." . "~/emacs-backups")))

;; Frame sizes and splitting
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; (add-to-list 'default-frame-alist '(width  . 100))
;; (add-to-list 'default-frame-alist '(height . 40))

;; (add-to-list 'default-frame-alist '(left   . 200))
;; (add-to-list 'default-frame-alist '(top    . 160))

;; (setq split-height-threshold 40) 
;; (setq split-width-threshold 80)

;; No tab characters!
(setq-default indent-tabs-mode nil)

;; Display buffer in current window
(add-to-list 'same-window-buffer-names "*Completions*")
(add-to-list 'same-window-buffer-names "*Help*")
(add-to-list 'same-window-buffer-names "*Buffer List*")

;; Always follow symbolic links
(setq vc-follow-symlinks t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(column-number-mode t)
 '(custom-enabled-themes (quote (wombat)))
 '(custom-safe-themes (quote ("cd0ae83bc6c947021a6507b5fbae87c33411ff8d6f3a9bf554ce8fed17274bf8" default)))
 '(inhibit-startup-screen t)
 '(safe-local-variable-values (quote ((company-c-headers-path-user quote ("include" "rl_utils/include")) (company-clang-arguments "-std=c++11" "-I/usr/include/SDL2" "-Iinclude" "-Irl_utils/include") (company-c-headers-path-user quote ("/home/martin/dev/ia/include")) (company-clang-arguments "-std=c++11" "-I/usr/include/SDL2" "-I/home/martin/dev/ia/include" "-I/home/martin/dev/ia/rl_utils/include") (company-clang-arguments "-std=c++11" "-I/home/martin/dev/ia/include" "-I/home/martin/dev/ia/rl_utils/include" "-I/usr/include/SDL2"))))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "unknown" :slant normal :weight normal :height 98 :width normal)))))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
