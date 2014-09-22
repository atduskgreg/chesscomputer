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


attributes = ['Passed pawns', 'King safety', 'Threats', 'Space']
n = np.arange(len(attributes))
bars = []
for attribute in attributes:
	bars.append(data[attribute]['mg']['mean'])

rx = re.compile(r'\.|\/')
parts = rx.split(args.yaml_file)
player_name = parts[len(parts)-2]

plt.bar(n, bars, 0.35, align='center', color='k')

plt.ylim([0, 0.02])

plt.xticks(n ,attributes, fontsize='8')
plt.suptitle(player_name, fontsize='16')
plt.savefig('graphs/' + player_name + ".png")
plt.show()

