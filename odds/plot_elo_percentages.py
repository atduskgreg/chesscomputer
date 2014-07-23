import numpy as np
from matplotlib import pyplot as plt

import csv



def getColumn(column, colType):
	results = csv.reader(open("elo_diff_win_percentage.csv"))
	if colType == "int":
		return [int(result[column]) for result in results]
	if colType == "float":
		return [float(result[column]) for result in results]


diff = getColumn(0,"int")
percent = getColumn(1, "float")

print len(diff)
print len(percent)

plt.figure("Elo difference vs win percentage")
plt.xlabel("Elo diff")
plt.ylabel("win percentage")
plt.scatter(diff,percent)

coefficients = np.polyfit(diff, percent, 4)
print coefficients
poly = np.poly1d(coefficients)
xs = np.arange(1,600)
ys = poly(xs)

line = plt.plot(xs,ys)
plt.setp(line, color='r', linewidth=3.0)
plt.show()