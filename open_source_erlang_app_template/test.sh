#!/usr/bin/env bash

set -eux

OUR_DIRECTORY=$(realpath $(dirname "$0"))

#
# Ensure template is known to rebar3 under a temporary alias
#
TEMPLATE_ALIAS=$(tr -dc a-z </dev/urandom | head -c 20 ; echo '')
mkdir -p "$HOME/.config/rebar3/templates"
ln -s "$OUR_DIRECTORY" "$HOME/.config/rebar3/templates/$TEMPLATE_ALIAS"
ln -s "$OUR_DIRECTORY/oss_app.template" "$OUR_DIRECTORY/$TEMPLATE_ALIAS.template"

function cleanup {
    rm "$HOME/.config/rebar3/templates/$TEMPLATE_ALIAS"
    rm "$OUR_DIRECTORY/$TEMPLATE_ALIAS.template"
}

trap cleanup EXIT

#
# Set up temporary dir
#
TEMPORARY_DIR=$(mktemp -d)

function cleanup2 {
    cleanup
    rm -rf "$TEMPORARY_DIR"
}

trap cleanup2 EXIT

#
# Instantiate template
#
pushd "$TEMPORARY_DIR"
rebar3 new "$TEMPLATE_ALIAS" foobar

#
# Confirm tests and checks run
#
pushd foobar
make test check

popd
popd
