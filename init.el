;; Hide startup message
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)

;; Look & Feel
(linum-mode t) ;; line numbers on

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
  (evil-mode 1))

(setq evil-overriding-maps nil)
(setq evil-intercept-maps nil)

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

(use-package evil-leader
  :ensure t
  :config
  (global-evil-leader-mode))

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
  "w" 'save-buffer
  "d" 'kill-this-buffer
  "q" 'save-buffers-kill-terminal)

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
