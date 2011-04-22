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

cntx = 5
cnty = 10
scalex = 1.2
scaley = 1.2

f = open('people.txt','r')
items = f.readlines()
f.close()

items = map(lambda x: x.strip(), items)
items += ['cred50','cred100','cred200','cred500','cred1000','RESET']

f = open('barcodes.svg','w')
f.write(svghead)

i = 0
j = 0
for item in items:
    elem = Popen(('zint','--directsvg','-d', item), stdout = PIPE).communicate()[0].split('\n')
    elem = elem[8:-2]
    elem[0] = elem[0].replace('id="barcode"', 'transform="matrix(%f,0,0,%f,%f,%f)"' % (scalex, scaley, 42+i*200 , 14+j*90) )
    elem[23] = item
    f.write('\n'.join(elem))
    i += 1
    if i >= cntx:
        i = 0
        j += 1

f.write(svgfoot)
f.close()
