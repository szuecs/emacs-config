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

