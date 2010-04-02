
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

(add-to-list 'load-path "~/.emacs.d/plugins")

(nconc same-window-buffer-names '("*Apropos*" "*Buffer List*" "*Help*" "*anything*"))

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

;; {{{ Color Theme
(require 'color-theme)
(color-theme-initialize)
;; (color-theme-charcoal-black)
(color-theme-billw)
;; (color-theme-clarity-and-beauty)
;; (color-theme-cooper-dark)
;; (color-theme-scintilla)
;; (color-theme-sitram-nt)
;; (color-theme-sitram-solaris)
;; (color-theme-sublte-hacker)
;; (color-theme-taming-mr-arneson)
;; (color-theme-white-on-grey)

(setq my-color-themes
      (list 'color-theme-charcoal-black
	    'color-theme-billw
	    'color-theme-sitaramv-solaris
	    'color-theme-clarity
	    'color-theme-jsc-dark
	    'color-theme-scintilla
	    'color-theme-subtle-hacker
	    'color-theme-taming-mr-arneson
	    'color-theme-pok-wog))

(defun my-theme-set-default () ; Set the first row
  (interactive)
  (setq theme-current my-color-themes)
  (funcall (car theme-current)))

(defun my-describe-theme () ; Show the current theme
  (interactive)
  (message "%s" (car theme-current)))

;; Set the next theme (fixed by Chris Webber - tanks)
(defun my-theme-cycle ()		
  (interactive)
  (setq theme-current (cdr theme-current))
  (if (null theme-current)
      (setq theme-current my-color-themes))
  (funcall (car theme-current))
  (funcall (car theme-current))
  (message "%S" (car theme-current)))

(setq theme-current my-color-themes)
(setq color-theme-is-global nil) ; Initialization
(my-theme-set-default)
(global-set-key [f12] 'my-theme-cycle)


;; }}}

;; Org Stuff {{{
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

(setq journal-root-dir "/Users/zkim/org/")
(defun today-org ()
  (interactive)
  (let ((today (concat journal-root-dir (format-time-string "%Y-%m-%d") ".org")))
    (if (file-exists-p today)
	(find-file-existing today)
	(with-temp-buffer
	  (insert "* Tasks\n\n* Journal\n\n* Notes")
	  (when (file-writable-p today)
	    (write-region (point-min) (point-max) today))
	  (find-file-existing today)))))
;; }}}

;; YA Snippet {{{
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

(defun clojure-namespace-take-while-not-found (col accu match)
  (if (string= (car col) match)
      accu
    (clojure-namespace-take-while-not-found (cdr col) (cons (car col) accu) match)))

(defun clojure-namespace-for-buffer ()
  "Returns a string representing the guessed clojure namespace for the current buffer.
   i.e. /path/to/src/com/napplelabs/stuff.clj -> 'com.napplelabs.stuff'"
  (let ((parts (reverse (split-string (buffer-file-name) "/" t))))
    (let ((col (reverse (clojure-namespace-take-while-not-found parts () "src"))))
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
(add-hook 'scala-mode-hook
          '(lambda ()
             (yas/minor-mode-on)))

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

;; Window Stuff
(winner-mode 1)

;; Anything
(require 'anything)
(require 'anything-config)

(setq anything-sources
      (list
       anything-c-source-buffers+
       anything-c-source-file-name-history
       anything-c-source-locate
       anything-c-source-emacs-commands
       ))

(defun buffers-and-files-anything ()
  (interactive)
  (anything-other-buffer
   '(anything-c-source-buffers
     anything-c-source-file-name-history
     anything-c-source-info-pages
     anything-c-source-info-elisp
     anything-c-source-man-pages
     anything-c-source-locate
     anything-c-source-emacs-commands)
   " *buffers-and-files-anything*"))


;; Idle Hightlight
(require 'idle-highlight)

;;{{{ Clojure Mode
(require 'clojure-mode)
(add-hook 'clojure-mode-hook 'idle-highlight)
(add-hook 'clojure-mode-hook 'paredit-mode)

(add-hook 'slime-connected-hook (lambda ()
                                  (interactive)
                                  (slime-redirect-inferior-output)))
;;}}}

;; Yegge Stuff http://steve.yegge.googlepages.com/effective-emacs
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
					;(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
					;(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; NXML
(require 'nxml-mode)

;;Highlight Color
(set-face-background 'region "blue") ; Set region background color 

;; Hi-line (highlights current line)
;; (global hi-line 1)

;;Paredit
(require 'paredit)

;; Temp Files
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

(message user-temporary-file-directory)

(desktop-save-mode 0)
					;(setq history-length 250)
					;(add-to-list 'desktop-globals-to-save 'file-name-history)


;; Hide-Show Mode
(add-hook 'clojure-mode-hook 'hs-minor-mode)
					;(define-key 'hs-mode-map (kbd "C-+") 'hs-toggle-hiding)
(global-set-key (kbd "C-=") 'hs-toggle-hiding)
(global-set-key (kbd "C-+") 'hs-toggle-selective-display)

(defun kill-start-of-line ()
  "kill from point to start of line"
  (interactive)
  (kill-line 0))

(defun hs-toggle-selective-display (column)
      (interactive "P")
      (set-selective-display
       (or column
           (unless selective-display
             (1+ (current-column))))))

(set-default-font "Inconsolata")
(set-face-attribute 'default nil :height 150)

(defun toggle-fullscreen () (interactive) (ns-toggle-fullscreen))
(ns-toggle-fullscreen)
(global-set-key [f11] 'toggle-fullscreen)


;; Emacs Client Setup
(server-start)

;; Show Paren Mode
(setq show-paren-style 'expression)
(add-hook 'clojure-mode-hook 'show-paren-mode)
(defun set-show-paren-face-background ()
  (set-face-background 'show-paren-match-face "#333333"))
(add-hook 'show-paren-mode-hook 'set-show-paren-face-background)

;; magit
;;(require 'magit)

;; Mode Line
(setq-default 
 mode-line-format	      
 (list '(
  #("-" 0 1 (help-echo "mouse-1: Select (drag to resize)\nmouse-2: Make current window occupy the whole frame\nmouse-3: Remove current window from display"))
  mode-line-mule-info 
  mode-line-client 
  mode-line-modified 
  mode-line-remote 
  mode-line-frame-identification 
  (buffer-file-name " %f" 
              (dired-directory 
               dired-directory 
                (revert-buffer-function " %b" 
               ("%b - Dir:  " default-directory)))) 
  #("   " 0 3 (help-echo "mouse-1: Select (drag to resize)\nmouse-2: Make current window occupy the whole frame\nmouse-3: Remove current window from display"))
  mode-line-position 
  (vc-mode vc-mode) 
  #("  " 0 2 (help-echo "mouse-1: Select (drag to resize)\nmouse-2: Make current window occupy the whole frame\nmouse-3: Remove current window from display"))
  mode-line-modes 
  (which-func-mode ("" which-func-format #("--" 0 2 ...)))
  (global-mode-string ("" global-mode-string #("--" 0 2 ...))) 
  #("-%-" 0 3 (help-echo "mouse-1: Select (drag to resize)\nmouse-2: Make current window occupy the whole frame\nmouse-3: Remove current window from display")))))

;; Ruby / Rails

(require 'rinari)
(add-to-list 'load-path "~/.emacs.d/plugins/rhtml")
(require 'rhtml-mode)
(add-hook 'rhtml-mode-hook
     	  (lambda () (rinari-launch)))

(setq rinari-tags-file-name "TAGS")

(load-file "~/.emacs.d/.keys")


