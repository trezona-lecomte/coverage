;;; Package -- summary
;;; Commentary:
;;; Code:
(require 'ert)
(require 'coverage)

(defvar bar-results [1 0 nil])
(defvar quux-results  [nil 1 nil nil 0 0 16])

(defvar expected-json `((RSpec
                         (timestamp . 1453405229)
                         (coverage
                          (/baz/qux/quux\.rb . ,quux-results)
                          (/foo/bar\.rb . ,bar-results)))))

(ert-deftest test-coverage-get-json-from-file ()
  (should (equal (coverage-get-json-from-file "./example.json")
                 expected-json)))

(ert-deftest test-coverage-get-results-for-file-bar ()
  (should (equal (coverage-get-results-for-file "/foo/bar.rb" "./example.json")
                 (coerce bar-results 'list))))

(ert-deftest test-coverage-get-results-for-file-quux ()
  (should (equal (coverage-get-results-for-file "/baz/qux/quux.rb" "./example.json")
                 (coerce quux-results 'list))))

(ert-deftest test-coverage-get-resultset-filepath ()
  (should (string= (coverage-get-resultset-filepath)
                   "~/dev/coverage/coverage/.resultset.json")))

(provide 'coverage-test)

;;; coverage-test.el ends here
