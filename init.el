;; Packages
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
       '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Evil Mode Always
(use-package evil
  :ensure t
  :config
  (evil-mode 1)

  (use-package evil-leader
    :ensure t
    :config
    (global-evil-leader-mode))

  (use-package evil-surround
    :ensure t
    :config
    (global-evil-surround-mode)))

(setq evil-overriding-maps nil)
(setq evil-intercept-maps nil)

;; use vim search behavior (enables use of `cgn` to replace search-object & jump to next)
(evil-select-search-module 'evil-search-module 'evil-search)

;; Auto start emacs-keybound buffers in evil-motion state instead
;(setq evil-motion-state-modes (append evil-emacs-state-modes evil-motion-state-modes))
;(setq evil-emacs-state-modes nil)
(dolist (mode '(ag-mode
		flycheck-error-list-mode
		git-rebase-mode))
  (add-to-list 'evil-emacs-state-modes mode))

(use-package try
  :ensure t)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(use-package org-bullets
  :ensure t
  :config (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package auto-complete
  :ensure t
  :init
  (progn
    (ac-config-default)
    (global-auto-complete-mode t)
    ))

(evil-leader/set-leader "<SPC>")

(use-package magit
  :ensure t)

(evil-leader/set-key
  "gg" 'magit-status)

;; Theme(s)
(use-package seti-theme
  :ensure t)

;;
;; Settings
;;

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

; A better way of listing buffers
(defalias 'list-buffers 'ibuffer)

(evil-leader/set-key
  "e" 'revert-buffer
  "o" 'find-file
  "q" 'save-buffers-kill-terminal)

(evil-leader/set-key
  "w" 'save-buffer
  "d" 'kill-this-buffer
  "b" 'switch-to-buffer
  "l" 'next-buffer
  "h" 'previous-buffer)

;; General behavior
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t
      inhibit-splash-screen t
      ring-bell-function 'ignore)

(setq-default indent-tabs-mode nil)
(setq tab-width 2)

;; Don't litter my init file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;; Look & Feel
(set-default-font
 "-*-Ubuntu Mono-normal-normal-normal-*-18-*-*-*-m-0-iso10646-1")

(use-package nlinum-relative
  :ensure t
  :config
  (nlinum-relative-setup-evil)
  (setq nlinum-relative-redisplay-delay 0)
  (add-hook 'prog-mode-hook #'nlinum-relative-mode))

;; change mode-line color by evil state
(eval-when-compile (require 'cl))
(lexical-let ((default-color (cons (face-background 'mode-line)
                                   (face-foreground 'mode-line))))
             (add-hook 'post-command-hook
                       (lambda ()
                         (let ((color (cond ((minibufferp) default-color)
                                            ((evil-insert-state-p) '("#444488" . "#ffffff"))
                                            ((evil-emacs-state-p)  '("#e80000" . "#ffffff"))
                                            ((buffer-modified-p)   '("#006fa0" . "#ffffff"))
                                            (t default-color))))
                           (set-face-background 'mode-line (car color))
                           (set-face-foreground 'mode-line (cdr color))))))
