
;;; Notes ----------------------------------------------------------------------

;; If something goes wrong, run emacs with "--debug-init" to get a stack trace.
;; If you are on OS X, you can use:
;;
;;   $ open -n /Applications/Emacs.app --args --debug-init


;;; Minimal Setup --------------------------------------------------------------

;; Get keys, fonts, and colors setup early so if something goes wrong
;; troubleshooting won't be so frustrating.

(when (eq system-type 'darwin)
  ;; On Mac make the Cmd key Meta.  First, it is much more comfortable to use
  ;; than Option and has the added benefit of being in the same place as Alt on
  ;; Windows keyboards making it easier to switch back and forth.
  (setq mac-option-key-is-meta nil
        mac-command-key-is-meta t
        mac-command-modifier 'meta
        mac-option-modifier 'hyper)

  ;; The mouse wheel is crazy fast by default.
  ;; http://krismolendyke.github.io/.emacs.d/#sec-7
  (setq mouse-wheel-scroll-amount '(0.01)
        mouse-wheel-progressive-speed nil
        scroll-step 1)

  (if (find-font (font-spec :name "Inconsolata-20"))
      (set-frame-font "Inconsolata-20") ; http://levien.com/type/myfonts/inconsolata.html
      ;; (set-frame-font "Source Code Pro-20") ; https://github.com/adobe/Source-Code-Pro
      ;; (set-frame-font "Inconsolata-24") ; http://levien.com/type/myfonts/inconsolata.html
      ;; (set-frame-font "Inconsolata-18") ; http://levien.com/type/myfonts/inconsolata.html
    ;; (set-frame-font "Hack-20") ; https://github.com/chrissimpkins/Hack#about
    )
  )

(when (eq system-type 'windows-nt)
  (if (find-font (font-spec :name "Inconsolata-14"))
      (set-frame-font "Inconsolata-14")
    ;; (set-frame-font "Consolas-14")
    ))

;; A good idea in general, but particularly helpful with package-list-packages
;; for MELPA stable which apparently has a package with a Unicode name.

(prefer-coding-system 'utf-8)


;;; Custom File ----------------------------------------------------------------

;; Normally changes made through the emacs customization interface are stored in
;; your init.el file.  Move them to a separate file.

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)


;;; Theme ----------------------------------------------------------------------

(let ((theme "~/.emacs.d/dark-plain-theme.el"))
  (if (file-exists-p theme)
      (load-file theme)))


;;; Personal Information -------------------------------------------------------

(setq user-full-name "Michael Kleehammer"
      user-mail-address "michael@kleehammer.com")


;;; Package Sources ------------------------------------------------------------

;; Add MELPA stable to the list of package repositories.  Stable only builds
;; commits with version tags, so it has proper version numbers and only builds
;; things the author intended to be a release.  Normal MELPA builds whatever's
;; been committed to master and uses the date as a version.

;; emacs-async is breaking normal installations.  It might be because I am
;; loading a few packages from /misc?  It doesn't matter - *anything* in the
;; packaging system needs to be bullet proof.  Reading the bug reports doesn't
;; give me a lot of confidence.
(setq async-bytecomp-allowed-packages nil)

(require 'package)

(setq package-archives
      (append package-archives
              '(("gnu" . "http://elpa.gnu.org/packages/")
                ("melpa-stable" . "http://stable.melpa.org/packages/"))))

(package-initialize)
(setq package-enable-at-startup nil)

(unless package-archive-contents
  (message "Refreshing ELPA package archives...")
  (package-refresh-contents))

;; Make sure the fantastic use-package macro is installed.

(unless (package-installed-p 'use-package)
  (message "Installing use-package")
  (package-install 'use-package))

(require 'use-package)


;;; Look and Feel --------------------------------------------------------------

;; Hide the toolbar, etc. and include the buffer name in the window title.  On
;; Mac ("ns-") don't pop up alerts - use the message buffer.

(when window-system
  (tooltip-mode -1)
  (tool-bar-mode -1)

  (setq frame-title-format "%b - emacs"
        icon-title-format "%f - emacs"
        ns-pop-up-frames nil))

;; Remove the clock from the mode line since the OS has one and add columns.
;; Show line numbers on the left.  The default is to show 3 digits, but that's
;; not nearly enough for log files.

(setq global-mode-string '("")
      column-number-mode t)

(global-linum-mode 1)
(setq line-number-display-limit nil
      line-number-display-limit-width 1000000)

;; Default to no line wrapping but have "C-x l" to toggle.

(setq-default truncate-lines t)
(global-set-key (kbd "C-x l") 'toggle-truncate-lines)


;;; System Tweaks --------------------------------------------------------------

;; I don't know why this option even exists, but if you don't set it to true,
;; emacs will use compiled code that is old over newer source.  That is a
;; /really/ bad default.  However, since I'm using use-package whenever
;; possible, this matters a lot less.
(setq load-prefer-newer t)

;; Replace "yes" and "no" prompts with a simple y/n keypress.
(fset 'yes-or-no-p 'y-or-n-p)

;; Turn off backups and auto-save.
(setq backup-inhibited t
      auto-save-default nil
      create-lockfiles nil
      delete-old-versions t)
(auto-save-mode nil)

;; Anyone working around me will appreciate it if emacs doesn't ding every time
;; I hit the wrong key...
(setq ring-bell-function 'ignore)

;; Set window splitting back to its old behavior.  I forgot the difference -
;; need to document this.
(setq split-width-threshold most-positive-fixnum)

;; If I remember correctly, this ensures that when if you page down, paging up
;; puts the cursor in the same place.
(setq scroll-preserve-screen-position 'always)

;; Enable some really handy functions.  These already have keys assigned and
;; will ask you for confirmation when you execute them unless you enable them.
(put 'narrow-to-region 'disabled nil)
(put 'erase-buffer     'disabled nil)
(put 'downcase-region  'disabled nil)
(put 'upcase-region    'disabled nil)
(put 'narrow-to-page   'disabled nil)


(defun save-all()
  "Save all buffers without prompting"
  (interactive) (save-some-buffers t))
(global-set-key (kbd "C-x s") 'save-all)
;; Normally C-x s prompts for each buffer, which is safe but I don't think I've
;; ever not saved.  In projects that monitor directories and rebuild I often
;; don't save individual files and save all at once to keep the rebuild from
;; happening over and over.  (If it was fast enough I wouldn't care...)  Since
;; I'm using this a lot, it is more convenient to have the key not prompt.


;;; Editing Tweaks -------------------------------------------------------------

;; Default to text-mode intead of fundamental-mode and 4-space tabs.  Turn on
;; word wrapping (auto-fill) in text mode and wrap at 95.  This width is about
;; right for printed text on US letter.

(setq major-mode 'text-mode
      initial-major-mode 'text-mode)
(setq-default tab-width 4
              indent-tabs-mode nil)

(defun personal-text-mode-hook ()
  (turn-on-auto-fill))
(add-hook 'text-mode-hook 'personal-text-mode-hook)

(setq-default fill-column 95)

;; Automatically move the mouse cursor out of the way of the emacs cursor.
(mouse-avoidance-mode 'animate)

;; Insert a closing paren or quote character.  Since I almost always have to
;; type the ending one or move right to pass it, I'm not sure this is really
;; helping.  I do like closing Javascript braces though.  This might need
;; tweaking.
;; (electric-pair-mode t)

(use-package paren
  ;; Highlight matching parens.
  :config
  (show-paren-mode 1))


;;; Global Key Bindings --------------------------------------------------------

;; Key bindings for external packages are set where the package is loaded.

(use-package hydra
  :ensure t)

;; I want to use standard emacs keys where possible but I like CUA's rectangle
;; mode.  If you just enable cua mode, it does weird things to try to match Windows
;; keys.  I know it sounds tempting, but don't.

;; I may be switching from this soon.  Multiple cursor helps and I believe built-in
;; rectangle commands are coming in emacs 25.

(cua-mode t)
(setq cua-auto-tabify-rectangles nil)   ; Don't tabify after rectangle commands
(cua-selection-mode t)                  ; Use rectangle mode, etc., but continue to use emacs keys.

;; Some familiar Windows bindings that don't interfere with standard emacs keys.

(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<end>") 'end-of-line)
(global-set-key (kbd "C-<home>") 'beginning-of-buffer)
(global-set-key (kbd "C-<end>") 'end-of-buffer)
(global-set-key (kbd "C-<backspace>") (quote backward-kill-word))

;; Hopping between visible buffers is something I do a lot so a key without a
;; prefix is necessary.  To help me remember, I've disabled the original key and
;; put a message in to remind (annoy) me.

(global-set-key (kbd "M-o") 'other-window)

(global-set-key (kbd "C-x o") 'mk/annoy-other-window)
(defun mk/annoy-other-window()
  (interactive)
  (message "Use M-o instead!"))

;; Replacing is something else I do a lot so a quick key is needed.  (Once you
;; get used to buffer narrowing, search and replace becomes a lot more powerful.)

(global-set-key (kbd "C-c r") 'replace-string)

;; The cycle-spacing function does the job of multiple functions.  Replace
;; delete-horizontal-whitespace.  Particularly useful since Cmd-SPC is used by
;; spotlight on OS X.
;;
;; Note that a function that behaves differently based on how many times you call
;; it in a row is something I'm seeing more of.  C-l used to just recenter the
;; window, but at some point pressing it again moves the line to the top and then
;; to the bottom.  M-r behaves similarly.

(global-set-key "\M-\\" 'cycle-spacing)

;; To open info directly to a manual, e.g. "Python".  I really need to use this
;; more.

(global-set-key (kbd "C-x C-i") 'info-display-manual)

;; Recolor the current buffer.  This is handy when you paste from one type of
;; buffer to another and emacs keeps the previous buffer's coloring (or when
;; emacs just gets confused).  I haven't needed this as much as I used to.

(global-set-key (kbd "<f6>") 'font-lock-fontify-buffer)


;;; OS Integration -------------------------------------------------------------

;; Copy the PATH from the shell.  On OS X, GUI programs don't pick up
;; environment variables from your login shell.

(use-package exec-path-from-shell
  :ensure t
  :if (eq system-type 'darwin)
  :config (exec-path-from-shell-initialize))


;; Support drag-and-drop in OS X.  (I think it already works on Windows.)
;;
;; - normally the file opens a new buffer
;; - Holding meta inserts file contents instead
;; - Holding shift inserts filename instead
;;
;; Emacs must be the current window for this to work.  However, you can Cmd-tab
;; while dragging to make it current.

(when (eq system-type 'darwin)
  (define-key global-map [M-ns-drag-file] 'ns-insert-file)
  (define-key global-map [S-ns-drag-file] 'ns-insert-filename)
  (define-key global-map [ns-drag-file] 'ns-find-file-in-frame)

  (defun ns-insert-filename ()
    "Insert contents of first element of `ns-input-file' at point."
    (interactive)
    (let ((f (pop ns-input-file)))
      (insert f))
    (if ns-input-file                     ; any more? Separate by " "
        (insert " ")))

  (defun ns-find-file-in-frame ()
    "Do a `find-file' with the `ns-input-file' as argument; staying in frame."
    (interactive)
    (let ((ns-pop-up-frames nil))
      (ns-find-file))))


(defun sudo-edit (&optional arg)
  "Edit currently visited file as root.

With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
  ;; From http://emacsredux.com/blog/2013/04/21/edit-files-as-root/
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))


;;; dired ----------------------------------------------------------------------

;; This allows dired-x to intercept find-file.
(setq dired-x-hands-off-my-keys nil)

(add-hook 'dired-mode-hook (lambda () (dired-omit-mode t)))

(eval-after-load "dired-aux"
  '(add-to-list 'dired-compress-file-suffixes
                '("\\.zip\\'" ".zip" "unzip")))

(define-key global-map "\C-x\C-j" 'dired-jump)
(define-key global-map "\C-x4\C-j" 'dired-jump-other-window)

;; http://stackoverflow.com/questions/1431351/how-do-i-uncompress-unzip-within-emacs

(eval-after-load "dired"
  '(define-key dired-mode-map "z" 'dired-zip-files))
(defun dired-zip-files (zip-file)
  "Create an archive containing the marked files."
  (interactive "sEnter name of zip file: ")

  ;; create the zip file
  (let ((zip-file (if (string-match ".zip$" zip-file) zip-file (concat zip-file ".zip"))))
    (shell-command
     (concat "zip -9 "
             zip-file
             " "
             (concat-string-list
              (mapcar
               '(lambda (filename)
                  (file-name-nondirectory filename))
               (dired-get-marked-files))))))

  (revert-buffer)

  ;; remove the mark on all the files  "*" to " "
  ;; (dired-change-marks 42 ?\040)
  ;; mark zip file
  ;; (dired-mark-files-regexp (filename-to-regexp zip-file))
  )


(defun concat-string-list (list)
  "Return a string which is a concatenation of all elements of the list separated by spaces"
  (mapconcat '(lambda (obj) (format "%s" obj)) list " "))

(require 'dired)
(require 'dired-x)

;; Sort directories to the top like the operating systems do.
(setq ls-lisp-dirs-first t)
(when (eq system-type 'darwin)
  (setq dired-listing-switches "-lah"))

;; http://xahlee.org/emacs/emacs_dired_open_file_in_ext_apps.html

(defun open-in-external-app ()
  "Open the current file or dired marked files in external app.
Works in Microsoft Windows, Mac OS X, Linux."
  (interactive)
  (let ( doIt
         (myFileList
          (cond
           ((string-equal major-mode "dired-mode") (dired-get-marked-files))
           (t (list (buffer-file-name))))))

    (setq doIt (if (<= (length myFileList) 5)
                   t
                 (y-or-n-p "Open more than 5 files?")))

    (when doIt
      (cond
       ((string-equal system-type "windows-nt")
        (mapc (lambda (fPath) (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t))) myFileList)
        )
       ((string-equal system-type "darwin")
        (mapc (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "open" fPath)))  myFileList))
       ((string-equal system-type "gnu/linux")
        (mapc (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "xdg-open" fPath))) myFileList))))))

;; M-x reveal-in-finder
;;
;; From dired, open Finder to the current file.  No key binding since it isn't
;; used often.
(use-package reveal-in-osx-finder
  :ensure t
  :if (eq system-type 'darwin))


;;; ediff ----------------------------------------------------------------------

(defconst ediff-ignore-similar-regions t)
(defconst ediff-use-last-dir t)
(defconst ediff-diff-options " -b ") ; add "w" for ignore whitespace
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)


;;; grep -----------------------------------------------------------------------

;; Don't grep into generated directories.  I'm sure this list will get much
;; longer.  There is probably a better way to do this.
(eval-after-load "grep"
  '(progn
     (add-to-list 'grep-find-ignored-directories "node_modules")
     (add-to-list 'grep-find-ignored-directories "build")))


;; wgrep - "writable grep results".  Let's you edit the grep results and then
;; write the changes back to the original files.  Not in MELPA stable so loading
;; a local copy.
(use-package wgrep
  :load-path "misc"
  ;;:bind (("C-c C-p" . wgrep-change-to-wgrep-mode)
  ;;       ("C-x C-q" . wgrep-change-to-wgrep-mode)) ; match dired
  :config
  (progn
    ;; wgrep-finish-edit has multiple bindings, but the one that makes the most
    ;; sense to me is "C-c C-c".  Remove the others so the help text actually
    ;; displays the key I like.
    (define-key wgrep-mode-map (kbd "C-x C-s") nil)
    (define-key wgrep-mode-map (kbd "C-c C-e") nil)
    (setq wgrep-auto-save-buffer t)))



;;; Buffers --------------------------------------------------------------------

;; Eliminate the confirmation when killing a buffer by setting the standard
;; "C-x k" key to our own function.
(defun kill-current-buffer ()
  "Kill the current buffer, without confirmation."
  (interactive)
  (kill-buffer (current-buffer)))
(global-set-key (kbd "C-x k") 'kill-current-buffer)

;; Eliminate 'kill buffer' query for running processes (SQL windows, etc.).
(setq kill-buffer-query-functions
      (remove 'process-kill-buffer-query-function
              kill-buffer-query-functions))

;; When I complete a task on a project, I usually kill either everything or
;; everything except the current magit buffer.  I run these with M-x.

(defun kill-all-buffers ()
  "Kill all buffers, asking permission on modified ones."
  (interactive)
  (let ((list (buffer-list)))
    (while list
      (let* ((buffer (car list))
             (name (buffer-name buffer)))
        (and (not (string-equal name ""))
             (kill-buffer buffer)))
      (setq list (cdr list))))
  (cd "~"))

;; kill-other-buffers normally doesn't delete any special buffers (e.g. those
;; with a star like the scratch buffer).  Use C-u before running to kill all
;; other buffers.

(defun kill-other-buffers (&optional arg)
  "Kill all buffers but the current one.
Don't mess with special buffers unless prefix is provided."
  (interactive "P")
  (dolist (buffer (buffer-list))
    (unless (or
             (eql buffer (current-buffer))
             (and (not arg) (not (buffer-file-name buffer))))
      (kill-buffer buffer))))


;; Swap two buffers.  Often when I split, they are in the opposite order of what
;; I want.
;;
;; http://emacswiki.org/emacs/TransposeWindows

(defun swap-windows ()
  "*Swap the positions of this window and the next one."
  (interactive)
  (let ((other-window (next-window (selected-window) 'no-minibuf)))
    (let ((other-window-buffer (window-buffer other-window))
          (other-window-hscroll (window-hscroll other-window))
          (other-window-point (window-point other-window))
          (other-window-start (window-start other-window)))
      (set-window-buffer other-window (current-buffer))
      (set-window-hscroll other-window (window-hscroll (selected-window)))
      (set-window-point other-window (point))
      (set-window-start other-window (window-start (selected-window)))
      (set-window-buffer (selected-window) other-window-buffer)
      (set-window-hscroll (selected-window) other-window-hscroll)
      (set-window-point (selected-window) other-window-point)
      (set-window-start (selected-window) other-window-start))
    (select-window other-window)))

(define-key ctl-x-4-map (kbd "t") 'swap-windows)

;; toggle between most recent buffers

(defun switch-to-previous-buffer ()
  "Switch to most recent buffer. Repeated calls toggle back and forth between the most recent two buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(global-set-key (kbd "M-O") 'switch-to-previous-buffer)

;;; Editing --------------------------------------------------------------------


(use-package align
  ;; Set "M-[" to align current variables.  Also provides some other handy
  ;; functions such as align-cols and align-regexp.
  :bind (("M-[" . align)))

(use-package align2)


(use-package expand-region
  ;; Keep pressing "M-2" to expand the region.

  ;; This project has not added a release tag for a while.  Once use-package
  ;; gets released (ironic, yes) with a default pin, we can load this one
  ;; package from MELPA unstable.  For now, issue #130 is so annoying that I'll
  ;; just check it out here.

  ;; :ensure t
  :load-path "misc/expand-region"

  :bind (("M-2" . er/expand-region)))


(use-package zop-to-char
  ;; By default "M-z" is zap-to-char (with an "a") and is incredibly handy.
  ;; This package replaces that with *selecting* up to the character instead of
  ;; deleting.  The old behavior now requires one more key, but you have more
  ;; options.  It's worth using, but it doesn't always do what I expect so I
  ;; might need to write a simpler one.
  :ensure t
  :bind ("M-z" . zop-to-char))


(use-package whole-line-or-region
  ;; This package makes cut and copy take the whole line if there is no
  ;; selection.  Even better, if a line is copied, it is pasted back in as a
  ;; line above the current one instead of being inserted exactly where the
  ;; cursor is, possibly breaking a line.
  :ensure t
  :diminish whole-line-or-region-mode
  :config (whole-line-or-region-mode 1))


(defun dup-line ()
  "Duplicate the current line and move down to the new line."

  ;; This was my goto for duplicating the current line, but now that I've
  ;; installed whole-line-or-region I might not need it.

  (interactive nil)
  (let ((str (concat
              (buffer-substring (point) (save-excursion (end-of-line) (point)))
              "\n"
              (buffer-substring (save-excursion (beginning-of-line) (point)) (point)))))
    (insert str)))
(global-set-key (kbd "M-S-<return>") 'dup-line)
;; This binding uses the same prefix as moving lines up and down, which are
;; operations I often do together.  It is also more comfortable to use.


(use-package drag-stuff
  ;; drag-stuff allows you to use M-up/dn to "drag" text around.  Works with a
  ;; selection too.  You can also use M-left/right with selected text.  (If text
  ;; is not selected, left and right appear to try to move the current word but
  ;; does something weird with cursor placement.)
  :ensure t
  :diminish drag-stuff-mode
  :config
  (progn
    (drag-stuff-global-mode t)

    ;; drag-stuff includes the line the cursor is on even when the cursor is at
    ;; the beginning because you highlighted the lines above it:
    ;; https://github.com/rejeep/drag-stuff.el/issues/4
    ;;
    ;; Use the before and after hooks to change the region being dragged, then
    ;; change it back after to eliminate this case.

    ;; https://github.com/kaushalmodi/.emacs.d/blob/master/setup-files/setup-drag-stuff.el
    ;; http://emacs.stackexchange.com/a/13942/115
    (defvar modi/drag-stuff--point-adjusted nil)
    (defvar modi/drag-stuff--point-mark-exchanged nil)

    (defun modi/drag-stuff--adj-pt-pre-drag ()
      "If a region is selected AND the `point' is in the first column, move
       back the point by one char so that it ends up on the previous line. If the
       point is above the mark, exchange the point and mark temporarily."
      (when (region-active-p)
        (when (< (point) (mark)) ; selection is done starting from bottom to up
          (exchange-point-and-mark)
          (setq modi/drag-stuff--point-mark-exchanged t))
        (if (zerop (current-column))
            (progn
              (backward-char 1)
              (setq modi/drag-stuff--point-adjusted t))
          ;; If point did not end up being on the first column after the
          ;; point/mark exchange, revert that exchange.
          (when modi/drag-stuff--point-mark-exchanged
            (exchange-point-and-mark) ; restore the original point and mark loc
            (setq modi/drag-stuff--point-mark-exchanged nil)))))

    (defun modi/drag-stuff--rst-pt-post-drag ()
      "Restore the `point' to where it was by forwarding it by one char after
       athe vertical drag is done."
      (when modi/drag-stuff--point-adjusted
        (forward-char 1)
        (setq modi/drag-stuff--point-adjusted nil))
      (when modi/drag-stuff--point-mark-exchanged
        (exchange-point-and-mark) ; restore the original point and mark loc
        (setq modi/drag-stuff--point-mark-exchanged nil)))

    (add-hook 'drag-stuff-before-drag-hook #'modi/drag-stuff--adj-pt-pre-drag)
    (add-hook 'drag-stuff-after-drag-hook  #'modi/drag-stuff--rst-pt-post-drag)))


;; Shift the selected region right if distance is postive, left if negative.  I
;; only need this because drag-stuff doesn't always work.

(defun shift-region (distance)
  (let ((mark (mark)))
    (save-excursion
      (indent-rigidly (region-beginning) (region-end) distance)
      (push-mark mark t t)
      ;; Tell the command loop not to deactivate the mark
      ;; for transient mark mode
      (setq deactivate-mark nil))))

(defun shift-right ()
  (interactive)
  (shift-region 1))

(defun shift-left ()
  (interactive)
  (shift-region -1))

(global-set-key [M-S-right] 'shift-right)
(global-set-key [M-S-left] 'shift-left)



(defun fill-buffer ()
  "Runs fill-region on the entire buffer.  (Word wrap the entire
file."
  (interactive)
  (save-excursion
    (fill-region (point-min) (point-max))))


;; A function to insert a new line below the current without breaking the
;; current line.  This is useful because of the automatic closing quotes and
;; parens means I'm often finished typing the current line but not at the end of
;; it.

(defun newline-without-break ()
  "Insert a new line below current and move cursor there."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(global-set-key (kbd "<S-return>") 'newline-without-break)


;;; Inserting Info Into The Buffer ---------------------------------------------

(defun insert-date ()
  "Insert date in YYYY-MM-DD format at point."
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(defun uuidgen ()
  "Insert a new UUID at point."
  (interactive)
  (insert
   (downcase (substring (shell-command-to-string "uuidgen") 0 36))))

;; F11 inserts a comment with "REVIEW: ", used like "TODO".

(defun mk-insert-review ()
  (interactive)
  (comment-dwim nil)
  (insert "REVIEW: "))
(global-set-key (kbd "<f11>") 'mk-insert-review)

;; C-F11 inserts "DO NOT CHECK IN" as a comment.  (The comment character is
;; determined by the current mode.)  I sometimes set a git precommit hook to
;; reject a file if it has this.  Use this when adding something you *really*
;; don't want checked in.

(defun mk-insert-donotcheckin ()
  (interactive)
  (comment-dwim nil)
  (insert "DO NOT CHECK IN")
  (newline-and-indent))

(global-set-key (kbd "C-<f11>") 'mk-insert-donotcheckin)


;;; Search ---------------------------------------------------------------------

;; In isearch you normally press Enter to exit isearch and leave the cursor at
;; the current search result.  Pressing C-Enter will exit isearch but leave the
;; cursor at the /other/ end of the search string.

(defun isearch-exit-other-end (rbeg rend)
  "Exit isearch, but at the other end of the search string.
This is useful when followed by an immediate kill."
  (interactive "r")
  (isearch-exit)
  (goto-char isearch-other-end))

(define-key isearch-mode-map [(control return)] 'isearch-exit-other-end)


;; "M-s _" starts an isearch for the current symbols, but the binding feels very
;; different from "C-s".  Instead, use the prefix to initiate.  (This is still a
;; bit awkward to press.

(global-set-key (kbd "C-.") 'isearch-forward-symbol-at-point)

;;; Scratch Buffer -------------------------------------------------------------

;; The scratch buffer should be easy to get to.  Press F8 to go to it, creating
;; a new one if necessary.  If it is not already visible, it will be opened at
;; the bottom of the window 8 lines tall.  This is useful for taking quick notes
;; or pasting something you don't want to lose without taking over the window.

(defvar scratch-window-height 8
  "*Number of lines in scratch window.  If nil, use Emacs default.")

(defun show-scratch ()
  "Makes the scratch buffer the current one, creating it if necessary."
  (interactive)
  (let ((buf (get-buffer-create "*scratch*")))
    (pop-to-buffer buf nil)
    (scratch-set-window-height (get-buffer-window buf))
    (switch-to-buffer buf)))

(global-set-key (kbd "<f8>") 'show-scratch)


; Enlarge the current window.  Useful after compiling splits the window in half.
(global-set-key (quote [f2]) 'enlarge-window-mk)
(fset 'enlarge-window-mk "\C-u19\C-x^")


;; modified copy of compilation-set-window-height
(defun scratch-set-window-height (window)
  "Set the height of WINDOW according to `scratch-window-height'."
  (and scratch-window-height
       (= (window-width window) (frame-width (window-frame window)))
       ;; If window is alone in its frame, aside from a minibuffer,
       ;; don't change its height.
       (not (eq window (frame-root-window (window-frame window))))
       ;; This save-excursion prevents us from changing the current buffer,
       ;; which might not be the same as the selected window's buffer.
       (save-excursion
         (let ((w (selected-window)))
           (unwind-protect
               (progn
                 (select-window window)
                 (enlarge-window (- scratch-window-height
                                    (window-height))))
             ;; The enlarge-window above may have deleted W, if
             ;; scratch-window-height is large enough.
             (when (window-live-p w)
               (select-window w)))))))


;;; Miscellaneous Text Functions -----------------------------------------------

(defun uniquify-region (beg end)
  "remove duplicate adjacent lines in the given region"
  (interactive "*r")
  (goto-char beg)
  (while (re-search-forward "^\\(.*\n\\)\\1+" end t)
    (replace-match "\\1")))

(defun uniquify-buffer ()
  (interactive)
  (uniquify-region (point-min) (point-max)))


;;; System Functions -----------------------------------------------------------

(defun copy-buffer-file-name (use-backslashes)
  "Puts the file name of the current buffer (or the current directory,
if the buffer isn't visiting a file) onto the kill ring, so that it
can be retrieved with \\[yank], or by another program.  With argument,
uses backslashes instead of forward slashes."
  (interactive "P")
  (let ((fn (subst-char-in-string
             ?/
             (if use-backslashes ?\\ ?/)
             (or
              (buffer-file-name (current-buffer))
              ;; Perhaps the buffer isn't visiting a file at all.  In
              ;; that case, let's return the directory.
              (expand-file-name default-directory)))))
    (when (null fn)
      (error "Buffer doesn't appear to be associated with any file or directory."))
    (kill-new fn)
    (message "%s" fn)
    fn))

(global-set-key (quote [S-f6]) 'copy-buffer-file-name)

;; Sometimes it isn't obvious what face you are trying to customize.  This tells
;; you what face is under the cursor.

(defun font-lock-face()
  "Displays the font-lock face at point."
  (interactive)
  (prin1 (get-text-property (point) 'face)))


;;; Project Support ------------------------------------------------------------

;; projectile provides completion for files in a project.  It has a lot of other
;; features, so be sure to read up on it.  This is one of those packages you
;; should spend time researching.

;; The `projectile-other-file-alist` allows me to use "C-c p a" to quickly
;; switch to another file with the same filename but a different extension.

;; recentf is required for "C-c p e" (projectile-recentf).

(recentf-mode 1)

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :config
  (progn
    (setq projectile-enable-caching t
          projectile-switch-project-action 'projectile-dired
          projectile-globally-ignored-files
          (append projectile-globally-ignored-files '(".DS_Store" ".gitignore" "*.pyo" "*.dll" "*.pdf" "*.exe" "*.pyc" "*.elc")))
    (add-to-list 'projectile-other-file-alist '("html" "js" "py"))
    (add-to-list 'projectile-other-file-alist '("js" "html" "py"))
    (add-to-list 'projectile-other-file-alist '("py" "html" "js"))

    ;; I'm looking for some shorter shortcuts for the common projectile functions.
    (global-set-key (kbd "M-O") 'projectile-find-file)
    (global-set-key (kbd "M-B") 'projectile-switch-to-buffer)

    (projectile-global-mode)))


;;; Compilation ----------------------------------------------------------------

;; F7 saves all buffers and compiles.  I'm not sure the function is necessary
;; anymore - is there an option already for saving all files when a compile is
;; made?

(defun save-and-compile ()
  "Saves all unsaved buffers, and runs 'compile'."
  (interactive)
  (save-some-buffers t)
  (compile compile-command)
  )
(global-set-key (kbd "<f7>") (quote save-and-compile))

;; Flycheck for automatic code checking.
;;
;; This hangs on Windows with jshint and the flycheck maintainer's not
;; interested in debugging Windows issues.

(use-package flycheck
  :if (eq system-type 'darwin))


;;; multiple-cursors and iedit -------------------------------------------------

;; This isn't quite as good as using Sublime Text, but when you need it's pretty
;; good.  (Though I can never get a single-key "skip" to work.)

;; For quick marking, select some text and use "M-3" to put a cursor (and
;; select) at the next match.  C-x m is bound to a hydra with more commands.
;; The most handy is probably "C-x m i" to initiate an interactive, though you
;; have to have selected something first.
;;
;; (I really need to make the hydra include things like turning on "symbol" mode
;; or something.  MC is nice, but could use some serious UX tweaking.a)

(use-package multiple-cursors
  :ensure t

  :bind
  (("M-3" . mark-next-like-this-cycle-forward) ; next to er/expand-region which is M-2
   ("C-x m" . hydra-mc/body))

  :config
  (progn
    ;; I find it odd, but mark-next marks the next item but does not move to is
    ;; - so you can't even see what you are marking a lot of times.  Make a
    ;; function that marks and then moves.
    (defun mark-next-like-this-cycle-forward ()
      "Marks next occurence of word like this and advances cursor to this occurence"
      (interactive)
      (mc/mark-next-like-this 1)
      (mc/cycle-forward))
    (add-to-list 'mc/cmds-to-run-once 'mark-next-like-this-cycle-forward)

    (setq mc/cycle-looping-behaviour 'error
          ;; Remove the warning color from the modeline.
          mc/mode-line `(" mc:" (:eval (format "%d" (mc/num-cursors)))))

    ;; There are a lot of commands and they aren't often used, so setup a hydra
    ;; to make them easy to find.  Use C-x m which is somewhat mnemonic.

    (defhydra hydra-mc ()
      "multiple cursors"
      ("i" mc/mark-more-like-this-extended "interactive")
      ("h" mc-hide-unmatched-lines-mode "hide unmatched")
      ("a" mc/mark-all-like-this "mark all")
      ("f" mc/mark-all-symbols-like-this-in-defun "mark in func")
      ("l" mc/edit-lines "edit lines"
       :exit t)
      ("\C-a" mc/edit-beginnings-of-lines "edit BOL"
       :exit t)
      ("\C-e" mc/edit-ends-of-lines "edit EOL"
       :exit t))
    (add-to-list 'mc/cmds-to-run-once 'hydra-mc/body)))


;; iedit - Highlight multiple instances of the symbol the cursor is on.  Editing
;; the current one changes them all.  The same thing can be accomplished with
;; multiple cursors, but this is much faster when it matches what you want to
;; do.

;; Unfortunately the keys are very hardcoded.  I wanted to switch to a hydra to
;; initiate but I still can't set the exit key properly.  It conflicts with an
;; ispell key that's handy.

(use-package iedit
  :ensure t)


;;; undo -----------------------------------------------------------------------

;; Emacs' default undo really doesn't make much sense.  Read the undo-tree docs
;; which will explain more.

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode))


;;; imenu ----------------------------------------------------------------------

;; imenu builds a list of symbols in the current file.  Running it normally will
;; prompt you for the symbol to go to, defaulting to the symbol at point.
;;
;; Later in this file M-g s is set to allow fuzzy matching for all symbols in
;; the file.

(use-package imenu
  :bind ("<f12>" . imenu))


;;; ido and smex ---------------------------------------------------------------

;; I'm using ido with fuzzy matching for completion everywhere.  smex does the
;; same with M-x

(require 'ido)
(ido-mode 1)

;; virtual-buffer causes ido-find-file (C-x C-f) to include recently used files
;; even if they are closed.
(setq ido-use-virtual-buffers t)

(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

(use-package flx-ido
  :ensure t
  :config
  (progn
    (flx-ido-mode 1)

    ;; disable ido faces to see flx highlights.
    (setq ido-enable-flex-matching t
          ido-case-fold t
          ido-use-faces nil
          ;; http://stackoverflow.com/questions/7479565/emacs-ido-mode-and-creating-new-files-in-directories-it-keeps-changing-the-dire
          ido-auto-merge-work-directories-length -1
          ido-use-virtual-buffers t)))


;; Use ido everywhere possible.

(use-package ido-ubiquitous
  :ensure t
  :config
  (ido-everywhere))

;; The default ido display is a comma separated, horizontal list.  Show the items
;; vertically which is much easier to read.

(use-package ido-vertical-mode
  :ensure t
  :config
  (ido-vertical-mode 1))


;; Set "M-g s" and "M-g M-s" to display a list of symbols (functions, etc.) in
;; the current buffer so you can jump to them using the same fuzzy matching.
;; This is just a modified version of imenu.


(defun ido-goto-symbol (&optional symbol-list parent)
  (interactive)

  ;; If no symbol-list, we've just been called interactively.  Call ourselves
  ;; with the list from imenu--make-index-alist.  That call will poplute
  ;; symbol-names which we then pass to ido.

  (cond
   ((not symbol-list)
    (let (name-and-pos symbol-names position)
      (while (progn
               (imenu--cleanup)
               (setq imenu--index-alist nil)
               (ido-goto-symbol (imenu--make-index-alist))
               (setq selected-symbol
                     (ido-completing-read "goto: " symbol-names))
               (string= (car imenu--rescan-item) selected-symbol)))
      ;; A symbol has been selected - go to it.
      (unless (and (boundp 'mark-active) mark-active)
        (push-mark nil t nil))
      (setq position (cdr (assoc selected-symbol name-and-pos)))
      (cond
       ((overlayp position)
        (goto-char (overlay-start position)))
       (t
        (goto-char position)))))

   ;; To ge here, we must have a symbol-list, so this is a recursive call whose
   ;; job is simply to take the symbols, put them into `symbol-names`, and
   ;; return.
   ;;
   ;; `symbol-list` is actually a tree, so if we find sub-symbols (e.g. a class
   ;; with methods), we'll call ourselves again with the sub-symbols as
   ;; `symbol-list`.

   ((listp symbol-list)
    (dolist (symbol symbol-list)
      (let (name position)
        (cond
         ((and (listp symbol) (imenu--subalist-p symbol))
          (progn
            (message "symbol: %S" (car symbol))
            (ido-goto-symbol symbol (car symbol))))
         ((listp symbol)
          (setq name (car symbol))
          (setq position (cdr symbol)))
         ((stringp symbol)
          (setq name symbol)
          (setq position
                (get-text-property 1 'org-imenu-marker symbol))))
        (if (null position)
            (message "no position: %s" name))
        (unless (or (null position) (null name)
                    (string= (car imenu--rescan-item) name))

          ;; Format the name appropriately.  Note that "*class definition*" is
          ;; something that Python does which Python mode does.  I need to see
          ;; how to make this more generic.
          (setq name
                (cond
                 ((and (atom parent) (string= name "*class definition*"))
                  parent)
                 ((atom parent)
                  (concat parent " " name))
                 (t
                  name)))

          (add-to-list 'symbol-names name)
          (add-to-list 'name-and-pos (cons name position))))))))


;; Fuzzy matching for M-x

(use-package smex
  :ensure t
  :bind (("M-x" . smex)))


;;; Fast Navigation ------------------------------------------------------------



(use-package avy
  ;; Quickly jump to any visible character.  I'm still getting used to this but
  ;; I think it could be good.
  :ensure t)


;; Create a hydra for the various goto commands

(defhydra hydra-goto(:exit t :hint nil :idle 0.5)
  "
_w_: word   _c_: char    _n_: next error  _._: set mark
_l_: line   _s_: symbol  _p_: prev error"
  ("l" goto-line)
  ("s" ido-goto-symbol)
  ("M-s" ido-goto-symbol)
  ("c" avy-goto-char-timer)
  ("w" avy-goto-word-1)
  ("." cua-set-mark)
  ("n" next-error)
  ("p" previous-error)
  ;;;; For backwards compatability, have "M-g M-g" and "M-g g" do what they've
  ;;;; always done.
  ("g" goto-line)
  ("M-g" goto-line)
  )

(global-set-key (kbd "M-g") 'hydra-goto/body)

;;; Kill Ring ------------------------------------------------------------------

;; Show the entire kill ring in another buffer so you can scroll around looking
;; for the text you want to paste.

(use-package browse-kill-ring
  :ensure t
  :config
  (progn
    (browse-kill-ring-default-keybindings)
    (setq-default browse-kill-ring-display-duplicates nil
                  browse-kill-ring-highlight-current-entry t
                  browse-kill-ring-highlight-inserted-item nil
                  browse-kill-ring-maximum-display-length 300
                  browse-kill-ring-no-duplicates t
                  browse-kill-ring-separator
                  "-----------------------------------------------------------------------------------------------"
                  browse-kill-ring-separator-face 'widget-documentation-face)))


;;; Magit ----------------------------------------------------------------------

;; Magit is a great interface to git.  I've set "M-F7" to show the current
;; status.

(use-package magit
  :ensure t
  :bind (("M-<f7>" . magit-status))
  :config
  (progn
    (add-to-list 'magit-no-confirm 'stage-all-changes)
    (setq magit-push-always-verify nil
          magit-last-seen-setup-instructions "2.1.0"
          magit-commit-show-diff nil
          magit-revert-buffers 1
          magit-completing-read-function #'magit-ido-completing-read)

    (defun personal-magit-setup-hook()
      (git-commit-turn-on-auto-fill)
      (git-commit-turn-on-flyspell))

    (add-hook 'magit-commit-setup-hook 'personal-magit-setup-hook)

    ;; Do not show tags in the "Show Refs" window.  It is way too slow on
    ;; Windows and isn't useful if you just want to manage your branches.  This
    ;; makes it more like Magit 1.x's branch manager.
    (remove-hook 'magit-refs-sections-hook 'magit-insert-tags)))

;; This is a fantastic package.  Turn it on and it creates a buffer for the
;; current file showing its previous state in git.  Press C-n and C-p to move
;; through the file's history.

(use-package git-timemachine
  :ensure t
  :commands git-timemachine)

;; I'm using Github a lot so having pull requests directly in the magit buffer
;; is handy.

;; (use-package magit-gh-pulls
;;   :config
;;   (add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls))

;; We won't be needing emacs' built-in version control code so disable it for
;; performance.
(setq vc-handled-backends nil)


;;; yasnippets -----------------------------------------------------------------

;; There are a ton of built-in snippets when downloading from MELPA, which makes
;; it take forever to load.  I don't use any of them anyway, so I'll set the
;; directory to only by mine first.
(setq yas-snippet-dirs '("~/.emacs.d/snippets"))

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config (yas-global-mode 1))

;;; Miscellaneous Modes --------------------------------------------------------

;; I'm using Bootstrap 2 & 3 so I work in less files.  I suppose I'll be
;; switching to Sass soon with Bootstrap 4.

(use-package less-css-mode
  :ensure t
  :mode ("\\.less$" . less-css-mode))

;; Markdown is pretty nice.  I'm using GitHub so enable Github Flavored Markdown
;; (gfm).

(use-package markdown-mode
  :ensure t
  :mode ("\\.md$" . gfm-mode))


;; prevent demoting heading also shifting text inside sections
(setq org-adapt-indentation nil)


;;; Whitespace and Line Endings ------------------------------------------------

;; The whitespace package provides functions for cleaning up inconsistent
;; whitespace and can even monitor your buffers as you work.

(use-package whitespace
  :config
  (progn
    (setq-default whitespace-silent t       ; complain in modeline only
                  whitespace-check-indent-whitespace nil
                  whitespace-check-leading-whitespace nil
                  whitespace-display-in-modeline nil)))

;; C-F6 for a quick whitespace cleanup.

(defun make-buffer-neat ()
  "Fixup whitespace"
  (interactive)
  (delete-trailing-whitespace (point-min) (point-max))
  (untabify (point-min) (point-max)))
(global-set-key (kbd "C-<f6>") 'make-buffer-neat)

;; With ws-butler, however, I don't really need cleanup as often.  This cleans
;; up whitespace *only* on lines you edit.  This ensures that a commit doesn't
;; look like every single line changed just because you cleaned up whitespace.
;; (On the other hand, you and your team do know how to configure magit to igore
;; whitespace by default?)

(use-package ws-butler
  :ensure t
  :config
  (ws-butler-global-mode 1))

;; Provide unix-file and windows-file to switch line endings.

(defun unix-file ()
  "Change the current buffer to Latin 1 with Unix line-ends."
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-unix t))

(defun windows-file ()
  "Change the current buffer to Latin 1 with Windows line-ends."
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-dos t))

(defun hide-windows-eol ()
  "Hide ^M in files containing mixed UNIX and Windows line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))


;;; Programming Modes ----------------------------------------------------------

;; Web Mode

;; I've set the default engine to "ctemplate" since everything I'm doing lately
;; is using Mustache / Handlebars syntax.

;; I also set / reset some of the keys so that they behave somewhat like the
;; same keys in other modes.  This package is pretty bad about not matching
;; emacs which makes it harder to remember the keys.

(use-package web-mode
  :ensure t
  :mode "\\.html$"
  :config
  (progn
    (setq
     web-mode-engines-alist '(("ctemplate" . "\\.html\\'"))
     web-mode-markup-indent-offset 2
     web-mode-css-indent-offset 2
     web-mode-code-indent-offset 2)
    (define-key web-mode-map (kbd "M-h") 'web-mode-mark-and-expand)
    (define-key web-mode-map (kbd "M-n") 'web-mode-tag-next)
    (define-key web-mode-map (kbd "M-p") 'web-mode-tag-previous)
    (define-key web-mode-map (kbd "C-M-p") 'web-mode-tag-previous)
    (define-key web-mode-map (kbd "C-M-u") 'web-mode-element-parent)
    (define-key web-mode-map (kbd "C-M-a") 'web-mode-element-previous)
    (define-key web-mode-map (kbd "C-M-e") 'web-mode-element-end)))

;; I'm using Python from the /misc directory so I can have the latest version.
;; I had to turn off the hideous electric-indent though.

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :load-path "misc/"
  :interpreter ("python" . python-mode)
  :config
  (progn
    (add-hook 'python-mode-hook 'my-python-hook)

    (setq python-fill-docstring-style (quote django)
          ;; python-guess-indent t
          python-honour-comment-indentation nil
          ;;python-indent-string-contents t
          )))

(defun my-python-hook()
  (turn-on-auto-fill)
  (setq electric-indent-inhibit t)
  (abbrev-mode 1)
  ;; Python mode appends "(class)" and "(def)" to everything which looks crappy.
  (setq python-imenu-format-item-label-function (lambda(type name) name))
  (setenv "LANG" "en_US.UTF8"))


;;; Javascript -----------------------------------------------------------------

;; http://stackoverflow.com/questions/20863386/idomenu-not-working-in-javascript-mode
;; https://github.com/redguardtoo/emacs.d/blob/master/lisp/init-javascript.el

;; The default Javascript imenu parser doesn't work with Backbone style
;; structures, so we'll make a custom one.
;;
;; Set the menu (first item) to nil so the result is a flat menu.

;; Update: flycheck and jshint has been missing a lot of obvious problems, so
;; I'm going to switch to js2-mode on Mac also.

(setq javascript-common-imenu-regex-list
      '(
        (nil "function[ \t*]*\\([^ ]+\\) *(" 1) ; function name()
        (nil " \\([^ ]+\\)\\s-*[=:]\\s-*function[ \t*]*(" 1) ; name: function() and name = function()
        ))

(defun personal/js-imenu-make-index ()
  (save-excursion
    (imenu--generic-function javascript-common-imenu-regex-list)))

(defun personal-js-mode-hook ()
  (turn-on-auto-fill)
  (setq-local imenu-create-index-function 'personal/js-imenu-make-index))

(add-hook 'js-mode-hook 'personal-js-mode-hook)

(use-package js2-mode
  :ensure t
  :config
  (progn
    (setq-default js2-global-externs
          '("define" "require" "app" "$" "_" "moment" "Backbone" "sessionStorage" "HTTP_ROOT" "localStorage" "Handlebars"))
  (add-hook 'js-mode-hook 'js2-minor-mode)))


;;; SQL ------------------------------------------------------------------------

;; M-F5 switches to the "*SQL*" buffer if it exists.  Otherwise it runs
;; sql-connect which will ask for a connection name from sql-connection-alist.
;; (I keep that in the local.el file that isn't checked in since it is different
;; for each computer.)

(defun switch-to-sql ()
  "Switch to *SQL* if exists, otherwise run sql-connect"
  (interactive)
  (let ((sbuf (get-buffer "*SQL*")))
    (message "buf: %S" sbuf)
    (if sbuf
        (pop-to-buffer sbuf)
      (call-interactively 'sql-connect)
      )))

(global-set-key (quote [M-f5]) 'switch-to-sql)


;; Make "C-M-h" (mark-defun usually) mark a table definition.  It starts on a
;; line with "create table ..." and ends with a line ")".

(defvar mksql-create "^create\\s-+table\\b" "Regexp for 'create table'")
(defvar mksql-end "^\\s-*);?" "Regexp for ';)' ending a table")

(defun mksql-mark-table()
  (interactive)
  (if (or (looking-at mksql-create) (re-search-forward mksql-create (point-min) t -1))
      (progn
        (push-mark)
        (re-search-forward mksql-end)
        (exchange-point-and-mark))))

(defun my-sql-hook()
  (turn-on-auto-fill)
  ;; When SQL mode is started, call look for the SQLI buffer automatically.
  (sql-set-sqli-buffer-generally)
  (define-key sql-mode-map "\C-\M-h" 'mksql-mark-table)

  ;; Normal SQL mode makes C-M-e go to the end of SQL, but I often need to go to
  ;; the end of a table definition.  I'll remap it back to end-of-defun which
  ;; happens to do the right thing.  Since going to the end of a SQL statement
  ;; is probably handy, I'll move to M-e which is normally forward-sentence.

  ;; SQL mode remaps these two to versions that go to the beginning and end of a
  ;; statement.  I'd rather keep them as-is so I can go the beginning and end of
  ;; table definitions.  I'll replace sentence movement with the statement ones
  ;; instead.
  (define-key sql-mode-map [remap beginning-of-defun] nil) ; remove SQL's remap from the keymap
  (define-key sql-mode-map [remap end-of-defun] nil)

  (define-key sql-mode-map (kbd "M-a") 'sql-beginning-of-statement)
  (define-key sql-mode-map (kbd "M-e") 'sql-end-of-statement)

  (define-key sql-mode-map (kbd "<f6>") 'sql-set-sqli-buffer-generally))

(add-hook 'sql-mode-hook 'my-sql-hook)

;; Replace standard sql-send-paragraph with one that does not send leading blank
;; lines.
;;
;; Only change is re-search-forward, though I'm not sure it is the best way.
;; For some reason it does skip forward to the right line, but it doesn't skip
;; leading blanks on the line.

(defun sql-send-paragraph ()
  "Send the current paragraph to the SQL process."
  (interactive)
  (let ((start (save-excursion
                 (backward-paragraph)
                 (re-search-forward "[^[:space:]]")
                 (point)))
        (end (save-excursion
               (forward-paragraph)
               (point))))
    (sql-send-region start end)))

;; (defun sql-add-newline-first (output)
;;   "Add newline to beginning of OUTPUT for `comint-preoutput-filter-functions'
;;    This fixes up the display of queries sent to the inferior buffer
;;    programatically.  But an new-line
;;    "
;;   (let ((begin-of-prompt
;;          (or (and comint-last-prompt-overlay
;;                   ;; sometimes this overlay is not on prompt
;;                   (save-excursion
;;                     (goto-char (overlay-start comint-last-prompt-overlay))
;;                     (looking-at-p comint-prompt-regexp)
;;                     (point)))
;;              1)))
;;     (if (> begin-of-prompt sql-last-prompt-pos)
;;         (progn
;;           (setq sql-last-prompt-pos begin-of-prompt)
;;           (concat "\n" output))
;;       output)))

;; (defun sqli-add-hooks ()
;;   "Add hooks to `sql-interactive-mode-hook'."
;;   (add-hook 'comint-preoutput-filter-functions
;;             'sql-add-newline-first))
;; (add-hook 'sql-interactive-mode-hook 'sqli-add-hooks)


;;; shell and eshell -----------------------------------------------------------

(setenv "EDITOR" "emacsclient")

(global-set-key (kbd "<f9>") 'eshell)

(defun eshell/clear ()
  "Clears the shell buffer ala Unix's clear or Windows' cls"
  (interactive)
  ;; the shell prompts are read-only, so clear that for the duration
  (let ((inhibit-read-only t))
    ;; simply delete the region
    (delete-region (point-min) (point-max))))


;; From kai.grossjohann@uni-duisburg.de
(defun eshell-insert-last-word (n)
  (interactive "p")
  (insert (car (reverse
                (split-string
                 (eshell-previous-input-string (- n 1)))))))

(add-hook 'eshell-mode-hook
          '(lambda ()
             (progn
               (linum-mode -1)
               (local-set-key (kbd "M-.") 'eshell-insert-last-word)
               (eshell-smart-initialize))))


(require 'eshell)
(require 'em-smart)
(setq eshell-where-to-jump 'begin)
(setq eshell-review-quick-commands nil)
(setq eshell-smart-space-goes-to-end t)

;; Move eshell's generated files into a subdirectory so we can add a single item
;; to .gitignore.

(setq eshell-directory-name "~/.emacs.d/eshell/"
      eshell-aliases-file "~/.emacs.d/eshell/alias")

(setq eshell-cmpl-cycle-completions nil
      eshell-prefer-lisp-functions t)

;; Replace M-r history search with an ido version.
(defun my-eshell-ido-complete-command-history ()
  (interactive)
  (eshell-kill-input)
  (insert
   (ido-completing-read "Run command: " (delete-dups (ring-elements eshell-history-ring))))
  (eshell-send-input))

(add-hook 'eshell-mode-hook
          (lambda ()
            (local-set-key (kbd "M-r") #'my-eshell-ido-complete-command-history)))


;;; C / C++ --------------------------------------------------------------------

;; Add the new Visual Studio 2005 / MSBuild format which adds the column to the
;; older Visual Studio format.
;;
;; Listener.cs(19,16): error CS1002: ; expected
(require 'compile)
(setq compilation-error-regexp-alist
      (nconc
       '(
         ("^\\([A-Za-z_-0-9.]+\\)(\\([0-9]+\\),\\([0-9]+\\)): \\(error\\|warning\\)" 1 2 3)
         )
       compilation-error-regexp-alist))

(autoload 'c++-mode "cc-mode" "C++ Editing Mode" t)
(autoload 'c-mode   "cc-mode" "C Editing Mode" t)

;; Force .h files into C++ mode; usually they are assigned to C mode.
(setq auto-mode-alist (cons '("\\.h$" . c++-mode) auto-mode-alist))

(defconst my-c-style
  '((c-tab-always-indent        . t)
    (c-comment-only-line-offset . 4)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 0)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)
                                   (inline-open       . 0)
                                   (comment-intro     . 0)
                                   ))
    (c-echo-syntactic-information-p . t)
    )
  "My C Programming Style")

(defun my-c-mode-common-hook ()
  ;; make the <enter> key use the "smart enter" function
  (define-key c-mode-base-map "\C-m" 'newline-and-indent)

  ;; I finally got tired of hungry delete, but here it is for those that like it.
  ;; (c-toggle-auto-hungry-state 1)
  (c-toggle-auto-state 1)

  (c-add-style "PERSONAL" my-c-style t)
  ;; (setq compile-command "nmake /NOLOGO  ")
  (setq c-comment-continuation-stars "* ")
  ;; (setq c-hanging-comment-ender-p nil)

  ;; override C-M-h to narrow-sexp.  Mark-sexp doesn't work for Java code, so we
  ;; grabbed its keystroke.
  ;;(global-set-key "\C-\M-h" 'narrow-sexp)

  (turn-on-auto-fill)
  ;; (setq auto-fill-function c-do-auto-fill)

  ;; override the default cleanup list to remove emtpy-defun-braces
  (setq c-cleanup-list '(scope-operator defun-close-semi))

  (setq comment-start "// ")
  (setq comment-end "")
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)


;;; Spell check ----------------------------------------------------------------

;; On OS X, install aspell.  (I might have used Homebrew.)

;; http://blacka.com/david/2010/01/17/switching-to-cocoa-emacs
(when (eq system-type 'darwin)
  (setq ispell-program-name "aspell"))


;;; Fun Stuff ------------------------------------------------------------------

;; I often use a French press for coffee.  The tea-time package provides an easy
;; timer, but of course it needs to aliased to coffee-time.  On OS X, use native
;; notifications just for fun.

(use-package tea-time
  :load-path "misc/"
  :config
  (progn
    ;; Rename to coffee-time. :)
    (defalias 'coffee-time 'tea-time)

    ;; Use a mac utility named terminal-notifier to get OS X native notifications.
    (when (eq system-type 'darwin)
      (add-hook 'tea-time-notification-hook
                (lambda ()
                  (start-process "tea-timer-notification" nil
                                 "terminal-notifier"
                                 "-title" "'Hello, Sailor!'"
                                 "-message" "'Coffee is ready!'"
                                 "-appIcon"
                                 "/Applications/Emacs.app/Contents/Resources/Emacs.icns"))))))


;;; Local ----------------------------------------------------------------------

;; Stuff that only applies to the current computer is stored in local.el and is
;; not checked in.  (It is in .gitignore.)  Since it is not checked in, this is
;; also where you'd store confidential items.

(let ((local "~/.emacs.d/local.el"))
  (if (file-exists-p local)
      (load-file local)))


;; Local Variables:
;; fill-column: 80
;; eval: (auto-fill-mode 1)
;; End:
