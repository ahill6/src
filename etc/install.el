; run with emacs --script install.el

(require 'package)

; find package information from following archives
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)

(mapcar (lambda (package)
          ; install package if not already installed
          (unless (package-installed-p package)
            (package-install package)))

        ; list of packages to be installed
        '(zenburn-theme
          material-theme
          monokai-theme
          leuven-theme
          spacemacs-theme
          neotree
          powerline
          markdown-mode
          color-theme))