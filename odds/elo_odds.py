from scipy import polyval
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("elos", help="Two ELO scores.", nargs=2, type=int)
args = parser.parse_args()

diff = abs(args.elos[0] - args.elos[1])

# coefficients for the polynomial that fits the elo score v win percentage graph
# get these by running plot_elo_percentages.py
coefficients = [ -3.33050902e-12, 7.69651076e-09, -6.73076942e-06, 2.79500149e-03, 4.92282512e-01]

print polyval(coefficients, diff)