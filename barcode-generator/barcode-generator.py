#!/usr/bin/python
#
# requires zint binary from zint package
#

from subprocess import Popen, PIPE
import sys

svghead = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" height="1052.3622" width="744.09448" version="1.1" id="svg2" inkscape:version="0.47 r22583" sodipodi:docname="barcodes.svg">

"""

svgfoot = """</svg>
"""

width = 5
scalex = 0.8
scaley = 0.8

p = 0
i = 0
j = 0
f = None

lines = sys.stdin.readlines()

for idx in xrange(len(lines)):
    items = lines[idx].strip().split(';')
    if idx % 30 == 0:
        if f and not f.closed:
            f.write(svgfoot)
            f.close()
        f = open('barcodes' + str(p) + '.svg','w')
        p += 1
        i = 0
        j = 0
        f.write(svghead)
    elem = Popen(('./zint','--directsvg','--notext', '-d', items[1]), stdout = PIPE).communicate()[0].split('\n')
    elem = elem[8:-2]
    elem[0] = elem[0].replace('id="barcode"', 'transform="matrix(%f,0,0,%f,%f,%f)"' % (scalex, scaley, 50+i*140 , 180+j*140) )
    elem.insert(-1, '      <text x="39.50" y="69.00" text-anchor="middle" font-family="Helvetica" font-size="14.0" fill="#000000" >%s</text>' % items[0])
    f.write('\n'.join(elem)+'\n\n')
    i += 1
    if i >= width:
        i = 0
        j += 1

if not f.closed:
    f.write(svgfoot)
    f.close()
