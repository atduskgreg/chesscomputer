import argparse
from scipy import stats


parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("path", help="Path to a comma-separated list of sample values")
parser.add_argument("--population-mean", help="The mean of the population from which this sample was drawn")
args = parser.parse_args()

f = open(args.path, 'r').read()
values = [float(x) for x in f.split(",")]
pop_mean = float(args.population_mean)

result = stats.ttest_1samp(values, pop_mean)

print "t:%.3f\np:%.3f"  % result