import gdxpds

import pandas as pd


gdx_file = 'out.gdx'
dataframes = gdxpds.to_dataframes(gdx_file)\

for symbol_name, df in dataframes.items():
    if symbol_name == 't_k':
        print(symbol_name)
        break;
        
        
        
for symbol_name, df2 in dataframes.items():
    if symbol_name == 'p_y':
        print(symbol_name)
        break;
        
        
for symbol_name, df3 in dataframes.items():
    if symbol_name == 'p_c':
        print(symbol_name)
        break;