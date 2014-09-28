import numpy as np
from matplotlib import pyplot as plt
from scipy.optimize import curve_fit
from scipy.stats import logistic
import csv

def sigmoid(x, x0, k):
     y = 1 / (1 + np.exp(-k*(x-x0)))
     return y


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

popt, pcov = curve_fit(sigmoid, score, percent)
print popt
x = np.linspace(-1000, 1000, 50)
y = sigmoid(x, *popt)
plt.plot(x,y, label='fit', color="r", linewidth=3.0)


# # coefficients = np.polyfit(score, percent, 5)
# # print coefficients
# # poly = np.poly1d(coefficients)
# xs = np.arange(-1000,1000)
# # ys = logistic.fit(xs)
# # xFit = curve_fit(sigmoid, percent, 3, 2)[0]
# ys = sigmoid(xs)
# line = plt.plot(xs,ys)
# plt.setp(line, color='r', linewidth=3.0)
plt.show()