#!/bin/sh
~/work/basex/bin/basex -bsource_url=Fluorinated_gases__F-Gases__reporting__2.xml fgases-2017.xquery > out.html && google-chrome-stable out.html