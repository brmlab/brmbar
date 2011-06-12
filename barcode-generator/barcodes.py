#!/usr/bin/python
#
# requires zint binary from zint package
#

from subprocess import Popen, PIPE
import sys

svghead = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="1052.3622" height="744.09448" version="1.1" id="svg2" inkscape:version="0.47 r22583" sodipodi:docname="barcodes.svg">
"""

svgfoot = """
</svg>
"""

width = 4
scalex = 1.2
scaley = 1.2

f = open('../dos/people.txt','r')
items = f.readlines()
f.close()

items = map(lambda x: x.strip(), items)
itemss = map(lambda x: x[0:3], items)

f = open('../dos/items.txt','r')
for l in f.readlines():
    l = l.strip().split(';')
    if int(l[2]) >= 0:
        items += [l[1]]
        itemss += [l[0]]
f.close()


p = 0
i = 0
j = 0
for idx in xrange(len(items)):
    if idx % 8 == 0:
        if not f.closed:
            f.write(svgfoot)
            f.close()
        f = open('barcodes' + str(p) + '.svg','w')
        p += 1
        i = 0
        j = 0
        f.write(svghead)
    elem = Popen(('zint','--directsvg','-d', itemss[idx]), stdout = PIPE).communicate()[0].split('\n')
    elem = elem[8:-2]
    elem[0] = elem[0].replace('id="barcode"', 'transform="matrix(%f,0,0,%f,%f,%f)"' % (scalex, scaley, 50+i*285 , 180+j*285) )
    elem[21] = elem[21].replace(' y="59.00" ', ' y="69.00" ')
    elem[22] = elem[22].replace(' font-size="8.0" ', ' font-size="14.0" ')
    elem[23] = items[idx]
    f.write('\n'.join(elem))
    i += 1
    if i >= width:
        i = 0
        j += 1

if not f.closed:
    f.write(svgfoot)
    f.close()
