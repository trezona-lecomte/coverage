;;; Package -- summary
;;; Commentary:
;;; Code:
(require 'ert)
(require 'ert-expectations)
(require 'coverage)

(defvar quux-results  '(nil 1 nil nil 0 0 16))
(defvar bar-results '(1 0 nil))

(defvar example-json `((RSpec
                        (timestamp . 1453405229)
                        (coverage
                         (/baz/qux/quux\.rb . ,(coerce quux-results 'array))
                         (/foo/bar\.rb . ,(coerce bar-results 'array))))))

(expectations
  (desc "get json from a resultset file")
  (expect example-json
    (coverage-get-json-from-file "./example.json"))

  (desc "get list of results for a file in the resultset")
  (expect quux-results
    (coverage-get-results-for-file "/baz/qux/quux.rb" "./example.json"))

  (desc "get the default result path for a file")
  (expect "~/dev/coverage/coverage/.resultset.json"
    (coverage-result-path-for-file "~/dev/coverage/test/.example.json"))

  (desc "get coverage dir for a file from the git root")
  (expect "~/dev/coverage/coverage/"
    (coverage-dir-for-file "~/dev/coverage/test/.example.json"))
  )

(provide 'coverage-test)

;;; coverage-test.el ends here
