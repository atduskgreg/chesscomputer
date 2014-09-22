import argparse
import yaml
import numpy as np
from matplotlib import pyplot as plt
import re

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("yaml_file", help="Path to the yaml file with the position choice data.")
args = parser.parse_args()
	
f = open(args.yaml_file)
data = yaml.safe_load(f)
f.close()


m = open("running_choice_average.yml")
mean_data = yaml.safe_load(m)
m.close()

attributes = ['Passed pawns', 'King safety', 'Threats', 'Space']
n = np.arange(len(attributes))
bars = []
colors = []
for attribute in attributes:
	val = data[attribute]['mg']['mean'] - mean_data[attribute]['mg']
	p_val =  data[attribute]['mg']['stats']['p']
	bars.append(val) 
	if p_val <= 0.05:
		if val >= 0:
			colors.append('g')
		else:
			colors.append('r')
	else:
		colors.append('k')

rx = re.compile(r'\.|\/')
parts = rx.split(args.yaml_file)
player_name = parts[len(parts)-2]

plt.bar(n, bars, 0.35, align='center', color=colors)

plt.axhline(y=0,color='k',ls='dashed')

plt.ylim([-0.005, 0.007])

plt.xticks(n ,attributes, fontsize='8')
plt.suptitle(player_name, fontsize='16')
plt.savefig('graphs/' + player_name + ".png")
plt.show()

