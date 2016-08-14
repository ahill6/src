; run with emacs -script install.el

(require 'package)

; find package information from following archives

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))

(package-initialize)


(mapcar (lambda (package)
          ; install package if not already installed
          (unless (package-installed-p package)
            (package-install package)))

        ; list of packages to be installed
        '(zenburn-theme
	  diff-hl

          neotree
          powerline
          markdown-mode
          color-theme))
