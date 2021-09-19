# P2P-RNFA Documentation

Checkout the branch 'code_forSharing'

Toy problem is solved in p2p-rnfa-trial.gms for 
  1. NLP without decomposition
  2. Steps 1-3 for MINLP to find multi-scale transactions for different pathways
  
P2P-RNFA optimization with decomposition solved in p2p-rnfa-trial-approximation.gms

Files for bio-fuels network
1. p2p-rnfa.gms - Optimization with decomposition for 2 pathway families with and without corn
2. lca-rnfa.gms - Only Life-cycle and reaction scale
3. rnfa.gms - Only reaction scale
4. pareto_script.sh - Bash script for generating required to make pareto front

Folder: incFiles - contains data intext format for 
1. Toy problem (incToy.inc) 
2. Sub-matrices in multi-scale transcations matrix for biofuels case study

Folder: resultBox - contains results for the multi-scale framework

Folder: oldFiles - contains previous versions of code, scripts for pareto etc.
