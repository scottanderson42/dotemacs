(deftheme mkleehammer
  "Created 2011-06-27.")

(custom-theme-set-variables
 'mkleehammer
 )

(custom-theme-set-faces
 'mkleehammer
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "gray93" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :foundry "outline" :family "Consolas"))))
 '(ediff-current-diff-B ((((class color) (min-colors 16)) (:background "Yellow" :foreground "DarkOrchid"))))
 '(font-lock-builtin-face ((t nil)))
 '(font-lock-comment-face ((((class color) (min-colors 88) (background dark)) (:foreground "DeepSkyBlue1"))))
 '(font-lock-constant-face ((((class color) (min-colors 88) (background dark)) nil)))
 '(font-lock-doc-face ((t (:inherit font-lock-comment-face))))
 '(font-lock-function-name-face ((((class color) (min-colors 88) (background dark)) (:foreground "DeepSkyBlue1"))))
 '(font-lock-keyword-face ((t nil)))
 '(font-lock-string-face ((((class color) (min-colors 88) (background dark)) nil)))
 '(font-lock-type-face ((t (:inherit font-lock-function-name-face))))
 '(font-lock-variable-name-face ((((class color) (min-colors 88) (background dark)) nil)))
 '(highlight ((t (:foreground "black" :background "darkseagreen2"))))
 '(match ((((class color) (min-colors 88) (background dark)) (:foreground "LightBlue1"))))
 '(mode-line ((t (:inverse-video t :foreground "slateblue4" :background "white"))))
 '(mode-line-inactive ((default (:inherit mode-line)) (((class color) (min-colors 88) (background dark)) (:background "grey60" :foreground "slateblue4" :box (:line-width -1 :color "grey10") :weight light))))
 '(region ((t (:foreground "white" :background "SlateBlue4"))))
 '(secondary-selection ((t (:foreground "black" :background "paleturquoise"))))
 '(show-paren-match ((((class color) (background dark)) (:background "black" :foreground "dark turquoise"))))
 '(show-paren-mismatch ((((class color)) (:background "red" :foreground "white"))))
 '(variable-pitch ((t (:family "Calibri")))))

(provide-theme 'mkleehammer)
