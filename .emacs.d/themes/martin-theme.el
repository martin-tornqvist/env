(deftheme martin
  "Created 2018-03-05.")

(custom-theme-set-variables
 'martin
 '(ansi-color-names-vector ["#212121" "#CC5542" "#6aaf50" "#7d7c61" "#5180b3" "#DC8CC3" "#9b55c3" "#bdbdb3"]))

(custom-theme-set-faces
 'martin
 '(button ((t (:underline t))))
 '(link ((t (:foreground "#7d7c61" :underline t :weight bold))))
 '(link-visited ((t (:foreground "#baba36" :underline t :weight normal))))
 '(cursor ((t (:background "white"))))
 '(escape-glyph ((t (:foreground "#7d7c61" :bold t))))
 '(fringe ((t (:foreground "#bdbdb3" :background "#212121"))))
 '(header-line ((t (:box (:line-width -1 :style released-button) :background "#3b3b3b" :foreground "#7d7c61"))))
 '(highlight ((t (:background "#282828"))))
 '(success ((t (:inherit default :foreground "#6aaf50" :weight bold))))
 '(warning ((t (:inherit default :foreground "#fb8512" :weight bold))))
 '(error ((t (:inherit default :foreground "#AA5542" :weight bold))))
 '(menu ((t (:foreground "#bdbdb3" :background "#212121"))))
 '(minibuffer-prompt ((t (:foreground "#7d7c61"))))
 '(mode-line ((((class color) (min-colors 89)) (:foreground "#c9c9c9" :background "#000000" :box (:line-width -1 :style released-button))) (t :inverse-video t)))
 '(mode-line-buffer-id ((t (:foreground "#6a7550"))))
 '(mode-line-inactive ((t (:background "gray20" :foreground "#9b9b9b" :box nil))))
 '(region ((t (:background "#3b3b3b" :foreground "gray80"))))
 '(secondary-selection ((t (:background "#0a0a0a"))))
 '(trailing-whitespace ((t (:background "#CC5542"))))
 '(vertical-border ((t (:foreground "#bdbdb3"))))
 '(scroll-bar ((t (:background "#0a0a0a" :foreground "#9b9b9b"))))
 '(match ((t (:background "#3b3b3b" :foreground "#fb8512"))))
 '(isearch ((t (:background "darkgreen" :foreground "white"))))
 '(isearch-fail ((t (:background "red4" :foreground "#bdbdb3"))))
 '(lazy-highlight ((t (:background "#2e2e2e" :foreground "#baba36"))))
 '(font-lock-builtin-face ((t (:foreground "#bdbdb3"))))
 '(font-lock-comment-face ((t (:foreground "gray50"))))
 '(font-lock-constant-face ((t (:foreground "#6a7550"))))
 '(font-lock-doc-face ((t (:foreground "#6a9550"))))
 '(font-lock-function-name-face ((t (:foreground "darkolivegreen3"))))
 '(font-lock-keyword-face ((t (:foreground "navajowhite4"))))
 '(font-lock-negation-char-face ((t (:foreground "red"))))
 '(font-lock-preprocessor-face ((t (:foreground "#6380b3"))))
 '(font-lock-regexp-grouping-construct ((t (:foreground "#7d7c61"))))
 '(font-lock-regexp-grouping-backslash ((t (:foreground "#6aaf50"))))
 '(font-lock-string-face ((t (:foreground "forestgreen"))))
 '(font-lock-type-face ((t (:foreground "NavajoWhite4"))))
 '(font-lock-variable-name-face ((t (:foreground "goldenrod"))))
 '(font-lock-warning-face ((t (:foreground "#baba36"))))
 '(show-paren-mismatch ((t (:background "#212121" :foreground "#ff5542"))))
 '(show-paren-match ((t (:background "#888888" :foreground "#000000"))))
 '(whitespace-space ((t (:background "#141414" :foreground "#141414"))))
 '(whitespace-hspace ((t (:background "#141414" :foreground "#141414"))))
 '(whitespace-tab ((t (:background "#dd5542"))))
 '(whitespace-newline ((t (:foreground "#141414"))))
 '(whitespace-trailing ((t (:background "darkred"))))
 '(whitespace-line ((t (:background "black" :foreground "red"))))
 '(whitespace-space-before-tab ((t (:background "#fb8512" :foreground "#fb8512"))))
 '(whitespace-indentation ((t (:background "#7d7c61" :foreground "#CC5542"))))
 '(whitespace-empty ((t (:background "#7d7c61"))))
 '(whitespace-space-after-tab ((t (:background "#7d7c61" :foreground "#CC5542"))))
 '(which-func ((t (:foreground "#6a7550"))))
 '(default ((t (:background "gray13" :foreground "wheat3")))))

(provide-theme 'martin)
