#!/bin/sh
basex/bin/basex -bsource_url=tests/qc-2017-test.xml fgases-2017.xquery > out.html && google-chrome-stable out.html