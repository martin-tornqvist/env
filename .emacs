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
;; (setq compilation-scroll-output 'first-error)
(setq compilation-scroll-output t)

;; Delete, backspace, or entering characters deletes selected region
(delete-selection-mode 1)

;; Highlight current line
(global-hl-line-mode +1)

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

;; Style
(setq-default rust-indent-offset 4)

;; ============================================================================
;; Misc
;; ============================================================================
;; Theme
(add-to-list 'custom-theme-load-path "/home/martin/.emacs.d/themes")

;; Default directory for themes
(setq custom-theme-directory "/home/martin/.emacs.d/themes")

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

;; display-buffer should not create a separate frame
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
 '(custom-enabled-themes (quote (ample-zen-martin)))
 '(custom-safe-themes
   (quote
    ("b6d30eb22ed9884dcf104d9deed840e8f2c34665cdb9cb2c46d1fcef34d49e76" "85899c623cc873e369bccc0e37b903ef3a6fa84972535c9191937006d144d242" "5cc61146650e9589178c6ac04821bdfabfb76049df284214dd585e21592bd858" "a581be8732e8b347776f7ff3146d1ae125822ecb9650d43e816d1d6b138a4d7e" "dd8e83ac67be31684ad6e58c5fd721d1564268ef5c383834085dedc1d660edc7" "2f10820cf43532be814d24542a490e125afd54b1fe1ed9245df30d2fd035176b" "1b7bdbcfc44eb68cf1d45b60ee9eb4ec12389541c1fa70d0f5b073ec9ce1df42" "c5612f3d3a4fe6490c502469f0b6d5bf2a1cb5b5fbf7164d57c7c1af033f2ff7" "75df3739f281d3adf7e83e407e0f28230813f641323ed65b5a2909980004fe40" "4a8883b45c09888112ef71a467e9cc5e6bc9b03122a3631b44bde2b81be59d59" "3fe69b55f77f7841e3e13f190f2960f2a22de72882aca9ef3feefbc20804b408" "88dd9cac52b7706a6a578d8da6b851c3ddb49be93498c40b877bdcbe62f82ae2" "764dbff615afcce9391d51338cb8f0714a875ff59540fbc272e619211ba2773d" "98bf2b6f018e07a67c808f8c81036942c66b38419663579f0fde0c4ba3b5da09" "3753af6dd53caa6c640c3e898c086c0fdbb9261f08211e79123a95e59aae3406" "1e13159177ca9ab9f15b2e536b80f67628439041afb32e462ac8cf6fc1dbc9be" "223b89cde48f5d54f1be8aa5b32296dad77f49a7ff710c04f70eedb1f418fa40" "608732bf95efaf17ef8fdef991bc4c87bcf511421f64e3fdde9085f8e6cd7103" "22f1f9de26797a63168b973e77bd397f56b288e2e0ca4fa617f8c13a298e433f" "e41bd25895ae882e5a797e04bee18b66c5d88316c2acf319cb96e8ba77ef60e7" "4e43c1ef077c58ae55f71afdc6a294bdde6b086fc9b1d569f8cd0fe74db9c9b5" "dd808be38a20d602cb51ceb8fef61ccc8d1c7399bcc9db59fb52724e91c2933c" "883d78a08b2d6ee30d2074a77fedd0362e506148042cc176e41e8e1d2a66c850" "0aea84c81b6531cf8cd82818a09e7893bb30bfa93946b84941318a42740e47d3" "ca2b2696c5f9ab7861cdc4f01f772578dc956682f0b91451a68ac5a19a4593d2" "93e5bc81ce9079c9eb76d7902378bde00c30315942fc860332a8e57d049167dc" "ae5b0f7d45ea4bb890afdd148508f6be4cc26b28e5524b480016caf92b064f6a" "0af5f9d014c8395040be3f108012681155d5ba7e1f5550264f9e592f38d0c3b7" "26a95dabe866d02cf3d8ba277ce6041218064be354415eabccf4fd3ffaa99a43" "9f1db8903e22626630b0587cab8d964579033e3309ceec814a54ae32510d7f98" "affd5f4ec2e66265b92056ae7b31566b3dba463863f164bd63c3f8269ef24f44" "bef6c8684fe4b5b88ee9a9a61b7491abf329621f082606fe6df4f27fcbc59a52" "a5389b57fd5e60c8dfd275483a9fb85a295e33f11ff3caf81dcd6d57fa767046" "4566c615e32e5d092c5a2e6df55124ca3dcbc453c3be0b2cb8ec4746dab6e4f4" "d925e1424aef2ba106089a2c05a60622609cdc8ad30d4b209cb54aa7ccf6a1c8" "da58e0b7242d9be77c7f0ca85bad4825126d38a081d29cee6bcf3f03cbf0e1a7" "aee9514c0a52204f2e93e1498fec54c17e224a1e1e2c7a7d1761120483beeecf" "aa123dda465b9375feb14f06d46f0cb0d6463bb446df09def83cecde1b149946" "f304e9d4b1ec09f5aeafd18256d5d060776a72c9d5163234dc6595ce31a35854" "e7901fb6cb21049a21fbf8b5fad7316845d5f036042e8a569216b50f8d7982e3" "864439f3a22c5f855ad6a948bd1b7ec0ebcb12b2ba36b4c9fbff0dcfd6d4cf7f" "bef75509b05f01f5966ef0f73391aff08615f9fa0858cfa652043f0b13ed63fc" "001eb0e30d7129979b7cf04dbec44949136ad8e32a11b29b674625d32e546509" "aaf92959dc540c30b250f2215f9cc291c0db7eadc0f2d63672fde7a5893b71bd" "942c44eca4c38000cd93545582c0e51adbfce9201979d9ec32bc253a7d419113" "cffb3c781a419540c53ae877b4ddcfaa9532cee67cc61d89e37af20ff4f58006" "a34cde01232d1c1fcedff63b33752a38e68c40022c3beca5cfd54b486fd27154" "823d56a11ed093ff144c1fe6ccf68f1594cf0e4f701e52f1ec58bab2d89fd331" "8705d8c90c40ce478409a1f44f2a6a53227a4ff5c99a5cfd0cb2f094ba09479c" "4bfee0e2f841a316c67f4f394c33b431a67f033e907e41a0925a06264601d7b7" "f7eba4bbf0780dd299fcd41743ea26e28a5b279eb2fd523bac0b0ef455434ad5" "fd9cf8e580bd962da20a8266e99ff5da686ddd3f4d17c222c38ad1250bf1f1c1" "7c197a736c09ebf5c2f4778a7f85674daf2d1d79a1467fe74048ce1e1bcb76e7" "e1c9efe7446a750c85f716c4315a86a9928c16f8e0da7228dc6a1863eeefdc71" "20e371edda5a21a12051bdc198db58bbb694090efc39bf27a585503135ff7499" "d66d13e497ca63d26c23696fdea7d1e295d594aedea03778c990036d6475a2d2" "87bc93a8a3372062dc6029c9bbea8c8a398e324e195fd36fe1e54d2a62afac9d" "f2704476595df015a65dd896f343c70b71b5e8003d95425ef7968ca9db1f4a86" "1cd156b2f1fb249f5f68a7fd11a3f4e565085b6ec7efa9a128a31d4934b46e56" "4ff07dbd389c461031fbddc5438c92eba40166975e66214ec1e3b570706bc9fb" "b30a421afcdaa375ad7c0200e57b8619eae6b1d80301a5843fef9460d8bed6f5" "40074c6901faf51606686e095b3845e42f94fbe7240298a3b4d92d33ed761275" "d94100ed89266c30c992f444d0e4e35584b12c9f3344f9ebf9a2194f71161d6c" "c6150ff1f2a3140b80112cf67662acc1d6777f21f31fb7c4f58dabd88ce464d2" "d52b3eeb7fada428ff20f1d3806bba08ed365791183be99db5658255d1bb442b" "4837cd37e601372615b057e84c10cebe743bfef345c2255c6ade9cf7df7bb3ad" "856c382adb2db9786a01a8d1e9e281d3064734fe1d8b82b0a0f864e9f86340cb" "1ff3c7cd214fe7224f36fea026820267657062b60a381dcaf90afdbda092bd65" "da68e1e57507f966d805407bea44d5823117daf9b211a3a4bfa8a7b81c16576e" "91315968cde118d67ef558b7220eafdada33df303dce36f9525938d302b953b4" "d7af44080212a04dbbfa5833cd1d87f454a3d4f8139fc6f9335c2f1da2fdbd58" "db4d3e4db23bf502a4c08dcabbcf939f63f8a90efbd60739e4251b91627fb7a1" "1f42e34be9bb8d8c3a0e92d2ee364b36ba53cb01b333647f59ec33819d431db3" "c894a56116645f4ecc49d1e46efe264e90167e6b6d0b2cc52afa0591df093e86" "2851e908774931743308a22752be2d3f2248f399f0a22ad55e352e83b7b394fc" "48e0702c3282942f80b07653babed41b3c277c761143da814c944eaa05a55e63" "0d195830e225acc2b00c721cbe639c56fbcb92324683e3e4f8c77a9acdf744a2" "b28497c33ac373a44a2e856431b026c945d80a24006da31e2b621815c56c6120" "0dab0b5f6dad08eade3850eb161091409e145f01c1b9b7d6ad2c45e4f1305910" "948207e736b69e29eb7e37ace3ef1c1ae71564c2c620524e26e763993eb00315" "884ebbebac0d9c5a34e31b34fc864c63b78e34091f6f1681cad8b226678d7188" "f3466205d272fde41ed2d520354d23a7d783c21967e124d366dcdb4b3e0933d5" "79296f46ef63f6b83fbe72d4a4743fdeaaf1dfce49e3a74973b55154f0d9a149" "2fd7eefb555e4482871410d282a2a60353a1d0371b49be4b2376be9f8f7be7bd" "8b77af8a46cf1bb55249f1556d455870a369df6aaf0f8075d79aa5a911dffcb7" "f244fa8ae485a4837101e23d05b1d659b43c7a329a7e337946bf9a5c55f8534e" "8c3cc2c9939a938ee7147734d18b16abe050b78273c8bed65722b63d1bbb9655" "cf41b99c633032f5959682e794dfbf215d65da6292774ad58947c438ef82f0b2" "7d365621b4bfc5612dcafd12402bbdf0483eb68bf2165db5a374e77dbeab3e13" "807ed55cbb66b7a89ab76e57867301db65985f122cf2eea7d5e42a70136e59bb" "126c33978a01830c4833538355375f8c08eae394b291144d59d484556dfb6035" "b7384c52496a84a497f3be45fc2bd11c7537a5cb45fb24a96a5d0fe4adc8d063" "81a80501ffc17bfc223b716f8b92ab44db83180d72be0dfb81b86e26600acccb" "0a8cda467f8877d63cb664b813886530b1464edf1d6caa8c99a7b6e6dc8e280d" "60887ff5aff5433f48ff54080ee5c1d359e0b05488b09e4bee2b57cbd7a3e02d" "0a8fc574d916a9535ec0dea699c46bbe70f243056c9dd6a8ab5d47eed0dc141d" "592ae0dd0ec957f2c907a7f7a30ae2f5827d2ed250e19c885581a73214a2eac2" "58e0d50df2433f410385c1409423976f3b32bf1e47307c49ecc038fbd6b340b7" "8c206fc129a07f1fbc06a3ecc037055d40666e488493b13c4fd66360e873bec0" "a0d5cf0975a03ef8d87d266b7734dd023cf9a2f945a5d0d58b965d4a5f4d32aa" "266650889527eaf98052f29ac3f4e893ae8a6d6321e458211a8bdbc438cde6cd" "f922fa8e72206057bbb03fd97f5f8cf0dd46453f4340a456119dde4d035c456f" "f3d286c611a7bc0c6fc4768214ed2f519caac08e9e37a7a2a6a54704d16974a8" "06462c67a7248c9f64ec5871dd55b5bdb6cce6ce1650f9a8c0f3cbccef40c25d" "612d9a11a1106e6be8289cb92bb35c9705c2763753fae63ed691625f28e2a297" "edb7bf9c0c90d876eddac1fb7d30cf3aacac6e641086c1682339e4c32bd9efc6" "483c8db96b11433940fbdc93a35cce3c8bb9a83e5f2543a2794a7084172325f8" "c39af6503b48bd62ff54eb74d9e698ae0bffa50a07c25e452cbbf404709fe68a" "280398092465ca3309d07e319eccb71b2c65ecd16cffade8a5603f5af9f18ad0" "723c64ace3d49f8a0360c5d5087aa9663cddddeea2cdb6c890b08bd72131a867" "a9fa7291ccd83a0d95ef8053dd40650a18df15c3929d619ba98ed9bcb6242ece" "5836ccd5bbe83ecd2ae4f9fba0710e3da042b29ddbd08db7093ce4fe0d8c2e1f" "07c1db2a33937248379ed09276fdb18546d2c14d6aea24f0e56e2e6475f1d744" "ea300c9f9a2347e4e7f7649bcb6d388e9d4d2f910165448ca5cd182e64979ecf" "465e8af6c3f96e6f9b223254f01ea5fa1466947d7b6ddc05b110b941547027e6" "2c9e747697f118a3b783f225f870253d8c8a82d07e5e6792823ae221feaad774" "e3fa99e5f8b633ecfa8224ee37dccc8c817b645990a1785689781d5ca71c1acb" "5b8e82b11285fe4a69075ed7c2f65764f30f995a09a81a70fe1a349bc237215e" "db740c2ce02d6737831478fa04f6a448b81c7c9a39a0d3b21156d5fbfd0184d5" "db39649317db2572b511c14044e10a89fae1b6388366073441b316d0aa767632" "1f4fbc1fcfc1629d02b80956cddd2afe876544167e47912cadc00d196515a659" "cd5c6cffe85bd206a0ca011af9265548bd1baeb56b5a17c1c59052d922c0fd9a" "6eaceb39d06c5c7db6f2c8a91ea9ce7008ae359e6d90836970a5d5e93778b4b1" "51c6fa1a6431128c7dbe86d1a203bf5aef8e754cc909c2f0bf7f302d624e755f" "ba83c0abc1b0191f13c0bc42cf95d43d0c04e92dcac2f80c42659d1e7761747e" "dbf48951bde88bb384a862703000b9b0df03091d83fa420207d6aa679fe21f3f" "c452a9b70a1a4f9f8749dd52debb76569fc0f3200b1f69a3e0567121309d54ba" "7f034f0a6eec3d3c94f61be8ffaf74872de9f9fc76d32bff51aa147c449d3573" "0e32c9d83e302ddf108cd76e3e004c1da323a59180e1b62289cfce9d88711bc8" "5f3f390d14025a333c9d0c94be2a71f113c774af92d46b68ea8190381e340324" "8c8a4346dce2f37d64f7067eeaf26a7656827429dddf851460aa0d7dc5d36f67" "877b6a0d588e2225b9bb8be2144345bbaa671e8ad1e5a76ffbc518e1ecc2aabd" "433e5341663ba3f0bf7b6bd39d8aff05d6fd2501c86997089010b91d6a3b5a34" "00e6ebb7a021730a9e155a97edb8d8610e60c14ef63e00b33cc846b2ee8d4ec9" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "235dc2dd925f492667232ead701c450d5c6fce978d5676e54ef9ca6dd37f6ceb" "1db337246ebc9c083be0d728f8d20913a0f46edc0a00277746ba411c149d7fe5" "938d8c186c4cb9ec4a8d8bc159285e0d0f07bad46edf20aa469a89d0d2a586ea" "6de7c03d614033c0403657409313d5f01202361e35490a3404e33e46663c2596" "ed317c0a3387be628a48c4bbdb316b4fa645a414838149069210b66dd521733f" "38e64ea9b3a5e512ae9547063ee491c20bd717fe59d9c12219a0b1050b439cdd" "a93bb5819f8e572e61be35e5645a5b9393434525a1c8989a6519724ad5dcc647" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06b2849748590f7f991bf0aaaea96611bb3a6982cad8b1e3fc707055b96d64ca" "fe230d2861a13bb969b5cdf45df1396385250cc0b7933b8ab9a2f9339b455f5c" "331433979cba7e5db23375e231e9216b2eb1d0b7977a3b327560b4dd6a2ef1ec" "4d886950135ac65bcaeaad1b7cba07696889ee6cec5b0337de561ea883ee99d6" "bd583f860cb323b5083f8bec3216d877561210ae820cb508d7a6ae2b73b3cff9" "a388014bace6f437697718697d7851ef57f4f1cb069a4b48444b0dcbdb5fd048" "cd0ae83bc6c947021a6507b5fbae87c33411ff8d6f3a9bf554ce8fed17274bf8" default)))
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
 '(pop-up-frames nil)
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

;; Display buffer in current window
(add-to-list 'same-window-buffer-names "*Completions*")
(add-to-list 'same-window-buffer-names "*Help*")
(add-to-list 'same-window-buffer-names "*Buffer List*")
(add-to-list 'same-window-buffer-names "*find files*")
(add-to-list 'same-window-buffer-names "*helm find files*")
(add-to-list 'same-window-buffer-names "*helm M-x*")
(add-to-list 'same-window-buffer-names "*helm mini*")

;; Always follow symbolic links
(setq vc-follow-symlinks t)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Terminus" :foundry "xos4" :slant normal :weight normal :height 105 :width normal)))))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
