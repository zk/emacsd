
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

(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

(require 'project-buffer-mode)

(setq ido-execute-command-cache nil)
 (defun ido-execute-command ()
   (interactive)
   (call-interactively
    (intern
     (ido-completing-read
      "M-x "
      (progn
        (unless ido-execute-command-cache
          (mapatoms (lambda (s)
                      (when (commandp s)
                        (setq ido-execute-command-cache
                              (cons (format "%S" s) ido-execute-command-cache))))))
        ido-execute-command-cache)))))
    
 (add-hook 'ido-setup-hook
           (lambda ()
             (setq ido-enable-flex-matching t)
             (global-set-key "\M-x" 'ido-execute-command)))


(set-frame-parameter (selected-frame) 'alpha '(96 50))
(add-to-list 'default-frame-alist '(alpha 96 50))

(require 'color-theme)
(color-theme-initialize)
(color-theme-charcoal-black)