#!/bin/sh
basex/bin/basex -bsource_url=missingART19.xml fgases-equipment-envelope.xquery > out.html && google-chrome-stable out.html