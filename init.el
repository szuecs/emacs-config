;; Start emacs server. Use `emacsclient -t'.
(server-start)

(setq make-backup-files nil)
(blink-cursor-mode 0)

(setq menu-bar-mode t)
;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

; setup mac
(defvar is-darwin (string-equal system-type "darwin"))
(unless (not is-darwin)
  (setq mac-option-key-is-meta nil)
  (setq mac-command-key-is-meta t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier nil)
  (setenv "PATH"
    (concat
      "/usr/local/bin" ":"
      "/usr/local/share/python" ":"
      "/usr/texbin" ":"
      (getenv "PATH")))
  (setenv "GOROOT" "/usr/local/go")
)

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session
(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)

;; init package
(require 'package)
;; enable melpa if it isn't enabled
(when (not (assoc "melpa" package-archives))
    (setq package-archives (append '(("melpa" . "https://melpa.org/packages/")) package-archives)))
;(package-initialize)

;; refresh package list if it is not already available
(when (not package-archive-contents) (package-refresh-contents))
;; install use-package if it isn't already installed
(when (not (package-installed-p 'use-package))
    (package-install 'use-package))

;;
;(add-hook 'after-init-hook 'global-company-mode)

;; load my config dir
(defun load-directory (dir)
	(let ((load-it (lambda (f)
		(load-file (concat (file-name-as-directory dir) f)))
		))
		(mapc load-it (directory-files dir nil "\\.el$"))))
(load-directory "~/.emacs.d/sszuecs/")

;; gopls
;(require 'gopls-config)
;
;(custom-set-variables
; ;; custom-set-variables was added by Custom.
; ;; If you edit it by hand, you could mess it up, so be careful.
; ;; Your init file should contain only one such instance.
; ;; If there is more than one, they won't work right.
; '(package-selected-packages '(ess yasnippet company-lsp)))
;(custom-set-faces
; ;; custom-set-faces was added by Custom.
; ;; If you edit it by hand, you could mess it up, so be careful.
; ;; Your init file should contain only one such instance.
; ;; If there is more than one, they won't work right.
; )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(company eglot go-mode markdown-mode yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
