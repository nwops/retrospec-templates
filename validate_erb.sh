#!/usr/bin/env bash

find ./ -type f -name '*.erb' -exec ./erb_template_syntax_check.sh {} \;
