import seaborn as sns, matplotlib.pyplot as plt
import numpy as np
import pandas as pd


data = pd.read_csv('fake_data.csv')

# we select rows where at least one of the participant is real (not a bot)
cond = (data['p1.is_bot'] + data['p2.is_bot']) != 2
data = data[cond]

# we get all contributions and multipliers + flatten the arrays
contributions = np.array(
    [data['p1.contribution'], data['p2.contribution']]).flatten()
multipliers = np.array(
    [data['p1.multiplier'], data['p2.multiplier']]).flatten()

# plot bars
sns.barplot(x=multipliers, y=contributions, capsize=.1)

# plot individual plots
sns.swarmplot(x=multipliers, y=contributions, color="black", alpha=.35)

plt.ylabel('Contribution')
plt.show()