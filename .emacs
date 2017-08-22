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
(require 'helm-config)
(require 'helm-grep)

;; Tab to tab stop
(global-set-key (kbd "<C-tab>") 'tab-to-tab-stop)
(setq tab-stop-list (number-sequence 4 200 4))

;; Rebind tab to do persistent action
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)

;; Make TAB work in terminal
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)

;; List actions using C-z
(define-key helm-map (kbd "C-z")  'helm-select-action)

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

(setq helm-gtags-ignore-case t
      helm-gtags-auto-update t
      helm-gtags-pulse-at-cursor t
      helm-gtags-prefix-key "\C-c g"
      helm-gtags-suggested-key-mapping t
      helm-gtags-use-input-at-cursor t)

(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)

;; NOTE: type M-x helm to discover helm or helm-gtags functions

;; Map Helm key(s) to something more convenient
;; NOTE: C-x c is the 'helm-command-prefix'
;; Find files
(define-key key-translation-map [f5] (kbd "\C-x c f"))

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
(global-linum-mode)

;; Recompile, next error, previous error
(global-set-key (kbd "<f6>") 'recompile)
(global-set-key (kbd "<f7>") 'next-error)
(global-set-key (kbd "S-<f7>") 'previous-error)

;; Scroll "compilation" buffer
;; (setq compilation-scroll-output t)
(setq compilation-scroll-output 'first-error)

;; Delete, backspace, or entering characters deletes selected region
(delete-selection-mode 1)


;; ============================================================================
;; C/C++
;; ============================================================================
(require 'irony)
(require 'company-irony-c-headers)

;; Setup clang executable
(setq clang-executable "clang++-3.8")

(setq company-clang-executable clang-executable)

;; (Yes, it really should be two dashes...)
(setq company-irony-c-headers--compiler-executable clang-executable)

(setq flycheck-c/c++-clang-executable clang-executable)

;; Setting up configurations when c++-mode loads
(add-hook 'c++-mode-hook
          '(lambda ()

             ;; NOTE: Put a .clang_complete in project root
             (irony-mode)

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
                  '(company-clang company-irony-c-headers company-irony))

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

;; ============================================================================
;; Misc
;; ============================================================================
;; Theme
(add-to-list 'custom-theme-load-path "/home/martin/.emacs.d/themes")

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
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(column-number-mode t)
 '(compilation-message-face (quote default))
 '(custom-enabled-themes (quote (ample)))
 '(custom-safe-themes
   (quote
    ("d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "235dc2dd925f492667232ead701c450d5c6fce978d5676e54ef9ca6dd37f6ceb" "1db337246ebc9c083be0d728f8d20913a0f46edc0a00277746ba411c149d7fe5" "938d8c186c4cb9ec4a8d8bc159285e0d0f07bad46edf20aa469a89d0d2a586ea" "6de7c03d614033c0403657409313d5f01202361e35490a3404e33e46663c2596" "ed317c0a3387be628a48c4bbdb316b4fa645a414838149069210b66dd521733f" "38e64ea9b3a5e512ae9547063ee491c20bd717fe59d9c12219a0b1050b439cdd" "a93bb5819f8e572e61be35e5645a5b9393434525a1c8989a6519724ad5dcc647" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06b2849748590f7f991bf0aaaea96611bb3a6982cad8b1e3fc707055b96d64ca" "fe230d2861a13bb969b5cdf45df1396385250cc0b7933b8ab9a2f9339b455f5c" "331433979cba7e5db23375e231e9216b2eb1d0b7977a3b327560b4dd6a2ef1ec" "4d886950135ac65bcaeaad1b7cba07696889ee6cec5b0337de561ea883ee99d6" "bd583f860cb323b5083f8bec3216d877561210ae820cb508d7a6ae2b73b3cff9" "a388014bace6f437697718697d7851ef57f4f1cb069a4b48444b0dcbdb5fd048" "cd0ae83bc6c947021a6507b5fbae87c33411ff8d6f3a9bf554ce8fed17274bf8" default)))
 '(fci-rule-color "#20240E")
 '(highlight-changes-colors (quote ("#FD5FF0" "#AE81FF")))
 '(highlight-tail-colors
   (quote
    (("#20240E" . 0)
     ("#679A01" . 20)
     ("#4BBEAE" . 30)
     ("#1DB4D0" . 50)
     ("#9A8F21" . 60)
     ("#A75B00" . 70)
     ("#F309DF" . 85)
     ("#20240E" . 100))))
 '(inhibit-startup-screen t)
 '(magit-diff-use-overlays nil)
 '(menu-bar-mode nil)
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(pos-tip-background-color "#A6E22E")
 '(pos-tip-foreground-color "#272822")
 '(safe-local-variable-values
   (quote
    ((eval progn
           (require
            (quote projectile))
           (setq company-clang-arguments
                 (delete-dups
                  (append company-clang-arguments
                          (list "-std=c++14"
                                (concat "-I"
                                        (projectile-project-root)
                                        "include")
                                (concat "-I"
                                        (projectile-project-root)
                                        "rl_utils/include")
                                (concat "-I"
                                        (projectile-project-root)
                                        "json/2.0.2/include")
                                "-I/usr/include/SDL2")))))
     (eval progn
           (require
            (quote projectile))
           (setq company-clang-arguments
                 (delete-dups
                  (append company-clang-arguments
                          (list "-std=c++14"
                                (concat "-I"
                                        (projectile-project-root)
                                        "include")
                                (concat "-I"
                                        (projectile-project-root)
                                        "rl_utils/include")
                                "-I/usr/include/SDL2")))))
     (whitespace-line-column . 80)
     (whitespace-line-column . 50)
     (c++-mode
      (whitespace-line-column . 50)
      (eval ignore-errors
            (add-hook
             (quote write-contents-functions)
             (lambda nil
               (delete-trailing-whitespace)
               nil))
            (require
             (quote whitespace))
            (whitespace-mode 0)
            (whitespace-mode 1)))
     (eval ignore-errors
           (add-hook
            (quote write-contents-functions)
            (lambda nil
              (delete-trailing-whitespace)
              nil))
           (require
            (quote whitespace))
           (whitespace-mode 0)
           (whitespace-mode 1))
     (eval ignore-errors "Write-contents-functions is a buffer-local alternative to before-save-hook"
           (add-hook
            (quote write-contents-functions)
            (lambda nil
              (delete-trailing-whitespace)
              nil))
           (require
            (quote whitespace))
           "Sometimes the mode needs to be toggled off and on."
           (whitespace-mode 0)
           (whitespace-mode 1))
     (c++-mode
      (whitespace-line-column . 50))
     (eval progn
           (require
            (quote projectile))
           (setq company-clang-arguments
                 (delete-dups
                  (append company-clang-arguments
                          (list "-std=c++11"
                                (concat "-I"
                                        (projectile-project-root)
                                        "include")
                                (concat "-I"
                                        (projectile-project-root)
                                        "rl_utils/include")
                                "-I/usr/include/SDL2")))))
     (eval progn
           (require
            (quote projectile))
           (setq company-clang-arguments
                 (delete-dups
                  (append company-clang-arguments
                          (list
                           (concat "-I"
                                   (projectile-project-root)
                                   "include")
                           (concat "-I"
                                   (projectile-project-root)
                                   "rl_utils"))))))
     (eval progn
           (require
            (quote projectile))
           (setq company-clang-arguments
                 (delete-dups
                  (append company-clang-arguments
                          (list
                           (concat "-I"
                                   (projectile-project-root)
                                   "include"))))))
     (eval progn
           (require
            (quote projectile))
           (setq company-clang-arguments
                 (delete-dups
                  (append company-clang-arguments
                          (list
                           (concat "-I"
                                   (locate-dominating-file default-directory ".dir-locals.el")
                                   "include"))))))
     (company-c-headers-path-user quote
                                  ("include"))
     (company-c-headers-path-user quote
                                  ("/home/martin/dev/strategy-game/include"))
     (company-clang-arguments "-std=c++11" "-I/usr/include/SDL2" "-I/home/martin/dev/strategy-game/include" "-I/home/martin/dev/strategy-game/rl_utils/include")
     (company-c-headers-path-user quote
                                  ("include" "rl_utils/include"))
     (company-clang-arguments "-std=c++11" "-I/usr/include/SDL2" "-Iinclude" "-Irl_utils/include")
     (company-c-headers-path-user quote
                                  ("/home/martin/dev/ia/include"))
     (company-clang-arguments "-std=c++11" "-I/usr/include/SDL2" "-I/home/martin/dev/ia/include" "-I/home/martin/dev/ia/rl_utils/include")
     (company-clang-arguments "-std=c++11" "-I/home/martin/dev/ia/include" "-I/home/martin/dev/ia/rl_utils/include" "-I/usr/include/SDL2"))))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#F92672")
     (40 . "#CF4F1F")
     (60 . "#C26C0F")
     (80 . "#E6DB74")
     (100 . "#AB8C00")
     (120 . "#A18F00")
     (140 . "#989200")
     (160 . "#8E9500")
     (180 . "#A6E22E")
     (200 . "#729A1E")
     (220 . "#609C3C")
     (240 . "#4E9D5B")
     (260 . "#3C9F79")
     (280 . "#A1EFE4")
     (300 . "#299BA6")
     (320 . "#2896B5")
     (340 . "#2790C3")
     (360 . "#66D9EF"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (unspecified "#272822" "#20240E" "#F70057" "#F92672" "#86C30D" "#A6E22E" "#BEB244" "#E6DB74" "#40CAE4" "#66D9EF" "#FB35EA" "#FD5FF0" "#74DBCD" "#A1EFE4" "#F8F8F2" "#F8F8F0")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Terminus" :foundry "xos4" :slant normal :weight normal :height 105 :width normal)))))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
