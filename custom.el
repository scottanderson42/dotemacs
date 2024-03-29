
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Buffer-menu-name-width 50)
 '(Info-additional-directory-list '("~/info"))
 '(ahs-default-range 'ahs-range-whole-buffer)
 '(align-c++-modes '(c++-mode c-mode java-mode js2-mode sql-mode js-mode))
 '(align-sq-string-modes '(perl-mode cperl-mode python-mode sql-mode))
 '(archive-zip-extract '("unzip" "-p" "-q"))
 '(blink-cursor-mode nil)
 '(coffee-tab-width 2)
 '(column-number-mode t)
 '(comint-scroll-show-maximum-output nil)
 '(comment-auto-fill-only-comments t)
 '(compilation-auto-jump-to-first-error nil)
 '(compilation-scroll-output 'first-error)
 '(compilation-window-height nil)
 '(compile-command "setup build")
 '(completion-ignored-extensions
   '(".svn/" "CVS/" ".o" "~" ".bin" ".bak" ".obj" ".map" ".a" ".ln" ".blg" ".bbl" ".elc" ".lof" ".glo" ".idx" ".lot" ".dvi" ".fmt" ".tfm" ".pdf" ".class" ".fas" ".lib" ".lo" ".la" ".toc" ".aux" ".cp" ".fn" ".ky" ".pg" ".tp" ".vr" ".cps" ".fns" ".kys" ".pgs" ".tps" ".vrs" ".frx" ".pyc" ".pyo"))
 '(confirm-kill-emacs 'y-or-n-p)
 '(css-indent-offset 2)
 '(cua-enable-cua-keys nil)
 '(custom-safe-themes
   '("0f62b27df04d9dc289b27e08e0654b3284f1e3e0da7e1868a590d44d57cce63b" "c5a044ba03d43a725bd79700087dea813abcb6beb6be08c7eb3303ed90782482" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" "756597b162f1be60a12dbd52bab71d40d6a2845a3e3c2584c6573ee9c332a66e" "3b1a6b4b63da8fd700e5e4d8567a036d699c466f9b577f537673f534e43e50e9" "ad6cc95aaccc13c323416675689d0f1793c9f16abf27f727ba2584069d4e5582" "203ddb182ff98db9e7782bba9e0ffeead133d66058b745194399f92344ed52fd" "9cefaad7843d750b141d79a26dc121beb9c367eea5839f91091c6b095fedc629" "c7cd81771525ff66c105413134cdf0330b0b5b88fd8096e5d56b0256872ba6c7" default))
 '(dictionary-create-buttons nil)
 '(dictionary-default-dictionary "gcide")
 '(dictionary-use-single-buffer t)
 '(dired-dnd-protocol-alist nil)
 '(dired-dwim-target t)
 '(dired-omit-extensions
   '(".o" "~" ".bak" ".obj" ".ln" ".blg" ".bbl" ".elc" ".lof" ".glo" ".idx" ".lot" ".dvi" ".fmt" ".tfm" ".class" ".fas" ".lib" ".lo" ".la" ".toc" ".aux" ".cp" ".fn" ".ky" ".pg" ".tp" ".vr" ".cps" ".fns" ".kys" ".pgs" ".tps" ".vrs" ".pyc" ".pyo" ".idx" ".lof" ".lot" ".glo" ".blg" ".bbl" ".cp" ".cps" ".fn" ".fns" ".ky" ".kys" ".pg" ".pgs" ".tp" ".tps" ".vr" ".vrs"))
 '(dired-omit-files "^\\.?#\\|^\\.$\\|^\\.\\.\\|__pycache__$")
 '(dired-recursive-copies 'top)
 '(dired-recursive-deletes 'top)
 '(electric-pair-pairs '((34 . 34) (96 . 96)))
 '(electric-pair-skip-whitespace nil)
 '(emacsw32-max-frames nil)
 '(emacsw32-style-frame-title t)
 '(find-file-run-dired t)
 '(flycheck-disabled-checkers '(javascript-eslint javascript-gslint))
 '(flyspell-auto-correct-binding [ignore])
 '(font-lock-global-modes t)
 '(font-lock-maximum-decoration t)
 '(font-lock-support-mode 'jit-lock-mode)
 '(frame-background-mode 'dark)
 '(frame-resize-pixelwise t)
 '(git-commit-finish-query-functions nil)
 '(git-commit-setup-hook
   '(git-commit-save-message git-commit-turn-on-auto-fill git-commit-turn-on-flyspell))
 '(git-commit-summary-max-length 80)
 '(grep-command "grep -sHInr -e ")
 '(gud-pdb-command-name "python3 -m pdb")
 '(helm-for-files-preferred-list
   '(helm-source-files-in-current-dir helm-source-buffers-list helm-source-recentf helm-source-file-cache))
 '(html-pagetoc-max 4)
 '(html-pagetoc-min 2)
 '(html-pagetoc-tocheads nil)
 '(imenu-auto-rescan t)
 '(inhibit-startup-echo-area-message "mkleehammer")
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(jit-lock-stealth-time 7)
 '(jit-lock-stealth-verbose nil)
 '(js-indent-level 2)
 '(js2-basic-offset 2)
 '(js2-highlight-external-variables t)
 '(js2-imenu-enabled-frameworks '(jquery backbone))
 '(js2-include-node-externs t)
 '(js2-mode-show-parse-errors nil)
 '(large-file-warning-threshold 100000000)
 '(lc-complete-idle-time-default 0.2)
 '(lc-ignored-file-extensions-external
   '("CVS/" ".o" "~" ".bin" ".bak" ".obj" ".map" ".a" ".ln" ".blg" ".bbl" ".elc" ".lof" ".glo" ".idx" ".lot" ".dvi" ".fmt" ".tfm" ".pdf" ".class" ".fas" ".lib" ".x86f" ".sparcf" ".lo" ".la" ".toc" ".aux" ".cp" ".fn" ".ky" ".pg" ".tp" ".vr" ".cps" ".fns" ".kys" ".pgs" ".tps" ".vrs" ".frm"))
 '(load-prefer-newer t)
 '(ls-lisp-ignore-case t)
 '(ls-lisp-verbosity nil)
 '(magit-branch-read-upstream-first nil)
 '(magit-completing-read-function 'magit-ido-completing-read)
 '(magit-diff-auto-show '(commit log-oneline log-select blame-follow))
 '(magit-log-arguments '("--graph" "--color" "--decorate"))
 '(magit-merge-arguments '("--ff-only"))
 '(magit-pull-arguments '("--rebase"))
 '(magit-stage-all-confirm nil)
 '(magit-status-buffer-switch-function 'switch-to-buffer)
 '(make-backup-files nil)
 '(makeinfo-options "--fill-column=95")
 '(minimap-always-recenter nil)
 '(next-error-recenter '(4))
 '(noticeable-minibuffer-prompts-mode nil)
 '(nxhtml-skip-welcome t)
 '(org-agenda-files '("~/todo.org"))
 '(package-selected-packages
   '(yafolding json-navigator realgud helm-w3m w32-browser w3 js2-mode auto-complete ido-completing-read+ python-mode zop-to-char yaml-mode ws-butler whole-line-or-region web-mode use-package undo-tree string-inflection smex scss-mode sass-mode rjsx-mode reveal-in-osx-finder projectile multiple-cursors markdown-mode magit less-css-mode jedi iedit ido-vertical-mode ido-ubiquitous hydra git-timemachine git-gutter fuzzy flymake-coffee flycheck flx-ido exec-path-from-shell elpy drag-stuff coffee-mode browse-kill-ring avy ag))
 '(pr-gs-command "c:/bin/gs/gs8.14/bin/gswin32c.exe")
 '(pr-gv-command "C:\\Program Files\\Ghostgum\\gsview\\gsview32.exe")
 '(projectile-globally-ignored-directories '(".git" ".hg" ".svn"))
 '(projectile-globally-ignored-file-suffixes '(".exe" ".pyc" ".pyo" ".dll"))
 '(projectile-globally-ignored-files '("TAGS" ".DS_Store" "*.pdf" "*.elc"))
 '(projectile-indexing-method 'alien)
 '(rmail-mail-new-frame t)
 '(rng-nxml-auto-validate-flag nil)
 '(safe-local-variable-values '((py-indent-offset . 2)))
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(speedbar-frame-parameters
   '((background-color . "black")
     (minibuffer)
     (width . 20)
     (border-width . 0)
     (menu-bar-lines . 0)
     (tool-bar-lines . 0)
     (unsplittable . t)
     (left-fringe . 0)
     (cursor-color . "white")))
 '(speedbar-use-images nil)
 '(sunshine-location "Argyle, TX")
 '(sunshine-show-icons t)
 '(tool-bar-mode nil)
 '(tramp-default-method "rsync")
 '(truncate-partial-width-windows nil)
 '(undo-tree-mode-lighter "")
 '(vc-dired-terse-display t)
 '(web-mode-enable-auto-quoting nil)
 '(window-resize-pixelwise t))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "cornflower blue"))))
 '(flx-highlight-face ((t (:inherit font-lock-variable-name-face :foreground "cyan2"))))
 '(magit-branch ((t (:background "IndianRed4" :foreground "White" :box (:line-width 2 :color "IndianRed4")))))
 '(magit-branch-local ((t (:foreground "LightSkyBlue1"))))
 '(magit-diff-context-highlight ((t (:foreground "white"))))
 '(magit-key-mode-switch-face ((t (:foreground "red"))))
 '(magit-log-author ((t (:foreground "Dodger Blue"))))
 '(magit-log-sha1 ((t (:foreground "Dodger Blue"))))
 '(magit-section-highlight ((t nil)))
 '(markdown-header-delimiter-face ((t (:inherit markdown-header-face :weight normal))))
 '(markdown-header-face ((t (:foreground "gold"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.25))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :foreground "gold3" :height 1.2))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :foreground "goldenrod"))))
 '(markdown-inline-code-face ((t (:inherit font-lock-constant-face :foreground "DarkGoldenRod"))))
 '(markdown-list-face ((t (:inherit markdown-header-face))))
 '(org-level-1 ((t (:foreground "#FAED44"))))
 '(org-level-2 ((t (:foreground "#FAC73F"))))
 '(org-level-3 ((t (:foreground "#F9A03B"))))
 '(org-level-4 ((t (:foreground "#F85436"))))
 '(org-level-5 ((t (:foreground "#D13149"))))
 '(rst-adornment ((t (:foreground "NavajoWhite1"))))
 '(rst-block ((t (:inherit rst-level-1))))
 '(rst-level-1 ((t (:foreground "NavajoWhite1"))))
 '(rst-level-2 ((t (:foreground "NavajoWhite1"))))
 '(rst-level-3 ((t (:foreground "NavajoWhite3"))))
 '(swiper-line-face ((t (:background "DeepSkyBlue4" :foreground "white")))))
