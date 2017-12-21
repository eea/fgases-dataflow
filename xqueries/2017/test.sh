#!/bin/sh
basex/bin/basex -bsource_url=fgases-test.xml fgases-2017.xquery > out.html && google-chrome-stable out.html