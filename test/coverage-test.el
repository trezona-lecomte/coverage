;;; Package -- summary
;;; Commentary:
;;; Code:
(require 'ert)
(require 'ert-expectations)
(require 'coverage)
(require 'el-mock)

(defvar quux-results)
(setq quux-results '(nil 1 nil nil 0 0 16))

(defvar bar-results)
(setq bar-results '(1 0 nil))

(defvar example-json)
(setq example-json `((provider-1
		      (coverage
		       (/foo/bar\.rb . ,(coerce bar-results 'array)))
		      (timestamp . 1234567890))
		     (provider-2
		      (coverage
		       (/baz/qux/quux\.rb . ,(coerce quux-results 'array)))
		      (timestamp . 6789012345))))

(expectations
  (desc "get json from a resultset file")
  (expect example-json
    (coverage-get-json-from-file "./example.json"))

  (desc "get list of results for a file in the resultset")
  (expect quux-results
    (coverage-get-results-for-file "/baz/qux/quux.rb" "./example.json"))

  (desc "get the default result path for a file")
  (expect "~/dev/coverage/coverage/.resultset.json"
    (with-mock
     (stub vc-git-root => "~/dev/coverage/")
     (coverage-result-path-for-file "~/dev/coverage/test/.example.json")))

  (desc "get coverage dir for a file from the git root")
  (expect "~/dev/coverage/coverage/"
    (with-mock
     (stub vc-git-root => "~/dev/coverage/")
     (coverage-dir-for-file "~/dev/coverage/test/.example.json")))
  )

(provide 'coverage-test)

;;; coverage-test.el ends here
