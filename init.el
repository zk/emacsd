
(defvar emacs-root  "~/.emacs.d/") ;; location of the emacs configuration source code tree

(defun append-to-load-path (path-element)
  (add-to-list 'load-path (concat emacs-root path-element)))


;; ELPA
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

(add-to-list 'load-path "~/.emacs.d/plugins")

(nconc same-window-buffer-names '("*Apropos*" "*Buffer List*" "*Help*" "*anything*"))

;; Imports
(require 'color-theme)
(require 'javadoc-help)
(require 'line-num)                 ; line numbers in left margin
(require 'ido)                      ; Fun stuff that happens in bottom bar
(require 'find-file-in-project)     ; find file in project
(require 'eproject)
(require 'eproject-extras)
(require 'anything-eproject)
(require 'anything-match-plugin)
(require 'anything)
(require 'anything-config)
(require 'idle-highlight)
(require 'nxml-mode)
(require 'paredit)
(require 'yasnippet-bundle)
(require 'clojure-mode)

;; TODELETE: (require 'project-buffer-mode) 

;; Appearance
;;; Transparency
(set-frame-parameter (selected-frame) 'alpha '(96 50))
(add-to-list 'default-frame-alist '(alpha 96 50))

;;; Color Theme
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


;; General Editing Features {

;; Emacs Client Setup
(server-start)

;; IDO
(ido-mode t)
(setq ido-enable-flex-matching t)   ; enable fuzzy matching
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

;; Autosave - keep autosaved and backup files inc one place {
(defvar autosave-dir
  (concat emacs-root "autosave/autosaved/"))
(defvar backup-dir
  (concat emacs-root "autosave/backups/"))
(append-to-load-path "autosave")

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


;; eproject
(define-project-type lein (generic)
  (look-for "project.clj")
  :relavent-files (".*"))

(define-project-type git (generic)  ; Any dir with a .git directory
  (look-for ".git")
  :relavent-files (".*"))

;; Anything

(setq anything-sources
      (list
       anything-c-source-buffers+
       anything-c-source-file-name-history
;       anything-c-source-eproject-buffers
       anything-c-source-eproject-files
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

(set-face-background 'region "blue") ; Set region background color 

;; }


;; Languages

;; Emacs Lisp {
(add-hook 'emacs-lisp-mode 'turn-on-eldoc-mode)  ; Eldoc (lisp param list)
;; }

;; Clojure {
(add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)   ; Eldoc (lisp param list)
(add-hook 'clojure-mode-hook 'idle-highlight)
(add-hook 'clojure-mode-hook 'enable-paredit-mode)
;(add-hook 'clojure-mode-hook 'yas/minor-mode-on)
;; }

;; Org Stuff {
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

(setq journal-root-dir "/Users/zkim/Dropbox/org/")
(defun today-file-name () (concat journal-root-dir (format-time-string "%Y-%m-%d") ".org"))

(defun today-org ()
  (interactive)
  (let ((today (today-file-name)))
    (if (file-exists-p today)
	(find-file-existing today)
      (with-temp-buffer
	(insert "* Tasks\n\n* Journal\n\n* Notes")
	(when (file-writable-p today)
	  (write-region (point-min) (point-max) today))
	(find-file-existing today)))))
;; }

;;; YA Snippet {{{
;(setq yas/root-directory "~/.emacs.d/snippets/")
;(yas/load-directory yas/root-directory)

;; (defun yas/advise-indent-function (function-symbol)
;;   (eval `(defadvice ,function-symbol (around yas/try-expand-first activate)
;;            ,(format
;;              "Try to expand a snippet before point, then call `%s' as usual"
;;              function-symbol)
;;            (let ((yas/fallback-behavior nil))
;;              (unless (and (interactive-p)
;;                           (yas/expand))
;;                ad-do-it)))))

;; (yas/advise-indent-function 'indent-or-expand)

;; (defun clojure-namespace-clean-extension (path-part)
;;   (car (split-string path-part "\\." t)))

;; (defun clojure-namespace-take-while-not-found (col accu match)
;;   (if (string= (car col) match)
;;       accu
;;     (clojure-namespace-take-while-not-found (cdr col) (cons (car col) accu) match)))

;; (defun clojure-namespace-for-buffer ()
;;   "Returns a string representing the guessed clojure namespace for the current buffer.
;;    i.e. /path/to/src/com/napplelabs/stuff.clj -> 'com.napplelabs.stuff'"
;;   (let ((parts (reverse (split-string (buffer-file-name) "/" t))))
;;     (let ((col (reverse (clojure-namespace-take-while-not-found parts () "src"))))
;;       (mapconcat 'identity (reverse (cons (clojure-namespace-clean-extension (car col)) (cdr col))) "."))))
;; }}}



;; SCALA! {
(append-to-load-path "plugins/scala-mode")
(require 'scala-mode)
(setq auto-mode-alist (cons '("\\.scala$" . scala-mode) auto-mode-alist))
(load-file (concat emacs-root "plugins/sbt.el"))
(setq compilation-scroll-output t)
(setq compilation-auto-jump-to-first-error t)
(add-hook 'scala-mode-hook
          '(lambda ()
             (yas/minor-mode-on)))
;; }

;;Shell
(ansi-color-for-comint-mode-on)

;; Window Stuff
(winner-mode 1)

;; Hide-Show Mode
(add-hook 'clojure-mode-hook 'hs-minor-mode)
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


;; Show Paren Mode
(setq show-paren-style 'expression)
(add-hook 'clojure-mode-hook 'enable-show-paren-mode)
(defun enable-show-paren-mode ()
  (interactive)
  (show-paren-mode t))
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

(require 'markdown-mode)

(require 'yaml-mode)

(load-file "~/.emacs.d/plugins/cedet/common/cedet.el")
(global-ede-mode t)
(semantic-load-enable-minimum-features)
(require 'semantic-ia)

(add-to-list 'load-path "~/.emacs.d/plugins/ecb240")
(require 'ecb)
(require 'ecb-autoloads)
(setq ecb-tip-of-the-day nil)
;(ecb-activate)

(setq inhibit-startup-screen t)
(today-org)
(setq initial-buffer-choice (today-file-name))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-layout-window-sizes (quote (("left8" (0.24203821656050956 . 0.2857142857142857) (0.24203821656050956 . 0.22448979591836735) (0.24203821656050956 . 0.2857142857142857) (0.24203821656050956 . 0.1836734693877551)))))
 '(ecb-options-version "2.40"))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; Clojure run test
(defun run-tests-for-namespace (ns)
  )

(defun slime-clojure-run-tests ()
  (interactive)
  (slime-interactive-eval "(run-tests)"))

(require 'goto-last-change)

;; NXHTML
(load "~/.emacs.d/plugins/nxhtml/autostart.el")
(require 'mumamo-fun)

(load "~/.emacs.d/plugins/lein.el")

;; Bar Cursor
(require 'bar-cursor)
(bar-cursor-mode 1)

(load-file "~/.emacs.d/.keys")

