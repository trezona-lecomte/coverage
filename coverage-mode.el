;;; coverage-mode.el --- Code coverage line highlighting

;; Copyright (C) 2016 Powershop NZ Ltd.

;; Author: Kieran Trezona-le Comte <trezona.lecomte@gmail.com>
;; Version: 0.1
;; Package-Requires: ((ov "1.0"))
;; Created: 2016-01-21
;; Keywords: coverage metrics simplecov ruby rspec
;; URL: https://github.com/trezona-lecomte/coverage-mode

;; This file is NOT part of GNU Emacs.

;;; License:

;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:
;; This package provides a minor mode to highlight code coverage in
;; source code files.
;;
;; At present it only knows how to parse coverage data in the format
;; provided by the Simplecov gem (specifically, the RSpec results in
;; the .resultset.json file it outputs).

(require 'json)
(require 'ov)
(autoload 'vc-git-root "vc-git")

;;; Code:

(defgroup coverage-mode nil
  "Code coverage line highlighting for Emacs.")

(defvar coverage-resultset-filename ".resultset.json")

(defcustom coverage-dir nil
  "The coverage directory for `coverage-mode'.

For example: \"~/dir/to/my/project/coverage/\".

If set, look in this directory for a .resultset.json file to
obtain coverage results.

If nil, look for a /coverage directory immediately under the Git
root directory."
  :type '(choice (const :tag "Default (vc-git-root/coverage)" nil)
                 (string :tag "Path to coverage diretory"))
  :group 'coverage-mode)

(defun coverage-dir-for-file (filepath)
  "Guess the coverage directory of the given FILEPATH.

Use `coverage-dir' if set, or fall back to /coverage under Git root."
  (if coverage-dir
      (coverage-dir)
    (concat (vc-git-root filepath) "coverage/")))

(defun coverage-clear-highlighting-for-current-buffer ()
  "Clear all coverage highlighting for the current buffer."
  (ov-clear))

(defun coverage-draw-highlighting-for-current-buffer ()
  "Highlight the lines of the current buffer, based on code coverage."
  (save-excursion
    (goto-char (point-min))
    (dolist (element (coverage-get-results-for-current-buffer))
      (cond ((eq element nil)
             (ov-clear (line-beginning-position) (line-end-position)))
            ((= element 0)
             (ov (line-beginning-position) (line-end-position) 'face 'coverage-uncovered-face))
            ((> element 0)
             (ov (line-beginning-position) (line-end-position) 'face 'coverage-covered-face)))
      (forward-line))))

(defun coverage-get-results-for-current-buffer ()
  "Return a list of coverage for the current buffer."
  (coverage-get-results-for-file buffer-file-name
                                 (concat (coverage-dir-for-file buffer-file-name)
                                         coverage-resultset-filename)))

(defun coverage-get-results-for-file (target-path result-path)
  "Return coverage for the file at TARGET-PATH from resultset at RESULT-PATH."
  (coerce (cdr
           (assoc-string target-path
                         (assoc 'coverage
                                (assoc 'RSpec
                                       (coverage-get-results-from-json result-path)))))
          'list))

(defun coverage-get-results-from-json (filepath)
  "Return alist of the json resultset at FILEPATH."
  (json-read-from-string (with-temp-buffer
                           (insert-file-contents filepath)
                           (buffer-string))))

;;; Faces

(defface coverage-covered-face
  '((((class color) (background light))
     :background "#ddffdd")
    (((class color) (background dark))
     :background "#335533"))
  "Face for covered lines of code."
  :group 'coverage-mode)

(defface coverage-uncovered-face
  '((((class color) (background light))
     :background "#ffdddd")
    (((class color) (background dark))
     :background "#553333"))
  "Face for uncovered lines of code."
  :group 'coverage-mode)

(defvar coverage-covered-face 'coverage-covered-face)
(defvar coverage-uncovered-face 'coverageuncovered-face)

;;; Mode definition

(define-minor-mode coverage-mode
  "Coverage mode"
  nil nil nil
  (if coverage-mode
      (progn
        (coverage-draw-highlighting-for-current-buffer))
    (coverage-clear-highlighting-for-current-buffer)))

(provide 'coverage-mode)

;;; coverage-mode.el ends here
