import argparse
from scipy import stats
import numpy as np


parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("path", help="Path to a comma-separated list where the first row is the observed counts and the second row is the expected counts")
args = parser.parse_args()

f = open(args.path, 'r').read()

lines = f.split("\n")

observed = [float(x) for x in lines[0].split(",")]
expected = [float(x) for x in lines[1].split(",")]

result = stats.chisquare(np.array(observed),np.array(expected))

print "chi:%.5f\np:%.5f"  % result