#!/usr/bin/env python3

import json
import sys

import argparse as ap
import matplotlib.pyplot as plt

from argparse import ArgumentParser
from typing   import List, Dict, Set

debug = False

def DEBUG(*args):
    if debug:
        print("DEBUG", *args, file=sys.stderr)

class PlottableData:
    data: List[dict]
    x: []
    y: Dict[str, List[float]]

    def __init__(self, x: [], y: Dict[str, List[float]]):
        DEBUG("PDX", x)
        DEBUG("PDY", y)
        self.x = x
        self.y = y

    def plot(self):
        fig, ax = plt.subplots()
        ax.figure.autofmt_xdate()
        for label in ax.get_xticklabels():
            label.set_ha("right")
            label.set_rotation(70)

        for k in self.y.keys():
            ax.plot(self.x, self.y[k], label=k)

        plt.legend()
        plt.grid()
        plt.show()

class PlotSpec:
    x: str
    y: List[str]

    def __init__(self, spec: str):
        DEBUG("INITING PLOTSPECT FROM str='{}'".format(spec))
        parts = spec.split(":")
        if len(parts) != 2:
            raise Exception("expected plot spec to have 2 parts delimited by ':'")

        if parts[0] == "":
            parts[0] = "*"

        self.x = parts[1]
        self.y = parts[0].split(",")

        DEBUG("PSX", self.x)
        DEBUG("PSY", self.y)

    def WithData(self, data: List[dict]) -> PlottableData:
        x: [] = []
        y: Dict[List[float]] = {}
        allKeys: Set[str] = set()
        if self.y[0] != "*":
            allKeys = self.y

        for item in data:
            if item.get(self.x) is None:
                raise Exception("missing x data ({}) in data item".format(self.x))

            x.append(item[self.x])

            if self.y[0] == "*":
                for k, v in item.items():
                    if k == self.x:
                        continue

                    allKeys.add(k)

        allKeys = list(allKeys)

        DEBUG("ALLKEYS", allKeys)
        compositeY: List[str] = {}

        compositeSplit = allKeys[0].split("=")
        if len(allKeys) == 1 and len(compositeSplit) > 1:
            key = compositeSplit[0]
            value = compositeSplit[1]
            allKeys = set()
            for item in data:
                if item[key] is None:
                    raise Exception("missing key='{}' for composite plot in dataframe={}".format(key, item))

                allKeys.add(item[key])


            DEBUG("ALLKEYS UPDATED", allKeys)
            newData: List[dict] = {}

            currentX = ""
            xValues: List = [ data[0][self.x] ]
            for item in data:
                if item[self.x] != xValues[len(xValues) - 1]:
                    xValues.append(item[self.x])

            x = xValues
            yValues: List[dict] = []

            # O(n^2) but I don't care, I just hate python and can't get over it
            for X in xValues:
                values: dict = {}
                for item in data:
                    if item[self.x] == X:
                        values[item[key]] = item[value]
                        values[self.x] = item[self.x]

                yValues.append(values)

            data = yValues
            DEBUG("NEW DATA", yValues)

        for k in allKeys:
            y[k]: List[float] = []


        for item in data:
            for k in allKeys:
                if item.get(k) is None:
                    y[k].append(None)
                else:
                    y[k].append(float(item[k]))

        return PlottableData(x, y)

def parseData(inputData: str, fmt: str) -> List[dict]:
    DEBUG("PARSING DATA IN {} FORMAT".format(fmt))
    data = json.loads(inputData)

    returnData: List[dict] = []

    if fmt == "json":
        if type(data) is list:
            for obj in data:
                if type(obj) is dict:
                    returnData.append(obj)
                else:
                    raise Exception("JSON input expected to be array of objects, got non-object")
        else:
            raise Exception("JSON input expected to be array of objects, got non-list")
    else:
        raise Exception("Unsupported format='{}'".format(fmt))

    return returnData

parser = ArgumentParser(description='Plot data')

parser.add_argument('-i', '--input',  dest='input',  type=str,            default='',     help='input file with data (by default reads from stdin)')
parser.add_argument('-f', '--format', dest='format', type=str,            default='json', help='data format (available: json)')
parser.add_argument('-d', '--debug',  dest='debug',  action='store_true', default=False,  help='enable debug output')
parser.add_argument('plot', metavar='spec', type=str, default='', help='specify what to plot (like "y:x", "y1,y2:x", "*:x", ":x", "key=value:x" etc)')

args = parser.parse_args()
debug = args.debug

DEBUG("INPUT",  args.input)
DEBUG("FORMAT", args.format)
DEBUG("PLOT",   args.plot)

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

data = parseData(inputData, args.format)
DEBUG("DATA", data)
ps = PlotSpec(args.plot)
pd = ps.WithData(data)
pd.plot()
