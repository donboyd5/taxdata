# examine the different weights

# %% imports
import numpy as np
import pandas as pd


# %% locations
WTDIR = "/media/don/data/puf_files/puf_csv_related_files/Boyd/2021-05-21/"
W50 = "puf_weights_50iter.csv"
W100 = "puf_weights_100iter.csv"
W500 = "puf_weights.csv"

# %% constants
qtiles = (0.0, 0.001, 0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99, 0.999, 1.0)


# %% get files
wt50 = pd.read_csv(WTDIR + W50)
wt100 = pd.read_csv(WTDIR + W100)
wt500 = pd.read_csv(WTDIR + W500)

wt500.info()

wts = ["WT2011", "WT2012", "WT2013", "WT2029", "WT2030"]
wt50.describe()[wts]
wt100.describe()[wts]
wt500.describe()[wts]

wt50.sum(axis=0)
wt100.sum(axis=0)
wt500.sum(axis=0)

wt50.sum(axis=0) / wt500.sum(axis=0) * 1000
wt100.sum(axis=0) / wt500.sum(axis=0) * 1000

np.quantile(wt50.WT2030, qtiles)
np.quantile(wt100.WT2030, qtiles)
np.quantile(wt500.WT2030, qtiles)

wt500.WT2030 / wt100.WT2030
np.quantile(wt500.WT2030 - wt100.WT2030, qtiles)
np.round(np.quantile(wt500.WT2030 - wt100.WT2030, qtiles), 2)
np.round(np.quantile(wt500.WT2030 - wt50.WT2030, qtiles), 2)

np.nanquantile(wt500.WT2030 / wt100.WT2030, qtiles)
np.round(np.quantile(wt500.WT2030 - wt100.WT2030, qtiles), 2)
np.round(np.quantile(wt500.WT2030 - wt50.WT2030, qtiles), 2)

np.argmax(wt500.WT2030 - wt100.WT2030)
i = 86411
wt500.WT2030[i]  # 249918
wt100.WT2030[i]  # 188182
+wt100.WT2030[i] / wt500.WT2030[i]  # 0.75

np.argmin(wt500.WT2030 - wt100.WT2030)
i = 141993
wt500.WT2030[i]  # 249918
wt100.WT2030[i]  # 188182
+wt100.WT2030[i] / wt500.WT2030[i]  #


# %% zero-weight records


OLD = "/media/don/data/puf_files/puf_csv_related_files/PSL/2020-08-20/puf_weights.csv"
NEW = "~/Downloads/puf_weights.csv"

old_weights = pd.read_csv(OLD)
new_weights = pd.read_csv(NEW)

old_weights.loc[(old_weights == 0).all(axis=1)]
new_weights.loc[(new_weights == 0).all(axis=1)]
