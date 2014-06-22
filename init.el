;;; init.el --- custom init file
;;;
;;; Commentary:
;;; init file which creates and loads a config.el file containing
;;; custom settings for Emacs

;;; Code:

(package-initialize)
(require 'ob-tangle)
(setq dotfiles-dir (file-name-directory
                    (or (buffer-file-name) load-file-name)))
(org-babel-load-file (expand-file-name "config.org" dotfiles-dir))

;;; init.el ends here
