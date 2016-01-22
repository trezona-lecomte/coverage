Code coverage highlighting for Emacs
=======================================================

WIP!

The `code-coverage` minor mode enables the highlighting of lines
within a buffer to indicate their code coverage status as determined
by your test suite.

Currently `code-coverage` only works with output as supplied by the
[SimpleCov](https://github.com/colszowka/simplecov) gem, and it is
only configured to work with [RSpec](https://github.com/rspec/rspec)
results at present. My plan is to first expand support to other test
frameworks supported by SimpleCov, and then to other formats entirely.

Installation
=============

TODO: get melpa package working
TODO: add install instructions

Usage
=====

To enable `code-coverage` in the current buffer, use `M-x
code-coverage RET`. Repeat this command to disable.

Configuration
====

By default, `code-coverage` looks in your current `vc-git-root`
directory for the `coverage/.resultset.json` file. You can configure
this to whatever filepath you want through the `Coverage Dir`
customization variable.

You can also choose your own `faces` for covered & uncovered lines
through customization variables. These default to green for covered &
red for uncovered.
