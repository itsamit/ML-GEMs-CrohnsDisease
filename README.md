# ML-GEMs-CrohnsDisease
Integrating Mechanistic and Machine Learning Models to Identify Metabolic Reprogramming in Crohn's Disease

This repository contains the complete computational workflow used in our manuscript for identifying metabolic reprogramming in Crohn's disease by integrating deep generative learning, context-specific genome-scale metabolic modelling (GEM), genome-scale differential flux analysis (GS-DFA), machine learning, pathway enrichment, and drug–gene interaction analysis.

Software Requirements
Python
Python ≥ 3.10
Required packages
numpy
pandas
scipy
scikit-learn
tensorflow
keras
matplotlib
openpyxl
jupyter
```

Install using

```bash
pip install numpy pandas scipy scikit-learn tensorflow keras matplotlib openpyxl notebook
```

MATLAB

- MATLAB 2024a
- COBRA Toolbox
- Gurobi Optimizer
- Recon3D metabolic model

Please ensure that COBRA Toolbox is correctly configured before running the MATLAB scripts.

Workflow

Generate synthetic transcriptomic profiles

1. Open ‘1.synthetic_data_production’
2. Run ‘vaegan_mf_cf_cd.ipynb’ [Input: input_cf_mf_cd.csv] #this you need to change according to your input.

These notebook trains the VAE–GAN model and generate synthetic transcriptomic samples for healthy and Crohn's disease conditions.
These synthetic transcriptomic samples should be filtered to retain the biologically feasible transcriptomic profiles for subsequent analysis.

Afterwards we follow clustering and representative pair selection for each class. And generate 10 representative clusters for each condition. 

Generate context-specific metabolic models

1. Open ‘2.Generating_tissue_specific_models’
2. Run gan_gem.m
Required input files:
a. RNAseq_Cluster_Mean_Expression.xlsx (this file need to be changed as per the current file)
b. Recon3D_HAM_19.csv
c. Recon3D metabolic model

The script reconstructs context-specific metabolic models using COBRA Toolbox, iMAT, Gurobi Optimizer under HAM media conditions.
This script will produce the context specific models for each cluster centroid for each class and save accordingly. As in the previous stage we select 10 clusters for each class so we will get same amount of context specific models.

Genome scale differential flux analysis (GS-DFA)

1. Open ‘3.Analysis/Flux_Sampling’
2. Run all cells subsequently from Flux_sampling.ipynb
Input:
Context-specific metabolic models generated in previous Step. [here we have 100 total combinations]

The notebook performs ACHR flux sampling. 
From 100 combinations we segregate the top 5 most altered combinations. And take output for those 5 combinations. And also merged those 5 combinations too.

Output includes-
Healthy_CommonFlux.csv
CD_CommonFlux.csv
Common_Reactions.csv
Merged_HealthyFlux.csv
Merged_CDFlux.csv

Statistical significance testing
1. Open ‘3.Analysis/KS_Test’
2. Run KS_Test.ipynb
The notebook performs Kolmogorov–Smirnov test, Benjamini–Hochberg FDR correction

Output:
Combined_sigFC_Results.csv
Combined_MWU_Results.csv
Consensus_Reactions_Pathways.csv

Machine Learning-Based Prioritization analysis
Following genome-scale differential flux analysis (GS-DFA), this step prioritizes the most disease-associated metabolic reactions using a Support Vector Machine (SVM)-based machine learning framework. Rather than applying machine learning directly to transcriptomic data, the SVM model is trained using reaction-level flux features derived from the consensus GS-DFA results, enabling the identification of the most discriminative metabolic reactions associated with Crohn's disease.

1. Open and run ‘3.Analysis/KS_Test/Top50_SVM.ipynb’
Input:
The notebook requires the following file generated from the previous GS-DFA and KS-test workflow- ‘Consensus_Reactions_Pathways.csv’

The notebook performs the following analyses:
a. Loads the consensus reaction dataset obtained after GS-DFA.
b. Removes missing or invalid values.
c. Computes reaction-level features, including:
   - Fold Change (FC)
   - P-value
   - Adjusted P-value (FDR)
d. Normalizes the statistical and flux-based features.
e. Trains a linear Support Vector Machine (SVM) model using the reaction features.
f. Estimates the relative importance of each reaction from the trained SVM model.
g. Integrates SVM importance, statistical significance, and flux alteration into a composite importance score.
h. Ranks all metabolic reactions according to the composite score.
i. Selects the Top 50 highest-ranked reactions.
j. Performs hierarchical clustering of the selected reactions.
k. Generates the reaction clustering and importance visualization used in the manuscript.

Pathway enrichment analysis

1. Open ‘3.Analysis/Pathway_enrichment’
2. Run Pathway_enrichment.ipynb
Required input:
Combined_sigFC_Results.csv
Recon3D_RxnID_Subsystem.csv
Output: CD_Combined_Results_Pathway_enrichment.csv along with pathway enrichment figures.
Drug–gene interaction analysis (External step)
The drug–gene interaction analysis is performed outside this repository.
The prioritized genes are queried against Comparative Toxicogenomics Database (CTD) and Drug–Gene Interaction Database (DGIdb) to identify clinically relevant therapeutic targets and potential drug repurposing candidates.
—————————————————————————————————————————————

The workflow generates
- Synthetic transcriptomic profiles
- Context-specific metabolic models
- Flux distributions
- GS-DFA results
- Differential metabolic reactions
- Consensus altered reactions
- Pathway enrichment results
- Pathway figures
- Prioritized disease-associated genes
- Candidate therapeutic targets
