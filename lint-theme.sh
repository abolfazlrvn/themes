#!/bin/sh
# Simple script to check for common errors in themes

do_lint() {
    echo "== Linting $1 =="

    if [ ! -d $1 ] ; then
        echo " * Does not exist!"
        return 1
    fi

    cd $1

    if [ ! -f theme.json ] ; then
        echo " * Missing theme.json, skipping further checks!"
        cd ..
        return 1
    fi

    if [ ! -f screen.png ] ; then
        echo " * Missing screen.png, skipping further checks!"
        cd ..
        return 1
    fi

    JVERSION=`php -r "echo json_decode(file_get_contents('theme.json'), true)['version'];"`
    echo " * Version from theme.json: $JVERSION"
    if [ -n "$VERSION" -a "$JVERSION" != "$VERSION" ] ; then
        echo " * Versions do not match: theme.json ($JVERSION), info.inc.php ($VERSION)"
        cd ..
        return 1
    fi
    VERSION=$JVERSION
    echo " * Supported phpMyAdmin versions: `php -r "echo implode(', ', json_decode(file_get_contents('theme.json'), true)['supports']);"`"
    echo " * Metadata:"
    php -r "\$data = json_decode(file_get_contents('theme.json'), true); foreach (\$data as \$item => \$value) { echo '   - ' . \$item . ': '; if (is_array(\$value)) { echo implode(', ', \$value); } else { echo \$value; }; echo \"\\n\"; }"

    cd ..
}

if [ -z "$1" ] ; then
    echo "Usage: lint-theme.sh [--all|THEMEDIR]"
    exit 1
fi

if [ "x$1" = "x--all" ] ; then
    for dir in `find . -mindepth 1 -maxdepth 1 -type d` ; do
        do_lint $dir
        if [ $? -ne 0 ] ; then
            exit 0
        fi
    done
else
    do_lint $1
    exit $?
fi
