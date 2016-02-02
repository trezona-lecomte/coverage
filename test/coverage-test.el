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
                          '(/foo/bar\.rb . ,bar-results)
                          '(/baz/qux/quux\.rb . ,quux-results)))))

(ert-deftest test-coverage-get-json-from-file ()
  (should (equal (coverage-get-json-from-file "./example.json")
                 expected-json)))

(ert-deftest test-coverage-get-results-for-file-bar ()
  (should (equal (coverage-get-results-for-file "/foo/bar.rb" "./example.json")
                 bar-results)))

(ert-deftest test-coverage-get-results-for-file-quux ()
  (should (equal (coverage-get-results-for-file "/baz/qux/quux.rb" "./example.json")
                 quux-results)))

(provide 'coverage-test)

;;; coverage-test.el ends here
