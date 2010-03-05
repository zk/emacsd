
(defvar emacs-root  "~/.emacs.d/") ;; location of the emacs configuration source code tree

(defun append-to-load-path (path-element)
  (add-to-list 'load-path (concat emacs-root path-element)))

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


(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;;{{{ YA Snippet
(require 'yasnippet-bundle)
(setq yas/root-directory "~/.emacs.d/snippets/")
(yas/load-directory yas/root-directory)
(add-hook 'clojure-mode-hook 'yas/minor-mode-on)

(defun yas/advise-indent-function (function-symbol)
  (eval `(defadvice ,function-symbol (around yas/try-expand-first activate)
           ,(format
             "Try to expand a snippet before point, then call `%s' as usual"
             function-symbol)
           (let ((yas/fallback-behavior nil))
             (unless (and (interactive-p)
                          (yas/expand))
               ad-do-it)))))

(yas/advise-indent-function 'indent-or-expand)

(defun clojure-namespace-clean-extension (path-part)
  (car (split-string path-part "\\." t)))

(defun clojure-namspace-take-while-not-found (col accu match)
  (if (string= (car col) match)
    accu
    (clojure-namespace-take-while-not-found (cdr col) (cons (car col) accu) match)))

(defun clojure-namespace-for-buffer ()
  "Returns a string representing the guessed clojure namespace for the current buffer.
   i.e. /path/to/src/com/napplelabs/stuff.clj -> 'com.napplelabs.stuff'"
  (let ((parts (reverse (split-string (buffer-file-name) "/" t))))
    (let ((col (reverse (take-while-not-found parts () "src"))))
      (mapconcat 'identity (reverse (cons (clojure-namespace-clean-extension (car col)) (cdr col))) "."))))
;;}}}

;;{{{ autosave

;; keep autosaved and backup files inc one place
(defvar autosave-dir
  (concat emacs-root "autosave/autosaved/"))
(defvar backup-dir
  (concat emacs-root "autosave/backups/"))
(append-to-load-path "autosave")
					;(require 'autosave_config)

;;}}}

;; SCALA!
(append-to-load-path "plugins/scala-mode")
(require 'scala-mode)
(setq auto-mode-alist (cons '("\\.scala$" . scala-mode) auto-mode-alist))
(load-file (concat emacs-root "plugins/sbt.el"))
(setq compilation-scroll-output t)
(setq compilation-auto-jump-to-first-error t)

;;Shell
(ansi-color-for-comint-mode-on)

;;find file in project
(require 'find-file-in-project)

;;eproject
(require 'eproject)
(require 'eproject-extras)
(define-project-type git (generic)
  (look-for ".git")
  :relavent-files (".*"))
(require 'anything-eproject)

;; Winner (Window Mangement)
(winner-mode 1)

;; Anything
(require 'anything)
(require 'anything-config)

(setq anything-sources
      (list
       anything-c-source-emacs-commands
       anything-c-source-files-in-current-dir+
       ))
