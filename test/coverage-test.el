;;; Package -- summary
;;; Commentary:
;;; Code:
(require 'ert)
(require 'coverage)

(ert-deftest coverage-test-get-results-for-file-1 ()
  (should (equal (coverage-get-results-for-file "/foo/bar.rb" "./example.json")
                 '(1 0 nil))))

(ert-deftest coverage-test-get-results-for-file-2 ()
  (should (equal (coverage-get-results-for-file "/baz/qux/quux.rb" "./example.json")
                 '(1 5 0 nil 1 5 nil nil 1 nil nil 0 0 16 nil))))

(provide 'coverage-test)

;;; coverage-test.el ends here
