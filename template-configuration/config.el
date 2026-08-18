;; Configuration file for `project-config-file' for emacs.
;; The package project-config-mode (https://github.com/balamah/project-config-mode)
;; makes it possible.
;; To load the configuration file, press `C-c p f l'.

(defvar current-project (project-get-root)
  "Current project directory")

;; run project
(defrunc project
  (message "Ran entry point function"))

(global-set-key (kbd "S-<f10>") 'run-project)

;; add snippets
(let ((snippet-directory (project-config-file-directory-get-path "snippets")))
  (when (file-exists-p snippet-directory)
	(add-to-list 'yas-snippet-dirs 'snippet-directory)
	(yas-load-directory snippet-directory)))
