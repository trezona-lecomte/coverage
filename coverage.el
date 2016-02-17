;;; coverage.el --- Code coverage line highlighting

;; Copyright (C) 2016 Powershop NZ Ltd.

;; Author: Kieran Trezona-le Comte <trezona.lecomte@gmail.com>
;; Version: 0.1
;; Package-Requires: ((ov "1.0"))
;; Created: 2016-01-21
;; Keywords: coverage metrics simplecov ruby rspec
;; URL: https://github.com/trezona-lecomte/coverage

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

(defgroup coverage nil
  "Code coverage line highlighting."
  :group 'programming)

(defvar coverage-resultset-filename ".resultset.json")

(defcustom coverage-dir nil
  "The coverage directory for `coverage'.

For example: \"~/dir/to/my/project/coverage/\".

If set, look in this directory for a .resultset.json file to
obtain coverage results.

If nil, look for a /coverage directory immediately under the Git
root directory."
  :type '(choice (const :tag "Default (vc-git-root/coverage)" nil)
                 (string :tag "Path to coverage diretory"))
  :group 'coverage)

(defun coverage-result-path-for-file (filename)
  "Return the fully-qualified filepath of the resultset for FILENAME."
  (concat (coverage-dir-for-file filename) coverage-resultset-filename))

(defun coverage-dir-for-file (filename)
  "Guess the coverage directory of the given FILENAME.

Use `coverage-dir' if set, or fall back to /coverage under Git
root."
  (or coverage-dir
      (concat (vc-git-root filename) "coverage/")))

(defun coverage-clear-highlighting (buffer)
  "Clear all coverage highlighting for BUFFER."
  (set-buffer buffer)
  (ov-clear))

(defun coverage-draw-highlighting (results buffer)
  "Draw line highlighting for RESULTS in BUFFER."
  (set-buffer buffer)
  (save-excursion
    (goto-char (point-min))
    (dolist (element results)
      (cond ((eq element nil)
             (ov-clear (line-beginning-position) (line-end-position)))
            ((= element 0)
             (ov (line-beginning-position) (line-end-position) 'face 'coverage-uncovered-face))
            ((> element 0)
             (ov (line-beginning-position) (line-end-position) 'face 'coverage-covered-face)))
      (forward-line))))

(defun coverage-get-results-for-current-buffer ()
  "Return a list of coverage results for the currently buffer."
  (coverage-get-results-for-file (buffer-file-name)
                                 (coverage-result-path-for-file buffer-file-name)))

(defun coverage-get-results-for-file (target-path result-path)
  "Return coverage for the file at TARGET-PATH from RESULT-PATH."
  (coerce (cdr
           (assoc-string target-path
                         (assoc 'coverage
                                (assoc 'RSpec
                                       (coverage-get-json-from-file result-path)))))
          'list))

(defun coverage-get-json-from-file (filepath)
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
  :group 'coverage)

(defface coverage-uncovered-face
  '((((class color) (background light))
     :background "#ffdddd")
    (((class color) (background dark))
     :background "#553333"))
  "Face for uncovered lines of code."
  :group 'coverage)

;;; Mode definition

;;;###autoload
(define-minor-mode coverage
  "Coverage mode"
  :lighter " COV"
  (if coverage
      (coverage-draw-highlighting (coverage-get-results-for-current-buffer) (current-buffer))
    (coverage-clear-highlighting (current-buffer))))

(provide 'coverage)

;;; coverage.el ends here
