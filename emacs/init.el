;; -*- lexical-binding: t -*-
;;; init.el --- Summary
;; This is my Emacs initialization file which configures Emacs to my liking.

;;; Commentary:
;; This file sets up essential packages, keybindings, and custom functions
;; to enhance productivity and usability of Emacs.

;;; Code:

(require 'use-package)

;; Increase the garbage collection threshold during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Reset the garbage collection threshold after startup
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold 800000)))

;;; Appearance Configuration ;;;
;;----------------------------;;

;; Load theme
(use-package catppuccin-theme
  :ensure t
  :init
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm))

;; Remove tool bar
(tool-bar-mode -1)

;; Menu bar mode
(menu-bar-mode t)

;; Enable line numbers
(global-display-line-numbers-mode 1)
(add-hook 'treemacs-mode-hook (lambda() (display-line-numbers-mode -1)))

;; Configure mode line
(set-face-attribute 'mode-line-active nil :inherit 'mode-line)

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

;;; General Configuration ;;;
;;----------------------------;;

;; Clipboard Configuration
(setq select-enable-clipboard t
      select-enable-primary t)

;; Disable backup files
(setq make-backup-files nil)

;; Disable tooltip mode
(tooltip-mode -1)

;; Disable auto save
(setq auto-save-default nil)

;; Auto revert mode
(global-auto-revert-mode t)

;; Disable dialog boxes
(setq use-dialog-box nil)

;; Meta key pound sign
(global-set-key (kbd "M-3") (lambda () (interactive) (insert "#")))

;; Set modifier key
(setq mac-option-modifier 'meta)
(setq mac-right-option-modifier nil)
(setq mac-command-modifier 'super)

;; Copy
(global-set-key (kbd "s-c") 'clipboard-kill-ring-save)

;; Paste
(global-set-key (kbd "s-v") 'clipboard-yank)

;; Cut
(global-set-key (kbd "s-x") 'kill-region)

;; Undo
(global-set-key (kbd "s-z") 'undo)

;; Redo
(global-set-key (kbd "s-y") 'undo-redo)

;; Force Quit
(global-set-key (kbd "s-q") 'kill-emacs)

;; Select All
(global-set-key (kbd "s-a") 'mark-whole-buffer)

;; Paste replaces selected region
(delete-selection-mode 1)

;; Path configuration
(let ((paths '("/Users/lukecollins/.nix-profile/bin"
               "/etc/profiles/per-user/lukecollins/bin"
               "/run/current-system/sw/bin"
               "/nix/var/nix/profiles/default/bin"
               "/usr/local/bin"
               "/usr/bin"
               "/usr/sbin"
               "/bin"
               "/sbin")))
  (setenv "PATH" (string-join paths ":"))
  (setq exec-path (append paths exec-path)))

;; Introduce backtab functionality for unindent
(defun my-unindent-up-to-previous ()
  "Unindent the current line to match the nearest lesser indentation level of the lines above."
  (interactive)
  (let ((current-indentation (current-indentation))
        (target-indentation 0)
        (searching t))
    (save-excursion
      (while (and searching (not (bobp)))
        (forward-line -1)
        (let ((previous-line-indentation (current-indentation)))
          (when (< previous-line-indentation current-indentation)
            (setq target-indentation previous-line-indentation)
            (setq searching nil)))))
    (when (and (not searching) (> current-indentation target-indentation))
      (indent-line-to target-indentation))))

;; Bind the function to Backtab (shift + tab)
(define-key global-map [backtab] 'my-unindent-up-to-previous)

;;; App Configuration ;;;
;;----------------------------;;

;; Dashboard configuration
(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*"))
        dashboard-banner-logo-title "Allied Mastercomputer"
        dashboard-startup-banner "~/Pictures/gnu_color.png"
        dashboard-center-content t
        dashboard-display-icons-p t
        dashboard-icon-type 'nerd-icons
        dashboard-set-file-icons t
        dashboard-items '((recents  . 5)
                          (projects . 5)
                          (agenda   . 5))
        dashboard-footer-messages '("I have no mouth, and I must scream"))
  :config
  (dashboard-setup-startup-hook)
  (setq org-agenda-files '("~/Documents/owncloud-org/")))

(use-package nerd-icons
  :ensure t
  :custom (nerd-icons-font-family "Symbols Nerd Font Mono"))

;; Projectile configuration
(use-package projectile
  :ensure t
  :defer t
  :config
  (projectile-mode +1))

;; Direnv configuration
(use-package direnv
  :ensure t
  :defer t
  :config
  (direnv-mode))

;; Helm configuration
(use-package helm
  :ensure t
  :defer t
  :init
  (setq helm-M-x-fuzzy-match t
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t
        helm-locate-fuzzy-match t
        helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-completion-in-region-fuzzy-match t)
  :bind (("M-x" . helm-M-x))
  :config
  (helm-mode 1))

;; Configure company
(use-package company
  :ensure t
  :defer t
  :config
  (global-company-mode t)
  (setq-default company-idle-delay 0.05
                company-require-match nil
                company-minimum-prefix-length 0
                company-frontends '(company-preview-frontend)))

;; Configure codeium
(use-package codeium
  :ensure t
  :defer t
  :init
  (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
  :config
  (setq use-dialog-box nil
        codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion))))
        codeium-api-enabled
        (lambda (api) (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
  (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
  (defun my-codeium/document/text ()
    (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
  (defun my-codeium/document/cursor_offset ()
    (codeium-utf8-byte-length
     (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))
  (setq codeium/document/text 'my-codeium/document/text)
  (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset))

;; Treemacs configuration
(use-package treemacs
  :ensure t
  :defer t
  :bind (("C-x t" . treemacs)))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(defun my-treemacs-add-project-with-name ()
  "Add a project to the Treemacs workspace with a custom name."
  (interactive)
  (let ((path (read-directory-name "Project root: "))
        (name (read-string "Project name: ")))
    (when (and (file-directory-p path) (file-exists-p path))
      (treemacs-do-add-project-to-workspace path name))))

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map (kbd "A a") #'my-treemacs-add-project-with-name))

;; Enable grip-mode
(use-package grip-mode
  :ensure t
  :defer t)

;; Vterm configuration
(use-package vterm
  :ensure t
  :defer t
  :config
  (setq vterm-max-scrollback 5000))

;; Configure elfeed
(use-package elfeed
  :ensure t
  :defer t
  :config
  (global-set-key (kbd "M-A") 'elfeed-update)
  (setq elfeed-search-title-max-width 180)
  (add-hook 'elfeed-search-mode-hook
            (lambda ()
              (setq-local elfeed-search-title-max-width 180)
              (elfeed-search-update :force))))

(use-package elfeed-protocol
  :ensure t
  :after elfeed
  :config
  (elfeed-protocol-enable)
  (setq elfeed-protocol-feeds '(("ttrss+http://rearrange5473@192.168.0.3:8280" :password "32Y3TzPtHHKbUc")))
  :custom
  (setq elfeed-protocol-ttrss-maxsize 200
        elfeed-protocol-ttrss-fetch-category-as-tag t))

;;; Language Configuration ;;;
;;----------------------------;;

;; Custom function to enable lsp-mode only for Bash scripts and not for Zsh
(defun enable-lsp-in-sh-mode ()
  "Enable lsp-mode in shell mode only for Bash scripts."
  (when (and (eq major-mode 'sh-mode)
             (not (string-suffix-p ".zsh" (buffer-file-name))))
    (lsp-deferred)))

;; Modes for various file types
(use-package terraform-mode
  :ensure t
  :defer t
  :mode "\\.tf\\'")

(use-package dockerfile-mode
  :ensure t
  :defer t
  :mode ("Dockerfile\\'" . dockerfile-mode)
        ("\\.dockerfile\\'" . dockerfile-mode))

(use-package nix-mode
  :ensure t
  :defer t
  :mode "\\.nix\\'")

(use-package rust-mode
  :ensure t
  :defer t
  :mode "\\.rs\\'")

(use-package markdown-mode
  :ensure t
  :defer t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package grip-mode
  :ensure t
  :hook (markdown-mode . grip-mode))

(use-package yaml-mode
  :ensure t
  :defer t
  :mode "\\.yml\\'" "\\.yaml\\'")

;; Enable Flycheck
(use-package flycheck
  :ensure t
  :defer t
  :init (global-flycheck-mode))

;; LSP Mode
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((rust-mode . lsp-deferred)
         (nix-mode . lsp-deferred)
         (sh-mode . enable-lsp-in-sh-mode)
         (dockerfile-mode . lsp-deferred)
         (terraform-mode . lsp-deferred)
         (yaml-mode . lsp-deferred))
  :config
  (setq lsp-rust-analyzer-cargo-watch-command "clippy"
        lsp-rust-analyzer-server-display-inlay-hints t
        lsp-completion-enable nil))

;; LSP UI
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode))

;; Pyright
(use-package lsp-pyright
  :ensure t
  :defer t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp-deferred))))

(provide 'init)
;;; init.el ends here
