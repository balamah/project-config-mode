;;; project-config-mode-running-functions.el
;;; -*- lexical-binding: t; -*-

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

;; Code:
(defun run-prepare ()
  "Save the buffer and switch to split window below"
  (when buffer-file-name (save-buffer))
  (split-window-below)
  (unless no-redisplay (redisplay))
  (other-window 1))

(defun run (binary-name &optional is-only-file-name)
  "Run current file using BINARY-NAME in vterm"
  (run-prepare)
  (let* ((filename (if is-only-file-name
					   (get-only-file-name buffer-file-name)
					 buffer-file-name))
		 (formatted-filename (replace-regexp-in-string " " "\\\\ " filename)))
	(vterm-run (format "%s %s" binary-name formatted-filename))))

(defmacro defrun (function-name binary-name &optional is-only-file-name)
  "Create interactive function with (run).
WARNING: this macro creates function with prefix `run-',
for example:
java --> run-java
php  --> run-php
"
  (declare (indent defun))
  `(defun ,(intern (concat "run-" (symbol-name function-name))) ()
     (interactive)
     (run ,binary-name ,is-only-file-name)))

(defmacro defrunc (function-name &rest body)
  "Create interactive function with (run-prepare).
WARNING: this macro creates function with prefix `run-',
for example:
java --> run-java
php  --> run-php
"
  (declare (indent defun))
  `(defun ,(intern (concat "run-" (symbol-name function-name))) ()
     (interactive)
	 (run-prepare)
	 ,@body))

(provide 'project-config-mode-running-functions)
;; project-config-mode-running-functions.el ends here
