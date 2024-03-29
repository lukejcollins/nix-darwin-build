;; -*- lexical-binding: t -*-;;
;;; init.el --- Summary
;; This is my Emacs initialization file which configures Emacs to my liking.

;;; Commentary:
;; This file sets up essential packages, keybindings, and custom functions
;; to enhance productivity and usability of Emacs.

;;; Code:

(require 'use-package)


;;; Appearance Configuration ;;;
;;----------------------------;;

;; Load theme
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)

;;Remove tool bar
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

;; Paste replaces selected regio
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

  ;; Set the environment variable PATH
  (setenv "PATH" (string-join paths ":"))

  ;; Set exec-path in Emacs
  (setq exec-path (append paths exec-path)))


;;; App Configuration ;;;
;;----------------------------;;

;; Dashboard configuration
(use-package dashboard
  :ensure t
  :config
  ;; Set the initial buffer choice to Dashboard
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

  ;; Set up the Dashboard
  (dashboard-setup-startup-hook)

  ;; Dashboard appearance settings
  (setq dashboard-banner-logo-title "Allied Mastercomputer")
  (setq dashboard-startup-banner "~/Pictures/gnu_color.png")  ; Set the banner image
  (setq dashboard-center-content t)  ; Center the content
  (setq dashboard-display-icons-p t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-set-file-icons t)

  ;; Dashboard items to display
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (agenda   . 5)))  ; Added agenda

  ;; Modify heading icons for certain dashboard items
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))

;; Set Org agenda files
  (setq org-agenda-files '("~/Documents/owncloud-org/"))

  ;; Set the footer message
  (setq dashboard-footer-messages '("I have no mouth, and I must scream")))

(use-package nerd-icons
  :ensure t
  :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

;; Projectile configuration
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1))

;; Direnv configuration
(use-package direnv
  :ensure t
  :config
  (direnv-mode))

;; Helm configuration
(use-package helm
  :ensure t
  :config
  (helm-mode 1)

  ;; Enable fuzzy matching
  (setq helm-M-x-fuzzy-match t) ;; Fuzzy matching for M-x
  (setq helm-buffers-fuzzy-matching t) ;; Fuzzy matching for buffer-related tasks
  (setq helm-recentf-fuzzy-match t) ;; Fuzzy matching for recent files
  (setq helm-locate-fuzzy-match t) ;; Fuzzy matching for locate command
  (setq helm-semantic-fuzzy-match t) ;; Fuzzy matching for semantic sources
  (setq helm-imenu-fuzzy-match t) ;; Fuzzy matching for imenu
  (setq helm-completion-in-region-fuzzy-match t) ;; Fuzzy matching for in-region completion

  :bind (("M-x" . helm-M-x)
         ;; You can add more keybindings here if needed
        ))

;; Configure company
(use-package company
    :ensure t
    :defer 0.1
    :config
    (global-company-mode t)
    (setq-default
        company-idle-delay 0.05
        company-require-match nil
        company-minimum-prefix-length 0

        ;; get only preview
        company-frontends '(company-preview-frontend)
        ;; also get a drop down
        ;; company-frontends '(company-pseudo-tooltip-frontend company-preview-frontend)
        ))

;; Configure codeium
(use-package codeium
    :ensure t
    :init
    (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
    :config
    (setq use-dialog-box nil) ;; do not use popup boxes
    (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
    (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
    (setq codeium-api-enabled
        (lambda (api)
            (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
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
    ;; Ensure the path is valid
    (when (and (file-directory-p path)
               (file-exists-p path))
      ;; Add project to workspace
      (treemacs-do-add-project-to-workspace path name))))

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map (kbd "A a") #'my-treemacs-add-project-with-name))


;; Enable grip-mode
(use-package grip-mode
  :ensure t)

;; Vterm configuration
(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 5000))



;; Configure elfeed
(use-package elfeed
  :config
  (global-set-key (kbd "M-A") 'elfeed-update)
  (setq elfeed-search-title-max-width 180)
  (add-hook 'elfeed-search-mode-hook (lambda ()
                                       (setq-local elfeed-search-title-max-width 180)
                                       (elfeed-search-update :force))))

(use-package elfeed-protocol
  :ensure t
  :config
  (elfeed-protocol-enable)
  (setq elfeed-protocol-feeds '(("ttrss+http://rearrange5473@192.168.0.3:8280"
                                 :password "32Y3TzPtHHKbUc")))
  :custom
  (setq elfeed-protocol-ttrss-maxsize 200) ;; Bigger than 200 is invalid
  (setq elfeed-protocol-ttrss-fetch-category-as-tag t))

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
  :mode ("\\.tf\\'" . terraform-mode))
(use-package dockerfile-mode
  :ensure t
  :mode ("Dockerfile\\'" . dockerfile-mode)
        ("\\.dockerfile\\'" . dockerfile-mode))
(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")
(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
(use-package grip-mode
  :ensure t
  :hook ((markdown-mode . grip-mode)))

;; Enable Flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; LSP Mode
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((python-mode . lsp-deferred)
         (rust-mode . lsp-deferred)
         (nix-mode . lsp-deferred)
	 (sh-mode . enable-lsp-in-sh-mode)
	 (dockerfile-mode . lsp-deferred)
	 (terraform-mode . lsp-deferred))
  :config
    (setq lsp-rust-analyzer-cargo-watch-command "clippy")
    (setq lsp-rust-analyzer-server-display-inlay-hints t)
    (setq lsp-completion-enable nil)
    (setq lsp-diagnostic-package :none))

;; LSP UI
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode))

(provide 'init)
;;; init.el ends here
