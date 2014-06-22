
(require 'cl)
(require 'org)
(defun export-init-org ()
  "Generate init.html and init.html from the current init.org file."
  (interactive)
  (call-interactively 'org-babel-tangle)
  (call-interactively 'org-export-as-html))

(setq org-export-html-style-extra "<link rel=\"stylesheet\" href=\"init.css\" />")

;;; timestamps in *Messages*
(defun current-time-microseconds ()
  (let* ((nowtime (current-time))
         (now-ms (nth 2 nowtime)))
    (concat (format-time-string "[%Y-%m-%dT%T" nowtime) (format ".%d] " now-ms))))

(defadvice message (before test-symbol activate)
  (if (not (string-equal (ad-get-arg 0) "%s%s"))
      (let ((deactivate-mark nil)
            (inhibit-read-only t))
        (save-excursion
          (set-buffer "*Messages*")
          (goto-char (point-max))
          (if (not (bolp))
              (newline))
          (insert (current-time-microseconds))))))

(setq gc-cons-threshold 20000000)

(setq inhibit-startup-message t)

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(setq visible-bell t)

(setq initial-scratch-message nil)

(fset 'yes-or-no-p 'y-or-n-p)

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "PYTHONPATH"))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(package-initialize)

(defadvice package-install (before maybe-refresh-packages activate)
  (unless (or (called-interactively-p) (assq (ad-get-arg 0) package-archive-contents))
    (unless package--initialized
      (package-initialize t))
    (unless (and package-archive-contents (assq (ad-get-arg 0) package-archive-contents))
      (package-refresh-contents))))

(unless (package-installed-p 'req-package)
  (package-install 'req-package))
(package-initialize)
(require 'req-package)

(req-package auto-compile
             :init
             (progn
               (auto-compile-on-load-mode 1)
               (auto-compile-on-save-mode 1)
               ))

(setq user-full-name "Phillip B Oldham"
      user-mail-address "phillip.oldham@gmail.com"
      change-log-default-name "CHANGELOG")

(add-to-list 'custom-theme-load-path (expand-file-name "themes" dotfiles-dir))
(load-theme 'leiptr)

(set-face-attribute 'default nil :font "Monaco-10:weight=normal")

(setq org-fontify-done-headline t)

(setq enable-recursive-minibuffers t)

(minibuffer-depth-indicate-mode 1)

(blink-cursor-mode -1)

(setq message-log-max 512)

(req-package uniquify
             :diminish ""
             :init
             (progn
                (setq uniquify-buffer-name-style 'forward)
                ))

(req-package powerline
             :diminish ""
             :init (powerline-default-theme))

(add-hook 'emacs-lisp-mode-hook
  (lambda()
    (setq mode-name "el")))

(global-linum-mode 1)
(setq linum-format "%4d")
(setq column-number-mode 1)

(defun line-at-click ()
  (save-excursion
  (let ((click-y (cdr (cdr (mouse-position))))
      (line-move-visual-store line-move-visual))
    (setq line-move-visual t)
    (goto-char (window-start))
    (next-line (1- click-y))
    (setq line-move-visual line-move-visual-store)
    (1+ (line-number-at-pos)))))

(defun md-select-linum ()
  (interactive)
  (goto-line (line-at-click))
  (set-mark (point))
  (setq *linum-mdown-line*
    (line-number-at-pos)))

(defun mu-select-linum ()
  (interactive)
  (when *linum-mdown-line*
  (let (mu-line)
    (setq mu-line (line-at-click))
    (goto-line (max *linum-mdown-line* mu-line))
    (set-mark (line-end-position))
    (goto-line (min *linum-mdown-line* mu-line))
    (setq *linum-mdown*
      nil))))

(global-set-key (kbd "<left-margin> <down-mouse-1>") 'md-select-linum)
(global-set-key (kbd "<left-margin> <mouse-1>") 'mu-select-linum)
(global-set-key (kbd "<left-margin> <S-mouse-1>") 'mu-select-linum)
(global-set-key (kbd "<left-margin> <drag-mouse-1>") 'mu-select-linum)

(setq isearch-allow-scroll t)

(setq scroll-step 1
      scroll-conservatively 10000)

(mouse-wheel-mode t)
(setq mouse-wheel-scroll-amount '(1))
(setq mouse-wheel-progressive-speed nil)

(setq mouse-wheel-follow-mouse 't)

(setq redisplay-dont-pause t)
(defun up-single () (interactive) (scroll-up 1))
(defun down-single () (interactive) (scroll-down 1))
(defun up-double () (interactive) (scroll-up 2))
(defun down-double () (interactive) (scroll-down 2))
(defun up-triple () (interactive) (scroll-up 5))
(defun down-triple () (interactive) (scroll-down 5))

(global-set-key [wheel-down] 'up-single)
(global-set-key [wheel-up] 'down-single)
(global-set-key [double-wheel-down] 'up-double)
(global-set-key [double-wheel-up] 'down-double)
(global-set-key [triple-wheel-down] 'up-triple)
(global-set-key [triple-wheel-up] 'down-triple)

(define-key global-map (kbd "<S-down-mouse-1>") 'ignore) ; turn off font dialog
(define-key global-map (kbd "<S-mouse-1>") 'mouse-set-point)
(define-key global-map (kbd "<S-down-mouse-1>") 'mouse-save-then-kill)

(global-font-lock-mode 1)

(setq transient-mark-mode t)

(req-package highlight-indentation
             :init
             (progn
               (set-face-background 'highlight-indentation-face "#222")
               (add-hook 'python-mode-hook 'highlight-indentation-mode)
               ))

(req-package rainbow-delimiters
             :diminish ""
             :init
             (progn
               (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
               (add-hook 'python-mode-hook 'rainbow-delimiters-mode)
               ))

(req-package column-enforce-mode
             :diminish ""
             :init (add-hook 'python-mode-hook 'column-enforce-mode))

(req-package rainbow-mode
             :diminish ""
             :defer t
             :init
             (progn
               (add-hook 'clevercss-mode-hook 'rainbow-mode)
               (add-hook 'less-mode-hook 'rainbow-mode)
               (add-hook 'css-mode-hook 'rainbow-mode)
               (add-hook 'css-mode-hook 'rainbow-mode)
               (add-hook 'emacs-lisp-mode-hook 'rainbow-mode)
               ))

(req-package auto-complete
             :init
             (progn
               (add-to-list 'ac-dictionary-directories (expand-file-name "autocomplete" dotfiles-dir))
               (require 'auto-complete-config)
               (ac-config-default)
               (setq ac-use-menu-map t)
               (define-key ac-complete-mode-map "\t" 'ac-complete)
               (define-key ac-complete-mode-map "\r" nil)
               (define-key ac-complete-mode-map [return] nil)
               (define-key ac-complete-mode-map "\C-m" nil)
               (global-set-key "\C-f" 'ac-isearch)))

(setq file-name-shadow-tty-properties '(invisible t))
(file-name-shadow-mode 1)

(req-package recentf
             :diminish ""
             :init
             (progn
               (recentf-mode 1)
               (setq recentf-max-save-items 500
                     recentf-max-menu-items 50)))

(req-package ido-ubiquitous
             :require (ido recentf)
             :diminish ""
             :init
             (progn
               (ido-mode t)
               (setq ido-confirm-unique-completion nil)
               (setq ido-create-new-buffer 'always)
               (setq ido-enable-flex-matching t)
               (setq ido-ignore-extensions t)
               (setq ido-use-virtual-buffers t)
               (ido-ubiquitous-mode 1)
               ))

(req-package flx-ido
             :require flx
             :init
             (progn
               (flx-ido-mode 1)
               ))

(defun ido-recentf-open ()
  "Use `ido-completing-read' to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
    (message "Aborting")))

(global-set-key (kbd "H-S-o") 'ido-recentf-open)

(req-package smex
             :diminish ""
             :bind (("M-x" . smex)
                    ("M-X" . smex-major-mode-commands)
                    ("C-c C-c M-x" . execute-extended-command)))

(req-package projectile
             :diminish ""
             :init
             (progn
               (projectile-global-mode)
               ))

(setq mac-command-modifier 'alt mac-option-modifier 'meta)
(setq mac-command-modifier 'hyper)

(global-set-key [(hyper z)] 'undo)
(global-set-key [(hyper shift z)] 'redo)

(global-set-key [(hyper a)] 'mark-whole-buffer)

(global-set-key [(hyper x)] 'kill-region)
(global-set-key [(hyper c)] 'kill-ring-save)
(global-set-key [(hyper v)] 'yank)

(global-set-key [(hyper o)] 'find-file)
(global-set-key [(hyper s)] 'save-buffer)
(global-set-key [(hyper w)]
                (lambda () (interactive) (my-kill-buffer (current-buffer))))
(global-set-key [(hyper q)] 'save-buffers-kill-emacs)

(global-set-key [(hyper m)] 'iconify-frame)
(global-set-key [(hyper h)] 'ns-do-hide-emacs)

(global-set-key [(hyper f)] 'isearch-forward)
(global-set-key [(hyper g)] 'isearch-repeat-forward)

(global-set-key [(hyper left)] 'beginning-of-line)
(global-set-key [(hyper right)] 'end-of-line)
(global-set-key [(hyper t)] 'beginning-of-buffer)
(global-set-key [(hyper b)] 'end-of-buffer)

(global-set-key [(hyper u)] 'upcase-region)
(global-set-key [(hyper l)] 'downcase-region)

(global-set-key [(hyper j)] 'goto-line)

(global-set-key (kbd "H-S-<backspace>") 'join-line)

(global-set-key [(hyper shift r)] 'repeat)

(define-key local-function-key-map [cancel] [H-Esc])
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-set-key (kbd "M-2") '(lambda () (interactive) (insert "€")))

(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))

(global-set-key (kbd "H-=") 'text-scale-increase)
(global-set-key (kbd "H--") 'text-scale-decrease)

(req-package key-chord
             :init
             (progn
               (key-chord-mode 1)
               (when (memq window-system '(mac ns))
                 (key-chord-define-global "§1" 'smex))
               (key-chord-define-global "o0" 'find-file)
               (key-chord-define-global "o=" 'dired-jump)
               (key-chord-define-global "o-" 'ido-recentf-open)
               (key-chord-define-global "o[" 'find-file-at-point)
               (key-chord-define-global "p-" 'projectile-find-file)
               (key-chord-define-global "t5" 'untabify)
               (key-chord-define-global "r4" 'replace-string)
               (key-chord-define-global "r3" 'vr/query-replace)
               (key-chord-define-global "e3" 'er/expand-region)
               (key-chord-define-global "e2" 'er/contract-region)
               (key-chord-define-global "p[" 'fill-paragraph)
               (key-chord-define-global "p]" 'unfill-paragraph)
               (key-chord-define-global " k" 'delete-trailing-whitespace)
               (key-chord-define-global "m," 'my-previous-like-this)
               (key-chord-define-global "m." 'my-more-like-this)
               (key-chord-define-global "s1" 'ispell-region)
               (key-chord-define-global "d3" 'deft)
               ))

(setq initial-major-mode 'text-mode)

(defun new-empty-buffer ()
  "Create a new buffer called untitled(<n>)"
  (interactive)
  (let ((newbuf (generate-new-buffer-name "untitled")))
    (switch-to-buffer newbuf)))

(global-set-key [(hyper n)] 'new-empty-buffer)

(defvar persistent-scratch-filename
    (expand-file-name ".emacs-persistent-scratch" dotfiles-dir)
    "Location of *scratch* file contents for persistent-scratch.")

(defun save-persistent-scratch ()
  "Write the contents of *scratch* to the file name
  PERSISTENT-SCRATCH-FILENAME"
  (with-current-buffer (get-buffer "*scratch*")
    (write-region (point-min) (point-max)
                  persistent-scratch-filename)))

(defun load-persistent-scratch ()
  "Load the contents of PERSISTENT-SCRATCH-FILENAME into the
  scratch buffer, clearing its contents first."
  (if (file-exists-p persistent-scratch-filename)
      (with-current-buffer (get-buffer "*scratch*")
        (delete-region (point-min) (point-max))
        (shell-command (format "cat %s" persistent-scratch-filename) (current-buffer)))))

(load-persistent-scratch)

(push #'save-persistent-scratch kill-emacs-hook)

(setq bury-buffer-names '("*scratch*" "*Messages*"))

(defun kill-buffer-query-functions-maybe-bury ()
  "Bury certain buffers instead of killing them."
  (if (member (buffer-name (current-buffer)) bury-buffer-names)
      (progn
        (kill-region (point-min) (point-max))
        (bury-buffer)
        nil)
    t))

(add-hook 'kill-buffer-query-functions 'kill-buffer-query-functions-maybe-bury)

(defun my-kill-buffer (buffer)
  "Protect some special buffers from getting killed."
  (interactive (list (current-buffer)))
  (if (member (buffer-name buffer) bury-buffer-names)
      (call-interactively 'bury-buffer buffer)
    (kill-buffer buffer)))

(defun indent-whole-buffer ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(defun kill-all-buffers-except-current ()
  "Kill all buffers except current buffer."
  (interactive)
  (let ((current-buf (current-buffer)))
    (dolist (buffer (buffer-list))
      (set-buffer buffer)
      (unless (eq current-buf buffer)
        (kill-buffer buffer)))))

(defun custom-ignore-buffer (str)
  (or
   ;;buffers I don't want to switch to
   (string-match "\\*Buffer List\\*" str)
   (string-match "\\*Compile-Log\\*" str)
   (string-match "^TAGS" str)
   (string-match "^\\*Messages\\*$" str)
   (string-match "^\\*Completions\\*$" str)
   (string-match "^\\*Flymake error messages\\*$" str)
   (string-match "^\\*Flycheck error messages\\*$" str)
   (string-match "^\\*SPEEDBAR\\*" str)
   (string-match "^ " str)

   ;;Test to see if the window is visible on an existing visible frame.
   ;;Because I can always ALT-TAB to that visible frame, I never want to
   ;;Ctrl-TAB to that buffer in the current frame.  That would cause
   ;;a duplicate top-level buffer inside two frames.
   (memq str
         (mapcar
          (lambda (x)
            (buffer-name
             (window-buffer
              (frame-selected-window x))))
          (visible-frame-list)))
   ))

(defun custom-switch-buffer (ls)
  "Switch to next buffer in ls skipping unwanted ones."
  (let* ((ptr ls)
         bf bn go
         )
    (while (and ptr (null go))
      (setq bf (car ptr)  bn (buffer-name bf))
      (if (null (custom-ignore-buffer bn))        ;skip over
   (setq go bf)
        (setq ptr (cdr ptr))
        )
      )
    (if go
        (switch-to-buffer go))))

(defun custom-prev-buffer ()
  "Switch to previous buffer in current window."
  (interactive)
  (custom-switch-buffer (reverse (buffer-list))))

(global-set-key [(hyper down)] 'custom-prev-buffer)

(defun custom-next-buffer ()
  "Switch to the other buffer (2nd in list-buffer) in current window."
  (interactive)
  (bury-buffer (current-buffer))
  (custom-switch-buffer (buffer-list)))

(global-set-key [(hyper up)] 'custom-next-buffer)

(defun copy-full-path-to-kill-ring ()
  "copy buffer's full path to kill ring"
  (interactive)
  (when buffer-file-name
    (kill-new (file-truename buffer-file-name))))

(defun describe-variable-short (var)
  (interactive "vVariable: ")
  (message (format "%s: %s" (symbol-name var) (symbol-value var))) )

(defun get-buffer-path ()
  "print the buffer path in the mini buffer"
  (interactive)
  (when buffer-file-name
    (kill-new (file-truename buffer-file-name))
    (message (format "%s" (file-truename buffer-file-name)))
    ))

(defun copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(defun open-with ()
  "Simple function that allows us to open the underlying
file of a buffer in an external program."
  (interactive)
  (when buffer-file-name
    (shell-command (concat
                    (if (eq system-type 'darwin)
                        "open"
                      (read-shell-command "Open current file with: "))
                    " "
                    buffer-file-name))))

(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)))))))

(defun move-buffer-file (dir)
  "Move both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
         (newname (concat dir "/" name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (copy-file filename newname 1)
      (delete-file filename)
      (set-visited-file-name newname)
      (set-buffer-modified-p nil)
      t)))

(global-auto-revert-mode 1)

(setq auto-save-default nil)

(setq make-backup-files nil)

(setq require-final-newline t)

(req-package whitespace-cleanup-mode
             :diminish ""
             :init (global-whitespace-cleanup-mode))

(defun beginning-of-line-dwim ()
  "Toggles between moving point to the first non-whitespace character, and
the start of the line."
  (interactive)
  (let ((start-position (point)))
    (move-beginning-of-line nil)
    (when (= (point) start-position)
        (back-to-indentation))))

(global-set-key (kbd "C-a") 'beginning-of-line-dwim)
(global-set-key (kbd "H-<left>") 'beginning-of-line-dwim)

(req-package goto-last-change
             :diminish ""
             :bind ("H-M-<left>" . goto-last-change))

(defun my-more-like-this (arg)
  (interactive "p")
  (if (not (region-active-p))
      (select-at-point)
    (mc/mark-next-like-this arg)
    )
  )

(defun my-previous-like-this (arg)
  (interactive "p")
  (if (not (region-active-p))
      (select-at-point)
    (mc/mark-previous-like-this arg)
    )
  )

(defun select-at-point ()
  (interactive)
  (setq default (thing-at-point 'word))
  (setq bds (bounds-of-thing-at-point 'word))
  (setq p1 (car bds))
  (setq p2 (cdr bds))
  (set-mark p1)
  (goto-char p2)
)

(req-package volatile-highlights
             :diminish volatile-highlights-mode
             :init (volatile-highlights-mode t))

(setq-default indent-tabs-mode nil)

(setq-default tab-width 4)

(req-package expand-region
             :diminish ""
             :bind (("H-e" . er/expand-region)
                    ("H-S-e" . er/contract-region)))

(req-package move-text
             :diminish ""
             :bind (("H-S-<up>" . move-text-up)
                    ("H-S-<down>" . move-text-down)))

(delete-selection-mode +1)

(req-package undo-tree
             :ensure undo-tree
             :diminish ""
             :init (global-undo-tree-mode))

(setq cua-enable-cua-keys nil)
(setq cua-highlight-region-shift-only t)
(setq cua-toggle-set-mark nil)
(cua-mode)

(req-package autopair
             :diminish autopair-mode
             :init
             (progn
              (autopair-global-mode)
              (setq show-paren-delay 0)
              (show-paren-mode t)
              (setq show-paren-style 'parenthesis)
              (add-hook 'term-mode-hook
                        #'(lambda ()
                            (setq autopair-dont-activate t)
                            (autopair-mode -1)))
              ))

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(defun toggle-letter-case ()
  "Toggle the letter case of current word or text selection.
Toggles between: “all lower”, “Init Caps”, “ALL CAPS”."
  (interactive)
  (let (p1 p2 (deactivate-mark nil) (case-fold-search nil))
    (if (region-active-p)
        (setq p1 (region-beginning) p2 (region-end))
      (let ((bds (bounds-of-thing-at-point 'word) ) )
        (setq p1 (car bds) p2 (cdr bds)) ) )

    (when (not (eq last-command this-command))
      (save-excursion
        (goto-char p1)
        (cond
         ((looking-at "[[:lower:]][[:lower:]]") (put this-command 'state "all lower"))
         ((looking-at "[[:upper:]][[:upper:]]") (put this-command 'state "all caps") )
         ((looking-at "[[:upper:]][[:lower:]]") (put this-command 'state "init caps") )
         ((looking-at "[[:lower:]]") (put this-command 'state "all lower"))
         ((looking-at "[[:upper:]]") (put this-command 'state "all caps") )
         (t (put this-command 'state "all lower") ) ) ) )

    (cond
     ((string= "all lower" (get this-command 'state))
      (upcase-initials-region p1 p2) (put this-command 'state "init caps"))
     ((string= "init caps" (get this-command 'state))
      (upcase-region p1 p2) (put this-command 'state "all caps"))
     ((string= "all caps" (get this-command 'state))
      (downcase-region p1 p2) (put this-command 'state "all lower")) )
    ))

(global-set-key (kbd "H-k") 'toggle-letter-case)

(defun sort-lines-nocase ()
  (interactive)
  (let ((sort-fold-case t))
    (call-interactively 'sort-lines)))

(defun replace-string-withcase ()
  (interactive)
  (let ((case-fold-search nil))
    (call-interactively 'replace-string)))

(defun fix-quotes (beg end)
  "Replace 'smart quotes' in buffer or region with ascii quotes."
  (interactive "r")
  (format-replace-strings '(("\x201C" . "\"")
                            ("\x201D" . "\"")
                            ("\x2018" . "'")
                            ("\x2019" . "'"))
                          nil beg end))

(defun remove-control-m ()
  (interactive)
  (goto-char 1)
  (while (search-forward "
" nil t)
    (replace-match "" t nil)))

(req-package wrap-region
             :diminish ""
             :init
             (progn
               (wrap-region-global-mode t)
               (setq wrap-region-keep-mark t)
               (add-to-list 'wrap-region-tag-active-modes 'sgml-mode)
               (defadvice wrap-region-trigger (before disable-autopair activate)
                 (if (region-active-p)
                     (autopair-global-mode -1)))
               (defadvice wrap-region-trigger (after re-enable-autopair activate)
                 (if (region-active-p)
                     (autopair-global-mode 1)))
               ))

(req-package iedit)

(add-hook 'sgml-mode-hook
  (lambda ()
    (require 'rename-sgml-tag)
    (define-key sgml-mode-map (kbd "C-c C-r") 'rename-sgml-tag)))

(req-package zencoding-mode
             :diminish ""
             :init (add-hook 'sgml-mode-hook 'zencoding-mode))

(req-package unfill
             :diminish ""
             :init (setq-default fill-column 80))

(setq-default show-trailing-whitespace t)

(defun fix-whitespace-in-region (beg end)
  "replace all whitespace in the region with single spaces"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (re-search-forward "\\s-+" nil t)
        (replace-match " ")))))

(global-set-key (kbd "H-M-SPC") 'fix-whitespace-in-region)

(req-package multiple-cursors
             :diminish "")

(req-package anzu
             :diminish anzu-mode
             :init (global-anzu-mode +1))

(req-package visual-regexp-steroids
             :require visual-regexp
             :diminish ""
             :bind (("C-c r" . vr/replace)
                    ("C-c q" . vr/query-replace)
                    ("C-r" . vr/isearch-backward)
                    ("C-s" . vr/isearch-forward)))

(req-package flycheck
             :require (dash s f exec-path-from-shell flycheck-color-mode-line)
             :ensure flycheck
             :diminish (global-flycheck-mode . " ✓ ")
             :defer t
             :init
             (progn
               (add-hook 'after-init-hook 'global-flycheck-mode)
               (eval-after-load "flycheck"
                 '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))
               ))

(req-package browse-kill-ring
             :init (browse-kill-ring-default-keybindings))

(winner-mode 1)

(global-set-key [C-tab] 'other-window)

(global-unset-key [C-b])
(global-set-key [C-b down] 'other-window)
(global-set-key [C-b up] 'previous-multiframe-window)

(req-package workgroups
             :diminish ""
             :init
             (progn
               (defun wg-mode-line-add-display () nil)
               (defun wg-mode-line-remove-display () nil)
               (setq wg-prefix-key (kbd "C-z")
                     wg-mode-line-on nil
                     wg-file (concat dotfiles-dir "/workgroups")
                     wg-use-faces nil
                     wg-morph-on nil)
               (workgroups-mode 1)
               ))

(req-package git-gutter+
             :diminish ""
             :init (global-git-gutter+-mode t))

(req-package magit)

(req-package monky
             :init (setq monky-process-type 'cmdserver))

(setq system-uses-terminfo nil)

(setq explicit-shell-file-name "/bin/zsh")

(req-package multi-term)

(req-package tramp
             :init (setq tramp-default-method "ssh"))

(req-package dired-details+)

(eval-after-load "dired-aux"
  '(add-to-list 'dired-compress-file-suffixes
                '("\\.zip\\'" ".zip" "unzip")))

(setq-default dired-listing-switches "-aGglhvop")
(setq dired-recursive-copies 'always)

(defadvice shell-command (after shell-in-new-buffer (command &optional output-buffer error-buffer))
  (when (get-buffer "*Async Shell Command*")
    (with-current-buffer "*Async Shell Command*"
      (rename-uniquely))))
(ad-activate 'shell-command)

(when (eq system-type 'darwin)
  (req-package ls-lisp
               :init (setq ls-lisp-use-insert-directory-program nil)))

(setq dired-recursive-copies 'always)

(add-hook 'dired-mode-hook
          (lambda ()
              (define-key dired-mode-map (kbd "M-<up>") 'dired-up-directory)))

(add-hook 'org-mode-hook
  (lambda()
    (local-unset-key (kbd "C-<tab>")) ; allow switching between frames
    ))

(req-package org-bullets
             :diminish ""
             :init (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(req-package deft
             :diminish ""
             :defer t
             :init
             (progn
               (setq deft-directory "~/Dropbox/Notes")
               (setq deft-extension "md")
               (setq deft-text-mode 'markdown-mode)
               (setq deft-use-filename-as-title t)
               ))

(add-hook 'prog-mode-hook 'subword-mode)

(req-package cython-mode
             :diminish "")

(req-package jinga2-mode
             :diminish ""
             :mode ("\\.jinja2\\'" . jinja2-mode))

(req-package xml-mode
             :diminish ""
             :mode ("\\.xsd\\'" . xml-mode))

(req-package xml-mode
             :diminish ""
             :mode ("\\.fo\\'" . xml-mode))

(req-package xquery-mode
             :diminish ""
             :mode ("\\.xq\\'" . xquery-mode))

(req-package yaml-mode
             :diminish ""
             :init
             (progn
               (add-to-list 'auto-mode-alist '("\\.ya?ml" . yaml-mode))
               (add-to-list 'auto-mode-alist '("\\.ylog" . yaml-mode))
               (add-to-list 'auto-mode-alist '("\\.yamlog" . yaml-mode))
               (add-hook 'yaml-mode-hook
                         '(lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
               ))

(req-package markdown-mode
             :diminish ""
             :mode ("\\.md\\'" . markdown-mode))

(req-package unbound)

(req-package-finish)
