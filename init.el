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

;;
;; Settings
;;
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

(defalias 'list-buffers 'ibuffer)

(evil-leader/set-key
  "e" 'find-file
  "q" 'save-buffers-kill-terminal)

(evil-leader/set-key
  "w" 'save-buffer
  "d" 'kill-this-buffer
  "b" 'switch-to-buffer
  "l" 'next-buffer
  "h" 'previous-buffer)

;; Auto added
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(custom-enabled-themes (quote (deeper-blue)))
 '(package-selected-packages
   (quote
    (evil-leader auto-complete org-bullets which-key try use-package))))

;; Auto added
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; General behavior
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)

;; Look & Feel
(set-default-font
 "-*-Ubuntu Mono-normal-normal-normal-*-18-*-*-*-m-0-iso10646-1")

(linum-mode t) ;; line numbers on

