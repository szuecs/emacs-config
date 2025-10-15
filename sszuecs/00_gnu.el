(defvar is-gnu-linux (string-equal system-type "gnu/linux"))

(unless (not is-gnu-linux)
  (setenv "PATH" (concat (getenv "PATH") ":/usr/share/go/bin:/usr/local/go/bin:/home/sszuecs/go/bin"))
  (setenv "GOROOT" "/usr/share/go")
  ; make accent work again
  (require 'iso-transl)
)
