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
;; NOTE: Packages can be installed/uninstalled with M-x list-packages
;; U-x upgrades all packages
;;


;; ============================================================================
;; Common
;; ============================================================================
;; Helm (incremental search system)
;; NOTE: helm-swoop seems nice, perhaps try it sometimes
;; (require 'helm-config)
;; (require 'helm-grep)

;; Tab to tab stop
(global-set-key (kbd "<C-tab>") 'tab-to-tab-stop)
(setq tab-stop-list (number-sequence 4 200 4))

;; Rebind tab to do persistent action
;; (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)

;; Make TAB work in terminal
;; (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)

;; List actions using C-z
;; (define-key helm-map (kbd "C-z")  'helm-select-action)

;; (define-key helm-grep-mode-map (kbd "<return>")  'helm-grep-mode-jump-other-window)
;; (define-key helm-grep-mode-map (kbd "n")  'helm-grep-mode-jump-other-window-forward)
;; (define-key helm-grep-mode-map (kbd "p") 'helm-grep-mode-jump-other-window-backward)

;; (add-to-list 'helm-sources-using-default-as-input 'helm-source-man-pages)

;; Override some common commands with Helm-style variants
;; (global-set-key (kbd "M-x") 'helm-M-x)
;; (global-set-key (kbd "M-y") 'helm-show-kill-ring)
;; (global-set-key (kbd "C-x b") 'helm-mini)
;; (global-set-key (kbd "C-x C-f") 'helm-find-files)
;; (global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
;; (global-set-key (kbd "C-c h o") 'helm-occur)
;; (global-set-key (kbd "C-c h x") 'helm-register)
;; (define-key 'help-command (kbd "C-f") 'helm-apropos)
;; (define-key 'help-command (kbd "r") 'helm-info-emacs)
;; (define-key 'help-command (kbd "C-l") 'helm-locate-library)

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

(setq helm-gtags-ignore-case t
      helm-gtags-auto-update t
      helm-gtags-pulse-at-cursor t
      helm-gtags-prefix-key "\C-c g"
      helm-gtags-suggested-key-mapping t
      helm-gtags-use-input-at-cursor t)

(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)

;; Map Helm key(s) to something more convenient
;; NOTE: C-x c is the 'helm-command-prefix'
;; Find files
;; (define-key key-translation-map [f5] (kbd "\C-x c f"))

;; Shortcut keys for helm-gtags key(s)
;; Find pattern
;; (define-key helm-gtags-mode-map (kbd "<f6>") 'helm-gtags-find-pattern)

;; Whitespace mode
;; NOTE: Set whitespace-line-column in projects dir_locals file
;;       (May requiring restarting whitespace-mode afterwards)
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)

;; Numbered windows (jump to specific window with M-#)
(require 'window-numbering)
(window-numbering-mode)

;; Auto revert buffer mode (so you don't have to manually M-x revert-buffer)
(global-auto-revert-mode 1)

;; Subword mode (to treat camelcase words as separate words)
(global-subword-mode 1)

;; Show line numbers in margin
;; (global-linum-mode)

;; Recompile, next error, previous error
(global-set-key (kbd "<f6>") 'recompile)
(global-set-key (kbd "<f7>") 'next-error)
(global-set-key (kbd "S-<f7>") 'previous-error)

;; Scroll "compilation" buffer
;; (setq compilation-scroll-output 'first-error)
(setq compilation-scroll-output t)

;; Delete, backspace, or entering characters deletes selected region
(delete-selection-mode 1)

;; Highlight current line
(global-hl-line-mode +1)

;; Show matching brace
(show-paren-mode)

;; Display buffer in current window
(add-to-list 'same-window-buffer-names "*Completions*")
(add-to-list 'same-window-buffer-names "*Help*")
(add-to-list 'same-window-buffer-names "*Buffer List*")
(add-to-list 'same-window-buffer-names "*find files*")
(add-to-list 'same-window-buffer-names "*calculator*")
(add-to-list 'same-window-buffer-names "*helm find files*")
(add-to-list 'same-window-buffer-names "*helm M-x*")
(add-to-list 'same-window-buffer-names "*helm mini*")

;; ============================================================================
;; C/C++
;; ============================================================================
(require 'irony)
(require 'company-irony-c-headers)

;; Setup clang executable
(setq clang-executable "clang")

(setq company-clang-executable clang-executable)

;; (Yes, it really should be two dashes...)
(setq company-irony-c-headers--compiler-executable clang-executable)

(setq flycheck-c/c++-clang-executable clang-executable)

;; Setting up configurations when c++-mode loads
(add-hook 'c++-mode-hook
          '(lambda ()

             ;; NOTE: Put a .clang_complete or compile_commands.json in the
             ;; project root
             (irony-mode)

             ;; List of relative paths where irony can search for a compile
             ;; database (e.g. compile_commands.json)
             (setq irony-cdb-search-directory-list (quote ("." ".." "build")))

             (helm-gtags-mode)

             ;; Eldoc-mode - show function call signatures in echo area
             (eldoc-mode)
             (irony-eldoc)

             ;; Flycheck ("Modern on the fly syntax checking")
             (flycheck-mode)
             (flycheck-irony-setup)

             ;; NOTE: Put a .dir_locals file in project root, containing a
             ;;       configuration of the company-clang-arguments variable
             (set (make-local-variable 'company-backends)
                  '(company-irony company-clang company-irony-c-headers))

             (define-key irony-mode-map [remap completion-at-point]
               'irony-completion-at-point-async)

             (define-key irony-mode-map [remap complete-symbol]
               'irony-completion-at-point-async)

             (company-irony-setup-begin-commands)

             (irony-cdb-autosetup-compile-options)

             ;; Key binding to auto complete and indent
             (local-set-key (kbd "TAB") #'company-indent-or-complete-common)

             ;; Delete trailing whitespace on save
             (add-hook 'write-contents-functions
                       (lambda ()
                         (delete-trailing-whitespace)
                         nil))

             ;; Whitespace mode
             (require 'whitespace)
             (whitespace-mode 1)
             ))

;; Style
(setq c-default-style "bsd")
(setq-default c-basic-offset 4)
(c-set-offset 'innamespace 0)

;; A hack to fix C++11 lambda function indentation
(defadvice c-lineup-arglist (around my activate)
  "Improve indentation of continued C++11 lambda function opened as argument."
  (setq ad-return-value
        (if (and (equal major-mode 'c++-mode)
                 (ignore-errors
                   (save-excursion
                     (goto-char (c-langelem-pos langelem))
                     ;; Detect "[...](" or "[...]{". preceded by "," or "(",
                     ;;   and with unclosed brace.
                     (looking-at ".*[(,][ \t]*\\[[^]]*\\][ \t]*[({][^}]*$"))))
            0         ;; no additional indent
          ad-do-it))) ;; default behavior


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
             (rust-enable-format-on-save)
             ))

;; Bind a keyboard shortcut to rustfmt
;; (eval-after-load 'rust-mode
;;   '(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer))

;; Style
(setq-default rust-indent-offset 4)

;; ============================================================================
;; Misc
;; ============================================================================
;; Theme
(add-to-list 'custom-theme-load-path "/home/martin/.emacs.d/themes")

;; Default directory for themes
(setq custom-theme-directory "/home/martin/.emacs.d/themes")

;; Load custom theme (without confirmation)
(load-theme 'martin t)

;; Backup path
(setq backup-directory-alist `(("." . "~/emacs-backups")))

;; No tab characters
(setq-default indent-tabs-mode nil)

;; Show column number
(setq column-number-mode t)

;; No startup screen
(setq inhibit-startup-screen t)

;; No menu bar, tool bar, scroll bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Always follow symbolic links
(setq vc-follow-symlinks t)

;; Default font
(set-face-attribute 'default nil
                    :family "Terminus"
                    :height 120
                    :weight 'normal
                    :width 'normal)

;; TODO: Do not use ":all"
(setq enable-local-variables :safe)
