#!/usr/bin/env python3

import json
import sys

import argparse as ap
import pandas as pd
import matplotlib.pyplot as plt

from argparse import ArgumentParser
from typing   import List, Dict, Set

debug = False

def DEBUG(*args):
    if debug:
        print("DEBUG", *args, file=sys.stderr)

class PlotOptions:
    name: str
    nogrid: bool
    kind: str

    def __init__(self, name: str, kind: str, nogrid: bool):
        self.name = name
        self.kind = kind
        self.nogrid = nogrid

class PlotSpec:
    x: str
    y: List[str]
    compositeY: (str, str)
    isComposite: bool

    def __init__(self, spec: str):
        DEBUG("INITING PLOTSPECT FROM str='{}'".format(spec))
        parts = spec.split(":")
        if len(parts) != 2:
            raise Exception("expected plot spec to have 2 parts delimited by ':'")

        if parts[0] == "":
            parts[0] = "*"

        self.x = parts[1]
        self.y = parts[0].split(",")
        self.compositeY = ("", "")
        self.isComposite = False

        compositeY = self.y[0].split("=")
        if len(compositeY) == 2:
            self.isComposite = True
            self.compositeY = (compositeY[0], compositeY[1])
            self.y = []

        DEBUG("PSX", self.x)
        DEBUG("PSY", self.y)
        DEBUG("PSIC", self.isComposite)
        DEBUG("PSCY", self.compositeY)


    def Plot(self, data: str, fmt: str, group: str, opts: PlotOptions):
        df = None

        if fmt == 'json':
            df = pd.read_json(data)
        elif fmt == 'csv':
            df = pd.read_csv(data)
        elif fmt == 'excel':
            df = pd.read_excel(data)
        elif fmt == 'xml':
            df = pd.read_xml(data)
        elif fmt == 'html':
            df = pd.read_html(data)
        else:
            raise Exception("uknonwn format='{}'".format(fmt))

        if self.isComposite:
            df = pd.pivot_table(df, index=self.x, columns=self.compositeY[0], values=self.compositeY[1])

        DEBUG("DF")
        DEBUG(df)
        DEBUG("DFKEYS", df.keys())

        xAxis = None
        if not self.isComposite:
            xAxis = self.x

        df.plot(x=xAxis, kind=opts.kind)
        if not opts.nogrid:
            plt.grid()

        plt.title(opts.name)
        plt.legend()
        plt.tight_layout()
        plt.show()


parser = ArgumentParser(description='Plot data')

parser.add_argument('-i', '--input',   dest='input',      type=str,            default='',     help='input file with data (by default reads from stdin)')
parser.add_argument('-f', '--format',  dest='format',     type=str,            default='json', help='data format (available: json)')
parser.add_argument('-s', '--groupby', dest='group',      type=str,            default='',     help='output multiple plots grouped by a list of parameters')
parser.add_argument('-p', '--plot',    dest='plotFormat', type=str,            default='line', help='specify plot format (line or bar)')
parser.add_argument('-n',  '--name',   dest='name',       type=str,            default='',     help='specify name for plot')
parser.add_argument('--nogrid',        dest='nogrid',     action='store_true', default=False,  help='disable grid on plot')

parser.add_argument('-d', '--debug',   dest='debug',     action='store_true', default=False,  help='enable debug output')
parser.add_argument('plot', metavar='spec', type=str, default='', help='specify what to plot (like "y:x", "y1,y2:x", "*:x", ":x", "key=value:x" etc)')

args = parser.parse_args()
debug = args.debug

DEBUG("INPUT",      args.input)
DEBUG("FORMAT",     args.format)
DEBUG("PLOT",       args.plot)
DEBUG("GROUP",      args.group)
DEBUG("PLOTFORMAT", args.plotFormat)

if args.input != '':
    with open(args.input) as f:
        inputData = f.read()
else:
    inputData = sys.stdin.read()

if args.plot == '':
    raise Exception("empty plot spec")

DEBUG("------------")
DEBUG(inputData)
DEBUG("============")

# data = parseData(inputData, args.format)
# DEBUG("DATA", data)
ps = PlotSpec(args.plot)
po = PlotOptions(args.name, args.plotFormat, args.nogrid)
pd = ps.Plot(inputData, args.format, args.group, po)
