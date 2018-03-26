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
;; (setq tab-stop-list (number-sequence 4 200 4))

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
             ;; configuration of the company-clang-arguments variable
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
             (setq whitespace-style '(face empty tabs lines-tail trailing))
             (global-whitespace-mode t)
             ))

;; Style
(setq c-default-style "bsd")
(setq-default c-basic-offset 8)
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
(setq racer-cmd "racer")
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
;; xml
;; ============================================================================
(setq nxml-child-indent 4 nxml-attribute-indent 4)


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

(setq enable-local-variables :safe)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#212121" "#CC5542" "#6aaf50" "#7d7c61" "#5180b3" "#DC8CC3" "#9b55c3" "#bdbdb3"])
 '(company-clang-insert-arguments nil)
 '(custom-enabled-themes (quote (martin)))
 '(custom-safe-themes
   (quote
    ("fe3dbede82c10d84366ec3f738850d6e043b7080a13fb8f5cbba47ae50bb9a7d" "850fc539df597f449e206a60d4b00a7fba0e23202e8987f0f1a17c272d069341" "e77006afeb855af2b5ab148ebb697de23539362bb29e7f9bed2267588498b22f" "cf574f5ecdaa5527e4111afb3aa0fbf5849b51e84100636f5a3f96f96ed00f4c" "348ca59ab1db997cc3c0981d14256dbd77866d82578fd47c1ef3d3276d588539" "d6290003ee8ac467ceba21163e936f122106a2fb5797846f98e94c3c69b6c2d0" "02b200083bc2ff0b840f6440e66c35d625cbf15c0f67abbb956fa527b0171393" "427621cbeed47edcd402171ae3b230d39f839d46c60fc8beb7848bcf9c8986e3" "a2994a65906acb4a3719f5bedb6ef4c21589c12f6b27d79016885ce1412be2af" "93ce12ed10cdb0757c6f0df50eb6df00bbd8e00fd9c3b15315e760bdabba1e63" "194335498cce57c7fa0ea59baffd6e98d64ef9a047e0a34263a110432e468b3a" "d11ca8dc52949e95374b5dd23374a929f5308c96c97f194be3bac256a2b0028b" "13da46a7f28e5e6b00a19d9a3466ba02b7d367fa8de4ad6410b2b7b97fba56b7" "07647d69705e4c709183be122b7d76ebc8b60c2859765f1a48f480da932695be" "da92b9185b1e60a0e02d566304f0673b37b12eb519522e5a0b04da032674fe79" "e0437da5709ce4dcb723d05e6286a5de9a411a1ae12199facf40304618cd5483" "877b6a0d588e2225b9bb8be2144345bbaa671e8ad1e5a76ffbc518e1ecc2aabd" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "1db337246ebc9c083be0d728f8d20913a0f46edc0a00277746ba411c149d7fe5" "ee89863f86247942d9fc404d47b2704475b146c079c1dcd2390d697ddfa9bdf4" "87073e92c4437df15f127e18cb05b2832c99689201c4d81dee3c20c7197d62e7" "adde823697efd8b7532eb0406b60903310979b334e431f35d282399d6655512e" "1af1cc4b157451aa0a370f09dd2fa4e2619b82938fe35fedd6487c92eb3eda0f" "c84a6d48bd840fc3dc719847efb33ee5cc58ebe09daf954dd6cb304bcd751101" "fe4086cd8ecdba0167ed3d6b94752191d310bc3661f71b82177b009ed816bff3" "50c5b6220b6a8e0d7fb01908e60779dee33566bb3b36d7c4443618ddb5418068" "433961d325be046c56a220db2d94b85d756772fe1e502b1cdaf31e2e1ec091a1" "fcc3963285e9c9074d6f34596ff333430ad3825dab37b277931e2b789b94c369" "a1035b15c35eaa41a08d0344655163ba417638cea0b062ff2fb62524a5acfe2f" "900cb33814d1b508576259ccfbb8dd0b03d748a24241a925638ad3f7d249338c" "795f05f6b20dc4348594d631e7f79097ea514764371537587f07ac7e934a2159" "6b36b4d5235bc176b3a3cc9f506c78849165222a5185ad58fb8d6b0011dd95c1" "d4a3aad9ebcc68893a9ce6624488fe2255419df70f9a13ed5f30df32bc9e48d5" "fcd916898113e53a8148edbd8c3c574b87205d5fcdabb1920d17eaddd8c24f36" "8a3d45b6408c449306532e46823f75e2525ffd726e2d1b9a722be2b47a212ef3" "92583e2918bf3d3254af565b624318498edd6c142a23c0d594368c129997d1c4" "d1b31e42ac44a8b70311c210bd7eb2b324fc3242e98c91c2a22ad9badd3872dc" default)))
 '(fci-rule-color "#383838")
 '(package-selected-packages
   (quote
    (window-numbering racer projectile irony-eldoc helm-gtags flycheck-rust flycheck-irony cyberpunk-theme company-racer company-irony-c-headers company-irony ample-zen-theme ample-theme)))
 '(vc-annotate-background "#3b3b3b")
 '(vc-annotate-color-map
   (quote
    ((20 . "#dd5542")
     (40 . "#CC5542")
     (60 . "#fb8512")
     (80 . "#baba36")
     (100 . "#bdbc61")
     (120 . "#7d7c61")
     (140 . "#6abd50")
     (160 . "#6aaf50")
     (180 . "#6aa350")
     (200 . "#6a9550")
     (220 . "#6a8550")
     (240 . "#6a7550")
     (260 . "#9b55c3")
     (280 . "#6CA0A3")
     (300 . "#528fd1")
     (320 . "#5180b3")
     (340 . "#6380b3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
