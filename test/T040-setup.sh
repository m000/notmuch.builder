#!/usr/bin/env bash

test_description='"notmuch setup"'
. $(dirname "$0")/test-lib.sh || exit 1

test_begin_subtest "Notmuch new without a config suggests notmuch setup"
output=$(notmuch --config=new-notmuch-config new 2>&1)
test_expect_equal "$output" "\
Error: cannot load config file.
Try running 'notmuch setup' to create a configuration."

test_begin_subtest "Create a new config interactively"
notmuch --config=new-notmuch-config > log.${test_count} <<EOF
Test Suite
test.suite@example.com
another.suite@example.com

/path/to/maildir
foo bar
baz
EOF

expected_dir=$NOTMUCH_SRCDIR/test/setup.expected-output
test_expect_equal_file ${expected_dir}/config-with-comments new-notmuch-config

test_begin_subtest "notmuch with a config but without a database suggests notmuch new"
notmuch 2>&1 | notmuch_dir_sanitize > OUTPUT
cat <<EOF > EXPECTED
Notmuch is configured, but there's not yet a database at

	MAIL_DIR/.notmuch

You probably want to run "notmuch new" now to create that database.

Note that the first run of "notmuch new" can take a very long time
and that the resulting database will use roughly the same amount of
storage space as the email being indexed.

EOF
test_expect_equal_file EXPECTED OUTPUT

test_done
