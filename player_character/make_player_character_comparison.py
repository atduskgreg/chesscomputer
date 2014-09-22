import argparse
import yaml
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.patches as mpatches
import re


parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("yaml_file", help="Path to the yaml file with the position choice data.", nargs=2)
args = parser.parse_args()


	
p1 = open(args.yaml_file[0])
p1_data = yaml.safe_load(p1)
p1.close()

p2 = open(args.yaml_file[1])
p2_data = yaml.safe_load(p2)
p2.close()


m = open("running_choice_average.yml")
mean_data = yaml.safe_load(m)
m.close()

attributes = ['Passed pawns','Space', 'King safety', 'Threats']
n = np.arange(len(attributes))
bars = []
colors = []
for attribute in attributes:
	val = p1_data[attribute]['mg']['mean'] - p2_data[attribute]['mg']['mean']
	bars.append(val) 
	# if p_val <= 0.05:
	if val >= 0:
		colors.append('g')
	else:
		colors.append('r')


rx = re.compile(r'\.|\/')
parts1 = rx.split(args.yaml_file[0])
parts2 = rx.split(args.yaml_file[1])

player_name1 = parts1[len(parts1)-2]
player_name2 = parts2[len(parts2)-2]

b = plt.barh(n, bars, 0.35, align='center', color=colors)
# plt.legend([player_name1,player_name2], loc=0)
# plt.legend([b],[player_name1], loc=1)
# plt.legend([b],[player_name2], loc=0)

p1_patch = mpatches.Patch(color='green', label=player_name1)
p2_patch = mpatches.Patch(color='red', label=player_name2)
plt.legend([p2_patch, p1_patch], [player_name2, player_name1],bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
           ncol=2, mode="expand", borderaxespad=0.)

plt.axvline(x=0,color='k',ls='dashed')

# plt.xlim([-0.005, 0.007])

plt.xlim([-0.009, 0.009])

plt.yticks(n ,attributes, fontsize='12')
# plt.suptitle(player_name2 + " v. " + player_name1, fontsize='16')

# l2 = plt.legend([player_name2], loc=0)

plt.savefig('graphs/' + player_name1 + "v" + player_name2 + ".png")
plt.show()

