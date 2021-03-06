% Code to fit the history-dependent drift diffusion models as described in
% Urai AE, de Gee JW, Tsetsos K, Donner TH (2019) Choice history biases subsequent evidence accumulation. eLife, in press.
%
% MIT License
% Copyright (c) Anne Urai, 2019
% anne.urai@gmail.com

%% ========================================== %
% determine how the figures will look
% ========================================== %

clear all; clc; close all;
set(groot, 'defaultaxesfontsize', 6, 'defaultaxestitlefontsizemultiplier', 1.1, ...
    'defaultaxeslabelfontsizemultiplier', 1.1, ...
    'defaultaxestitlefontweight', 'bold', ...
    'defaultfigurerenderermode', 'manual', 'defaultfigurerenderer', 'painters', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.05], 'defaultaxestickdir', 'out', 'DefaultAxesTickDirMode', 'manual', ...
    'defaultfigurecolormap', [1 1 1], 'defaultTextInterpreter','tex', ...
    'DefaultFigureWindowStyle','normal');

global datasets datasetnames mypath colors
dbstop if error % for debugging

usr = getenv('USER');
switch usr
    case {'anne', 'urai'}
        mypath = '~/Data/HDDM';
    case 'aeurai'
        mypath  = '/nfs/aeurai/HDDM';
end

% ORDER O THE DATASETS
datasets = {'Murphy', 'Anke_MEG_transition', 'NatComm', 'MEG', 'JW_PNAS', 'JW_yesno'};
datasetnames = {{'Visual motion' '2AFC (RT)'},   {'Visual motion' '2AFC (FD)'},...
    {'Visual motion' '2IFC (FD) #1'}, {'Visual motion' '2IFC (FD) #2'}, ...
    {'Visual contrast' 'yes/no (RT)'}, {'Auditory' 'yes/no (RT)'}};

% go to code folder
try
    addpath(genpath('~/code/Tools'));
    cd('/Users/urai/Documents/code/serialDDM');
end

% from Thomas, green; blue; darkteal
colors = [77,175,74; 55,126,184; 52, 103, 51] ./ 256; % green blue

% ========================================== %
% PREPARING DATA
% This will generate the allindividualresults.csv files
% ========================================== %

if 0,
    read_into_Matlab(datasets);
    read_into_Matlab_gSquare(datasets);
    make_dataframe(datasets);
    rename_PPC_files(datasets);
end
disp('starting visualization');

% ========================================== %
% Figure 1. SCHEMATIC/HYPOTHESES
% ========================================== %

schematic;

% ========================================== %
% FIGURE 2
% ========================================== %

repetition_range;
strategy_plot;

% ========================================== %
% FIGURE 3
% ========================================== %

barplots_modelcomparison;

close all; subplot(3,3,1);
conditional_bias_functions_collapsed(3, 3, 'rt', 0, 0);
tightfig; print(gcf, '-dpdf', '~/Data/serialHDDM/conditionalBiasFunctions_collapsed.pdf'); % 3b

% barplots
close all; conditional_bias_functions_collapsed_summary;
print(gcf, '-dpdf', '~/Data/serialHDDM/conditionalBiasFunctions_barplots.pdf'); % 3c

% ========================================== %
% FIGURE 4
% ========================================== %

alldat = individual_correlation_main(0, 0); % figure 4
forestPlot(alldat);
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_st%d_HDDM.pdf', 0));

% ========================================== %
% FIGURE 5
% ========================================== %

alldat = individual_correlation_prevcorrect;
% separate plots for correct and error
forestPlot(alldat(1:2:end));
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_HDDM_prevcorrect.pdf'));
forestPlot(alldat(2:2:end));
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_HDDM_preverror.pdf'));

% compare the correlation coefficients for figure 5d
compare_correlations_correct_error(alldat);

% DIC comparison
%vbarplots_DIC_previousresponse_outcome;

% ========================================== %
% FIGURE 6
% ========================================== %

kernels_lags_bestmodel;
correlations_regression_lags; % forestplot for multi-lag regression models

% ========================================== %
% FIGURE 7
% ========================================== %

% a. motion energy filtering: this has to run before, 
% on the UKE cluster to grab Anke's motionenergy coordinates
motionEnergy_filterDots;
motionEnergy_check;
motionEnergy_kernels;

% grab the results from Kostis' fits
% kostis_driftRate;
kostis_makeTable_v2;

% a. panel with all BIC plots
% kostis_all_BICs;
kostis_all_AICs;

% same for correlations, one big plot
kostis_all_correlations_selected;

% timecourse of dynamic bias signal, across models
plot_dynamic_bias_signal_hanks;

% ========================================== %
% SUPPLEMENTARY FIGURE 1
% ========================================== %

% see graphicalModels.manualGraphical.py
% run in Python: plot_HDDM_priors.py

% ========================================== %
% SUPPLEMENTARY FIGURE 2
% ========================================== %

dprime_driftrate_correlation;
posterior_predictive_checks;
history_kernels;
strategy_plot_2-7;

% ========================================== %
% SUPPLEMENTARY FIGURE 3
% ========================================== %

plot_posteriors;

% ========================================== %
% SUPPLEMENTARY FIGURE 4
% ========================================== %

% a. G-square fit
alldat = individual_correlation_main(1, 0);
forestPlot(alldat);
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_st%d_Gsq.pdf', 0));
barplots_BIC;

% b. fit with between-trial variability in non-decision time
alldat = individual_correlation_main(0, 1); %
forestPlot(alldat);
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_st%d_HDDM.pdf', 1));

% c. added non-decision time between coherence levels

nondecisiontime_coherence;
barplots_DIC_stcoh;

alldat = individual_correlation_tcoh(); % figure 4
forestPlot(alldat);
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_tcoh_HDDM.pdf'));

% ========================================== %
% SUPPLEMENTARY FIGURE 5
% ========================================== %

alldat = individual_correlation_pharma();
forestPlot(fliplr(alldat));
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_pharma.pdf'));

% ========================================== %
% SUPPLEMENTARY FIGURE 6
% ========================================== %

post_error_slowing;

% ========================================== %
% SUPPLEMENTARY FIGURE 7
% ========================================== %

barplots_modelcomparison_regression;

% ========================================== %
% SUPPLEMENTARY FIGURE 9
% see JW's code in simulations/ folder
% ========================================== %

% ========================================== %
% MEG REGRESSION RESULTS 
% FOR SFN2018 POSTER
% ========================================== %

meg_regression_dic;
meg_regression_posteriors;

% ========================================== %
% repeaters vs alternators
% ========================================== %

individual_correlations_repeaters_vs_alternators;

% ========================================== %
% combine post-error slowing with choice history
% ========================================== %

alldat = individual_correlation_PES; % figure 4
forestPlot(alldat);
print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/forestplot_PES_HDDM.pdf'));

% ========================================== %
% CUMULATIVE P(REPEAT)
% ========================================== %

cumulative_prepeat;

