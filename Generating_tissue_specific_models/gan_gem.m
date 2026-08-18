% ============================================================
% Generate ALL context-specific models (per sample)
% ============================================================

initCobraToolbox(false);

% Load model
model = readCbModel('/Users/apple/SCOOTI/SCOOTI/metabolicModel/GEMs/Recon3D.mat');

% Load expression data
exprData = readtable('/Users/apple/Downloads/Script_CBM_and_Analysis/RNAseq_Cluster_Mean_Expression.xlsx');
titles = exprData.Properties.VariableNames;

% Solver
changeCobraSolver('gurobi', 'LP');
changeCobraSolver('gurobi', 'MILP');

% Objective
model = changeObjective(model, 'BIOMASS_maintenance');
core = {'BIOMASS_maintenance'};
tol = 1e-6;

% Media constraints
media = readtable('/Users/apple/Downloads/Script_CBM_and_Analysis/3.Generating_tissue_specific_models/Recon3D_HAM_19.csv');
metList = table2array(media(:,8));
lb = table2array(media(:,9));

% ============================================================
% LOOP THROUGH ALL SAMPLES
% ============================================================

for i = 2:length(titles)

    fprintf("Processing sample: %s\n", titles{i});

    % ----------------------------
    % Expression mapping
    % ----------------------------
    geneIDs = exprData{:,1};
    exprValues = exprData{:,i};

    expressionStruct.gene = geneIDs;
    expressionStruct.value = exprValues;

    highThreshold = prctile(exprValues, 75);
    lowThreshold  = prctile(exprValues, 25);

    [expressionRxns, ~] = mapExpressionToReactions(model, expressionStruct);

    % ----------------------------
    % Build model (iMAT)
    % ----------------------------
    tissueModel = iMAT(model, expressionRxns, lowThreshold, highThreshold, tol, core);
    tissueModel = removeUnusedGenes(tissueModel);

    % ----------------------------
    % Apply media constraints
    % ----------------------------
    exc = tissueModel.rxns(findExcRxns(tissueModel));

    % Close all exchanges first
    tissueModel = changeRxnBounds(tissueModel, exc, 0, 'l');

    % Open only defined media
    for j = 1:length(metList)
        rxns = findRxnsFromMets(tissueModel, metList{j});
        if ~isempty(rxns)
            tissueModel = changeRxnBounds(tissueModel, rxns, lb(j), 'l');
        end
    end

    % ----------------------------
    % Save model
    % ----------------------------
    
    % Create folder automatically
    if contains(titles{i}, 'CF_CD')
        folder = 'models_CF_CD';
    elseif contains(titles{i}, 'MF_CD')
        folder = 'models_MF_CD';
    elseif contains(titles{i}, 'H')
        folder = 'models_Healthy';
    else
        folder = 'models_Others';
    end

    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    save(fullfile(folder, ['iMAT_' titles{i} '.mat']), 'tissueModel');

end

disp('All models generated successfully!');