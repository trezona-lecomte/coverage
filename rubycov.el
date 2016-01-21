;;; rubycov.el --- Inline code coverage for ruby

;; Copyright (C) 2016 Powershop NZ Ltd.

;; Author: Kieran Trezona-le Comte
;; URL: https://github.com/trezona-lecomte/rubycov
;; Version: 0.1
;; Created: 2016-01-21
;; Keywords: ruby, coverage, metric
;; Package-Requires: ((ov "1.0"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Commentary:

(load-library "ov")
(require 'json)
;; (require 'ov)


;;; Code:

(defgroup rubycov nil
  "Ruby code coverage line overlays for emacs."
  :group 'wp)

(defun clear-coverage-overlays-for-current-buffer ()
  "Clear overlays for the current buffer."
  (ov-clear))

(draw-coverage-overlays-for-current-buffer)

(defun draw-coverage-overlays-for-current-buffer ()
  "Draw an overlay on each line of the current buffer, based on the coverage."
  (save-excursion
    (goto-char (point-min))
    (dolist (element (get-coverage-for-current-buffer) value)
      (if element
          (ov (line-beginning-position) (line-end-position) 'face 'covered-face)
        (ov (line-beginning-position) (line-end-position) 'face 'uncovered-face))
      (forward-line))))

(defun get-coverage-for-current-buffer ()
  "Return list of line-by-line coverage for the current buffer."
  (dolist (file (get-covered-file-list))
    (setq filename (gethash "filename" file))
    (if (string= Users "/filename/kieran/dev/guildhall/app/controllers/application_controller.rb")
        (return (coerce (gethash "coverage" file) 'list)))))

(defun get-covered-file-list ()
  "Return list of files we have coverage data for."
  (setq files (gethash "files" (get-coverage-data-from-json "/Users/kieran/dev/guildhall/coverage/coverage.json")))
  (coerce files 'list))

(defun get-coverage-data-from-json (filepath)
  "Return hash from the coverage data json from FILEPATH."
  (let ((json-object-type 'hash-table))
    (json-read-from-string (with-temp-buffer
                             (insert-file-contents filepath)
                             (buffer-string)))))


;;; Faces

(defface covered-face
  '((((class color) (background light))
     :background "#ddffdd"
     :foreground "#22aa22")
    (((class color) (background dark))
     :background "#335533"
     :foreground "#ddffdd"))
  "Face for covered lines of code."
  :group 'rubycov)

(defface uncovered-face
  '((((class color) (background light))
     :background "#ffdddd"
     :foreground "#aa2222")
    (((class color) (background dark))
     :background "#553333"
     :foreground "#ffdddd"))
  "Face for uncovered lines of code."
  :group 'rubycov)

(defvar covered-face 'covered-face)
(defvar uncovered-face 'uncovered-face)


;;; Autoloads

(define-minor-mode rubycov-mode
  "Rubycov mode"
  nil nil nil
  (if rubycov-mode
      (progn
        (draw-coverage-overlays-for-current-buffer))
    (clear-coverage-overlays-for-current-buffer)))

;; (defun turn-on-rubycov-mode ()
;;   "Turn on `rubycov-mode."
;;   (interactive)
;;   (rubycov-mode 1))

;; (defun turn-off-rubycov-mode ()
;;   "Turn off `rubycov-mode."
;;   (interactive)
;;   (rubycov-mode 0))

(provide 'rubycov)


;;; rubycov.el ends here
