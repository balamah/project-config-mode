;;; project-config-mode.el --- Load per project configuration -*- lexical-binding: t; -*-

;; Author: Balamah
;; Version: 1.0
;; Keywords: tools, convenience

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see `http://www.gnu.org/licenses/'.

;;; Commentary:
;;; project-config-mode can be used as an entry point for some
;;; projects. For example, i want to launch symfony telegram bot,i don't
;;; want to create function for one project in my emacs config, it is
;;; better to have per-project config

;;;; Standard keybindings
;;;; C-c p f c --> project-config-file-create
;;;; C-c p f d --> project-config-directory-find-delete
;;;; C-c p f l --> project-config-find-file-load
;;;; C-c p f u --> project-config-file-unload
;;;; C-c p f o --> project-config-file-open

;;; Code:
(require 'project-config-mode-running-functions)

(defun project-get-root ()
  "Returns project root directory. Uses `projectile-project-root' if
`current-project' variable is not bound"
  (let* ((directory (if (bound-and-true-p current-project)
                       current-project
                     (projectile-project-root))))
    (if directory
        (file-name-as-directory directory)
      default-directory)))

(defun project-config-get-directory ()
  "Returns project configuration directory, which is `project-root/.emacs/'"
  (concat (project-get-root) ".emacs/"))

(defun project-config-file-get ()
  "Returns project configuration file, which is `project-root/.emacs/config.el'"
  (let* ((config-file (concat (project-config-get-directory) "config.el"))
		 (local-config-file (concat (project-config-get-directory) "config.local.el")))
	(if (file-exists-p local-config-file)
		local-config-file
	  config-file)))

(defun project-config-file-directory-get-path (file-directory)
  "Returns path of file-directory.
Example usage:
(project-config-file-directory-get-path `\"scripts/launcher\"')"
  (concat (project-config-get-directory) file-directory))

(defvar project-config-file-no-file-message
  "Project doesn't have .emacs/config.el, create it in project root"
  "`project-config-file-open' and `project-config-file-load' show the message when
project doesn't have .emacs/config.el")

(defvar project-config-file-keybinding-prefix "C-c p f"
  "Prefix for project-config-file-* keybindings")

(defvar project-config-directory-template nil
  "Template directory for project configuration, which is <package-path>/template-configuration/.
 The template should have similar structure to

.emacs
├── config.el
└── snippets
    └── major-mode
        ├── snippet-1
        └── snippet-2

snippets/ directory is similar to directories which are stored in `yas/snippet-dirs' variable")

(defun project-config-file-create ()
  "Copy directory from `project-config-directory-template' to project root"
  (interactive)
  (if (bound-and-true-p project-config-directory-template)
	  (progn
		(copy-directory
		 project-config-directory-template (project-config-get-directory) nil nil t)
		(message "%s has been created" (project-config-file-get)))
	(error "Assign value to project-config-directory-template")))

(defun project-config-file-open ()
  "Open project-config-file which is obtained from `project-config-file-get'"
  (interactive)
  (let ((project-config-file (project-config-file-get)))
	(if (file-exists-p project-config-file)
		(find-file project-config-file)
	  (error project-config-file-no-file-message))))

(defun project-config-directory-delete (project-config-directory)
  "Delete project configuration"
  (when (y-or-n-p "Are you sure you want to delete project config?")
	(delete-directory project-config-directory "recursive")))

(defun project-config-directory-find-delete ()
  "Find project config directory and delete"
  (interactive)
  (let ((project-config-directory (project-config-get-directory)))
	(if (file-directory-p project-config-directory)
		(project-config-directory-delete project-config-directory)
	  (message project-config-file-no-file-message))))

(require 'projectile)

(defun project-config-file-load (project-config-file)
  "Load project configuration file"
  (message "Loading project config from %s" project-config-file)
  (load-file project-config-file))

(defun project-config-file-find-load ()
  "Find project config file and load"
  (interactive)
  (let ((project-config-file (project-config-file-get)))
	(if (file-exists-p project-config-file)
		(project-config-file-load project-config-file)
	  (error project-config-file-no-file-message))))

(defun project-config-file-unload ()
  "Reset `current-project' variable. This allows to load other project
configurations.

To reset completely project configuration, it is recommended to
restart emacs"
  (interactive)
  (if (bound-and-true-p current-project)
	  (let ((project current-project))
		(makunbound 'current-project)
		(message "Successfully unloaded project configuration of %s"
				 (directory-file-name project)))
	(error "There is no loaded project configuration")))

(define-minor-mode project-config-mode
  "Toggle `project-config-mode' functional on or off"
  :global t
  :interactive t
  :init-value t
  :keymap
  (list
   (cons (pkbd project-config-file-keybinding-prefix "c") #'project-config-file-create)
   (cons (pkbd project-config-file-keybinding-prefix "o") #'project-config-file-open)
   (cons (pkbd project-config-file-keybinding-prefix "d") #'project-config-directory-find-delete)
   (cons (pkbd project-config-file-keybinding-prefix "l") #'project-config-file-find-load)
   (cons (pkbd project-config-file-keybinding-prefix "u") #'project-config-file-unload)
   ))

(provide 'project-config-mode)
;;; project-config-mode.el ends here
