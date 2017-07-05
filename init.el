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

  ;; do not override/intercept evil-state
  (setq evil-overriding-maps nil)
  (setq evil-intercept-maps nil)

  ;; use vim search behavior (enables use of `cgn` to replace search-object & jump to next)
  (evil-select-search-module 'evil-search-module 'evil-search)

  (use-package evil-leader
    :ensure t
    :config
    (global-evil-leader-mode)
    (evil-leader/set-leader "<SPC>"))

  (use-package evil-surround
    :ensure t
    :config
    (global-evil-surround-mode))

  (use-package neotree
    :ensure t
    :config
    (evil-leader/set-key
    "nn" 'neotree-find
    "nc" 'neotree-hide)

    (setq projectile-switch-project-action 'neotree-projectile-action)

    (add-hook 'neotree-mode-hook
              (lambda ()
                (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
                (define-key evil-normal-state-local-map (kbd "I") 'neotree-hidden-file-toggle)
                (define-key evil-normal-state-local-map (kbd "a") 'neotree-stretch-toggle)
                (define-key evil-normal-state-local-map (kbd "R") 'neotree-refresh)
                (define-key evil-normal-state-local-map (kbd "m") 'neotree-rename-node)
                (define-key evil-normal-state-local-map (kbd "c") 'neotree-create-node)
                (define-key evil-normal-state-local-map (kbd "d") 'neotree-delete-node)
                (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))
  )

  (use-package evil-rails
    :ensure t
    :config
    (use-package projectile-rails
      :ensure t
      :config (projectile-rails-global-mode)
    )
    (evil-leader/set-key
      "aa" 'projectile-toggle-between-implementation-and-test
      "av" '(lambda ()
              (projectile-toggle-between-implementation-and-test)
              (interactive)
              (evil-window-vsplit)
              (windmove-right))
      "as" '(lambda ()
              (projectile-toggle-between-implementation-and-test)
              (interactive)
              (evil-window-split)
              (windmove-down)))
  )
)

;; Auto start emacs-keybound buffers in evil-motion state instead
;(setq evil-motion-state-modes (append evil-emacs-state-modes evil-motion-state-modes))
;(setq evil-emacs-state-modes nil)
(add-to-list 'evil-emacs-state-modes 'git-rebase-mode)

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

(use-package magit
  :ensure t
  :config
  (evil-leader/set-key
    "gg" 'magit-status)
)

(use-package diff-hl
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'diff-hl-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (define-key evil-normal-state-map (kbd "]c") 'diff-hl-next-hunk)
  (define-key evil-normal-state-map (kbd "[c") 'diff-hl-previous-hunk)
)

(use-package projectile
  :ensure t
  :defer t
  :config
  (projectile-global-mode)
)

(use-package tabbar
  :ensure t
  :config (tabbar-mode t)
)

(use-package telephone-line
  :ensure t
  :config
  (setq telephone-line-primary-left-separator 'telephone-line-gradient
        telephone-line-secondary-left-separator 'telephone-line-nil
        telephone-line-primary-right-separator 'telephone-line-gradient
        telephone-line-secondary-right-separator 'telephone-line-nil
        telephone-line-evil-use-short-tag t)
  (telephone-line-evil-config)
)

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

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Don't litter my init file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;; Look & Feel
(custom-set-variables '(initial-frame-alist (quote ((fullscreen . maximized))))) ;; start maximized

(when window-system (global-hl-line-mode)) ;; highlight current line

(set-default-font
 "-*-Ubuntu Mono-normal-normal-normal-*-18-*-*-*-m-0-iso10646-1")

(use-package nlinum-relative
  :ensure t
  :config
  (nlinum-relative-setup-evil)
  (setq nlinum-relative-redisplay-delay 0)
  (add-hook 'prog-mode-hook #'nlinum-relative-mode))

;; display full file path in the frame title
(setq frame-title-format
      '(:eval
        (if (buffer-file-name)
            (abbreviate-file-name (buffer-file-name))
          "%b")))
