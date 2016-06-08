;; ============================================================================
;; TODO: What does this do?
;; ============================================================================
;(require 'cl-lib)
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
;; Racer - Code completion for Rust
;; ============================================================================
(setq racer-cmd "/home/martin/.cargo/bin/racer")
(setq racer-rust-src-path "/home/martin/dev/rust.git/src/")

;; Activate Racer when rust-mode starts
(add-hook 'rust-mode-hook #'racer-mode)

;; ============================================================================
;; Rustfmt - Code formatting for Rust
;; ============================================================================
;; Bind a keyboard shortcut to rustfmt
(eval-after-load 'rust-mode
  '(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer))

;; Format on save when using Rust mode
;;(add-hook 'rust-mode-hook #'rustfmt-enable-on-save)

;; ============================================================================
;; Flycheck-mode - Modern on the fly syntax checking
;; ============================================================================
;; TODO: What does this actually do...?
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

;; Activate flycheck-mode when rust-mode starts
(add-hook 'rust-mode-hook #'flycheck-mode)

;; Activate some extra flycheck stuff when flycheck-mode starts
(add-hook 'flycheck-mode-hook #'flycheck-pos-tip-mode)
(add-hook 'flycheck-mode-hook #'flycheck-color-mode-line-mode)

;; ============================================================================
;; Eldoc-mode - show function call signatures in echo area
;; ============================================================================
;; NOTE: Disabling eldoc for now, since it causes emacs to freeze in some
;; situations (for unknown reason). Try enabling it again later, perhaps when
;; new versions have been released. /2016-02-25
;(add-hook 'racer-mode-hook #'eldoc-mode)

;; ============================================================================
;; Irony-mode (C/C++ Minor mode)
;; ============================================================================
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)

;; ============================================================================
;; Company mode ("Complete anything") - A text completion framework for emacs
;; ============================================================================
;; Activate Company when c++-mode starts
(add-hook 'c++-mode-hook #'company-mode)

;; Activate Company when c-mode starts
(add-hook 'c-mode-hook #'company-mode)

;; NOTE: Disabling company for now, since it causes emacs to freeze in some
;; situations (for unknown reason). Try enabling it again later, perhaps when
;; new versions have been released. /2016-02-25
;; Activate Company when racer-mode starts
;;(add-hook 'racer-mode-hook #'company-mode)

(eval-after-load 'company
  '(define-key company-mode-map (kbd "TAB") #'company-indent-or-complete-common))

(setq company-tooltip-align-annotations t)

;; ============================================================================
;; C style
;; ============================================================================
(setq c-default-style "bsd")
(setq-default c-basic-offset 4)

;; Customize C style 
(defconst my-cc-style
  '("cc-mode"
    (c-offsets-alist . ((innamespace . [0])))))

(c-add-style "my-cc-mode" my-cc-style)

;; ============================================================================
;; Misc
;; ============================================================================
;; Theme
(add-to-list 'custom-theme-load-path "/home/martin/.emacs.d/cyberpunk-theme.el")

;; Backup path
(setq backup-directory-alist `(("." . "~/emacs-backups")))

;; Frame sizes and splitting
;;(add-to-list 'default-frame-alist '(width . 200))
;;(add-to-list 'default-frame-alist '(height . 50))
;;(add-to-list 'default-frame-alist '(left . 20))
;;(add-to-list 'default-frame-alist '(top . 30))
;;(setq split-height-threshold 40) 
;;(setq split-width-threshold 80)

;; No tab characters!
(setq-default indent-tabs-mode nil)

;; Display buffer in current window
(add-to-list 'same-window-buffer-names "*Completions*")
(add-to-list 'same-window-buffer-names "*Help*")
(add-to-list 'same-window-buffer-names "*Buffer List*")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes (quote (cyberpunk)))
 '(custom-safe-themes (quote ("cd0ae83bc6c947021a6507b5fbae87c33411ff8d6f3a9bf554ce8fed17274bf8" default)))
 '(inhibit-startup-screen t)
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
