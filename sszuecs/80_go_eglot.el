(setenv "GOROOT" "/usr/share/go")
(setenv "GOPATH" (concat (getenv "HOME") "/go"))
(setenv "GOBIN" (concat (getenv "GOPATH") "/bin"))
(setenv "PATH" (concat (getenv "PATH")
    ":" (getenv "GOBIN")
    ":" (getenv "GOROOT") "/bin"
    ))
(push (getenv "GOBIN") exec-path)
(push (concat (getenv "GOROOT") "/bin") exec-path)

(require 'project)

(defun project-find-go-module (dir)
  (when-let ((root (locate-dominating-file dir "go.mod")))
    (cons 'go-module root)))

(cl-defmethod project-root ((project (head go-module)))
  (cdr project))

(add-hook 'project-find-functions #'project-find-go-module)

;; Optional: load other packages before eglot to enable eglot integrations.
;(require 'company)
;(require 'go-mode)

(require 'eglot)


(setq-default eglot-workspace-configuration
    '((:gopls .
        ((staticcheck . t)
         (matcher . "CaseSensitive")))))

(setq gofmt-command "goimports")

(use-package go-mode
	:ensure t
	:bind (
		("M-*" . pop-tag-mark)
		("M-i" . eglot-find-implementation)
		("M-r" . xref-find-references)
		("C-c C-r" . eglot-rename)
	)
	:hook (
		(go-mode . eglot-ensure)
		(before-save . gofmt-before-save) ; non gopls
		;(before-save . eglot-code-action-organize-imports) ;
		;not working, but M-x eglot-code-action-organize-imports
		;works
))

(use-package company
	:ensure t
	:diminish company-mode
	:hook
		(after-init . global-company-mode)
	:config
		;(setq company-backends '((company-capf :with company-yasnippet)))
		(setq company-idle-delay 0
			company-minimum-prefix-length 2
			company-selection-wrap-around t
			completion-ignore-case t
			company-show-quick-access t))

