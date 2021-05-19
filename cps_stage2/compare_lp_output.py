# %% imports
# import os
# import glob
import numpy as np

# import pandas as pd
# from pathlib import Path
# from dataprep import dataprep

# %% get data
CBC = "/media/don/data/taxdata_output/default_output/"
TULIP = "/home/donboyd/Documents/python_projects/taxdata/cps_stage2/"

qtiles = (0.0, 0.1, 0.25, 0.5, 0.75, 1.0)

year = 2014


array_cbc = np.load(str(CBC + str(year) + "_output.npz"))
r_cbc = array_cbc["r"]
s_cbc = array_cbc["s"]
x_cbc = 1 + r_cbc - s_cbc
np.quantile(x_cbc, qtiles)
np.abs(x_cbc - 1).sum()  # 34003.99705736397
# 233544  Obj 34003.997

array_tlp = np.load(str(TULIP + str(year) + "_output.npz"))
r_tlp = array_tlp["r"]
s_tlp = array_tlp["s"]
x_tlp = 1 + r_tlp - s_tlp
np.quantile(x_tlp, qtiles)
np.abs(x_tlp - 1).sum()  # 34004.8215019533
# Objective = 34004.8231

np.corrcoef(x_cbc, x_tlp)
# array([[1.        , 0.99895801],
#        [0.99895801, 1.        ]])
