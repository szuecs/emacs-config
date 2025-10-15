;; set config variables
(defvar my-libs-dir "~/emacs-libs/"
  "Directory for elisp libraries without elpa")
(defvar my-config-dir "~/.emacs.d/sszuecs/"
  "Directory for elisp config files")
(defvar my-orgfile-dir "~/org/"
  "Directory for *.org files")
(defvar my-plugin-dir "~/.emacs.d/plugins/"
  "Directory for plugins")

; prefer utf8 encoding
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

; PATH
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(push "/usr/local/bin" exec-path)

; do not block input events
(setq redisplay-dont-pause t)

; C-<f11> maximize active window
(global-set-key (kbd "C-<f11>") 'maximize-window)
; C-<f10> resize window
(global-set-key (kbd "C-<f10>") 'resize-windows)

; get rid of confirmations
(setq confirm-nonexistent-file-or-buffer nil)
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(setq kill-buffer-query-functions
  (remq 'process-kill-buffer-query-function
         kill-buffer-query-functions))

;; ibuffer
(setq ibuffer-set-filter-groups-by-mode t)

;; ido
; fuzzy matching within minibuffer
(require 'ido)
(setq ido-enable-flex-matching t)
;  disable URL find file at point support
(setq ido-use-url-at-point t)
; magic guess
(setq ido-use-filename-at-point 'guess)
; sort buffer
(setq ido-file-extensions-order '(".el" ".org" ".go" ".pp" ".rb" ".py" ".r" ".c" ".h" ".js" ".xml" ".html" ".tmpl" ".txt" ".ini" ".cfg" ".cnf" ".cpp" ".clj" ".java" ".pl"))
; get rid of confirmations
(setq ido-create-new-buffer 'always)

; tramp
(setq tramp-default-method "ssh")

; use tex style input methods, such that we can use utf-8 chars easily
(set-input-method "TeX")
  ; you have to (toggle-input-method) if you want to use TeX style input method

; regex builder
(require 're-builder)
(setq reb-re-syntax 'string)

; use compile mode
(require 'compile)

; use <f1> to get a shell
(global-set-key [f1] 'eshell)

; occur-mode setup
; use <f2> to get buffer search with occur-mode
; use C-<f2> to search all buffers with the same mode
(global-set-key [f2] 'multi-occur-in-matching-buffers)


(defun get-buffers-matching-mode (mode)
  "Returns a list of buffers where their major-mode is equal to MODE"
  (let ((buffer-mode-matches '()))
   (dolist (buf (buffer-list))
     (with-current-buffer buf
       (if (eq mode major-mode)
           (add-to-list 'buffer-mode-matches buf))))
   buffer-mode-matches))

(defun multi-occur-in-this-mode ()
  "Show all lines matching REGEXP in buffers with this major mode."
  (interactive)
  (multi-occur
   (get-buffers-matching-mode major-mode)
   (car (occur-read-primary-args))))

;; global key for `multi-occur-in-this-mode' - you should change this.
(global-set-key (kbd "C-<f2>") 'multi-occur-in-this-mode)

; TODO(sszuecs) fix it
;; install flycheck
;(package-install 'flycheck)
;(add-hook 'after-init-hook #'global-flycheck-mode)
;; run on save
;(setq flycheck-check-syntax-automatically '(mode-enabled save))

;; enable abbrev-mode for auto-correction
;; add new entries to the global table with C-x a i g
(setq default-abbrev-mode t)

;
