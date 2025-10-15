;;; global dev mode settings
;;; useful for each language
(global-set-key (kbd "C-/") 'comment-or-uncomment-region)

;; chmod 711 if there is a shebang line
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; disable flyspell
(setq flyspell-mode nil)

; TODO(sszuecs) fix it
;(add-to-list 'load-path (concat my-libs-dir "expand-region"))
;(require 'expand-region)
;(global-set-key (kbd "C-=") 'er/expand-region)

; save hooks
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default show-trailing-whitespace t)

;;; auto completion
(add-to-list 'load-path (concat my-libs-dir "popup"))
;(add-to-list 'load-path (concat my-libs-dir "auto-complete"))
;(require 'auto-complete-config)
;(ac-config-default)
;(global-auto-complete-mode nil)
;(setq
;      ac-auto-show-menu t
;      ac-candidate-limit nil
;      ac-delay 0.5
;      ac-disable-faces (quote (font-lock-comment-face font-lock-doc-face))
;      ac-ignore-case 'smart
;      ac-menu-height 10
;      ac-quick-help-delay 1.5
;      ac-quick-help-prefer-pos-tip t
;      ac-use-quick-help nil
;      ; Start auto-completion after 2 characters of a word
;      ac-auto-start 2
;      ; case sensitivity is important when finding matches
;      ac-ignore-case nil
;)

; TODO fix it
;; less-css
;(add-to-list 'load-path (concat my-libs-dir "less-css-mode"))
;(require 'less-css-mode)

; cc-mode
(add-to-list 'auto-mode-alist '("\\.ext\\'" . c-mode))
; linux kernel style
(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook '(lambda ()
          ;; ac-omni-completion-sources is made buffer local so
          ;; you need to add it to a mode hook to activate on
          ;; whatever buffer you want to use it with.  This
          ;; example uses C mode (as you probably surmised).

          ;; auto-complete.el expects ac-omni-completion-sources to be
          ;; a list of cons cells where each cell's car is a regex
          ;; that describes the syntactical bits you want AutoComplete
          ;; to be aware of. The cdr of each cell is the source that will
          ;; supply the completion data.  The following tells autocomplete
          ;; to begin completion when you type in a . or a ->

          (add-to-list 'ac-omni-completion-sources
                       (cons "\\." '(ac-source-semantic)))
          (add-to-list 'ac-omni-completion-sources
                       (cons "->" '(ac-source-semantic)))

          ;; ac-sources was also made buffer local in new versions of
          ;; autocomplete.  In my case, I want AutoComplete to use
          ;; semantic and yasnippet (order matters, if reversed snippets
          ;; will appear before semantic tag completions).

          (setq ac-sources '(ac-source-semantic ac-source-yasnippet))

          (autopair-mode nil)
          (subword-mode 1)
          (c-toggle-electric-state)
          (c-toggle-auto-newline)
          (c-toggle-hungry-state)
          (setq c-syntactic-indentation 1)
          (setq c-default-style '((java-mode . "java")
                                  (awk-mode . "awk")
                                  (other . "gnu")))
          ;(setq c-basic-offset 4)
          ;; Add kernel style
          (c-add-style
           "linux-tabs-only"
           '("linux" (c-offsets-alist
                      (arglist-cont-nonempty
                       c-lineup-gcc-asm-reg
                       c-lineup-arglist-tabs-only))))))

;; automatically fille comments but no code
(add-hook 'c-mode-common-hook
          (lambda ()
            (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              (when (and filename
                         (string-match (expand-file-name "~/src/linux-trees") ;; kernel parent dir
                                       filename))
                (setq indent-tabs-mode t)
                (setq show-trailing-whitespace t)
                (c-set-style "linux-tabs-only")))

                ;(auto-fill-mode 1) ; deactivate auto linebreak
                (set (make-local-variable 'fill-nobreak-predicate)
                     (lambda ()
                       (not (eq (get-text-property (point) 'face)
                                'font-lock-comment-face))))))

(provide '60_devmodes)
;;; 60_devmodes.el ends here
