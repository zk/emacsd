
;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))


(load-file "~/.emacs.d/.keys")

(add-to-list 'load-path "~/.emacs.d/plugins")


;; Anything
(require 'anything)
(require 'anything-config)

(setq anything-sources
      (list
       anything-c-source-emacs-commands
	   anything-c-source-files-in-current-dir+
       ))

(nconc same-window-buffer-names '("*Apropos*" "*Buffer List*" "*Help*"))

;; ElDoc (shows parameter list for function call currently editing)
(add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)

;; Javadoc-Help (http://javadochelp.sourceforge.net/)
(require 'javadoc-help)

(require 'line-num)

