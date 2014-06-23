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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("121ba9dc71c1c23a73535302b216010a1f0d1ad342d9ddf3844da0c683607008" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
