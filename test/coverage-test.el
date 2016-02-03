;;; Package -- summary
;;; Commentary:
;;; Code:
(require 'ert)
(require 'ert-expectations)
(require 'coverage)

(defvar bar-results [1 0 nil])
(defvar quux-results  [nil 1 nil nil 0 0 16])

(defvar example-json `((RSpec
                        (timestamp . 1453405229)
                        (coverage
                         (/baz/qux/quux\.rb . ,quux-results)
                         (/foo/bar\.rb . ,bar-results)))))

(expectations
  (desc "get json from a resultset file")
  (expect example-json
    (coverage-get-json-from-file "./example.json"))

  (desc "get list of results for a file in the resultset")
  (expect (coerce bar-results 'list)
    (coverage-get-results-for-file "/foo/bar.rb" "./example.json"))

  (desc "get the default result path for a file")
  (expect "~/dev/coverage/coverage/.resultset.json"
    (coverage-result-path-for-file "~/dev/coverage/test/.example.json"))

  (desc "get coverage dir for a file from the git root")
  (expect "~/dev/coverage/coverage/"
    (coverage-dir-for-file "~/dev/coverage/test/.example.json"))

  ;;TODO:
  ;; (desc "get coverage dir for a file with customized coverage-dir")
  ;; (expect "~/dev/coverage/coverage/"
  ;;   (coverage-dir-for-file "~/dev/coverage/test/.example.json"))
  )

(ert-deftest test-coverage-get-results-for-file-bar ()
  (should (equal (coverage-get-results-for-file "/foo/bar.rb" "./example.json")
                 (coerce bar-results 'list))))

(ert-deftest test-coverage-get-results-for-file-quux ()
  (should (equal (coverage-get-results-for-file "/baz/qux/quux.rb" "./example.json")
                 (coerce quux-results 'list))))

(provide 'coverage-test)

;;; coverage-test.el ends here
