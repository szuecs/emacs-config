;; yasnippet
(use-package yasnippet
	:ensure t
	:commands yas-minor-mode
	:config (progn
		(setq yas-snippet-dirs '("~/.emacs.d/plugins/yasnippet_szuecs/snippets"))
	)
	:hook (
		(go-mode . yas-minor-mode)
	))
(yas-global-mode 1)
