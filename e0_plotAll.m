
%% determine how the figures will look
clear all; clc; close all;
set(groot, 'defaultaxesfontsize', 6, 'defaultaxestitlefontsizemultiplier', 1.1, ...
    'defaultaxeslabelfontsizemultiplier', 1.1, ...
    'defaultaxestitlefontweight', 'bold', ...
    'defaultfigurerenderermode', 'manual', 'defaultfigurerenderer', 'painters', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.05], 'defaultaxestickdir', 'out', 'DefaultAxesTickDirMode', 'manual', ...
    'defaultfigurecolormap', [1 1 1], 'defaultTextInterpreter','tex');

global datasets datasetnames mypath

usr = getenv('USER');
switch usr
    case 'anne'
        mypath = '~/Data/HDDM';
    case 'aeurai'
        mypath  = '/nfs/aeurai/HDDM';
end

% neutral vs biased plots
datasets = {'RT_RDK', 'NatComm', 'MEG', 'Anke_2afc_sequential', ...
    'MEG_MEGsessions', 'JW_yesno', 'Bharath_fMRI', 'Anke_MEG'};
datasetnames = { {'2AFC, RT'}, ...
    {'2IFC, Urai et al. 2017'}, {'2IFC, replication'}, ...
    {'2AFC, Braun et al. 2017'}, ...
    {'2IFC, replication', 'MEG sessions'}, ...
    {'Auditory yes-no'}, {'Bharath fMRI'}, {'Anke MEG'}};

%% start the actual plots

disp('starting');

% e8_serialBias_SfN_PPC; % figure 2, show that all models fit OK

% f0_schematic_DDM_bias; % figure 3a
e1_serialBias_SfN_DIC; % figure 3b & c

e1b_serialBias_SfN_ModelFreeCorrelation; % figure 4
e2_serialBias_SfN_SanityChecks; % correlate dprime with drift rate

e9_prevCorrect; % error vs correct
e3_serialBias_SfN_Posteriors; % figure 4c

% to add (from regression models)
% - RT modulation
% - kernels (lags)

%
