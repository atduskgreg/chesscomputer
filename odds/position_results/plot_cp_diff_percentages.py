import numpy as np
from matplotlib import pyplot as plt

import csv



def getColumn(column, colType):
	results = csv.reader(open("cp_diff_win_percentage.csv"))
	if colType == "int":
		return [int(result[column]) for result in results]
	if colType == "float":
		return [float(result[column]) for result in results]


score = getColumn(0,"int")
percent = getColumn(1, "float")

print len(score)
print len(percent)

plt.figure("CP score vs win percentage")
plt.xlabel("CP score")
plt.ylabel("win percentage")
plt.scatter(score,percent)

coefficients = np.polyfit(score, percent, 4)
print coefficients
poly = np.poly1d(coefficients)
xs = np.arange(1,600)
ys = poly(xs)

line = plt.plot(xs,ys)
plt.setp(line, color='r', linewidth=3.0)
plt.show()