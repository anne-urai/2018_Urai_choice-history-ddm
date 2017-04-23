% from the csv table, make an overview of repetition behaviour

% get a huge list with values for each participant
% can then work with this dataframe

clear; close all; clc;
addpath(genpath('~/code/Tools'));
warning off;

% ============================================ %
% TWO DIFFERENT DATASETS
% ============================================ %

usr = getenv('USER');
switch usr
    case 'anne' % local
        datasets = {'RT_RDK', 'projects/0/neurodec/Data/MEG-PL', 'NatComm', 'Anke_2afc_neutral'};
        datasetnames = {'RT', '2IFC', 'NatComm', 'Anke neutral'};

    case 'aeurai' % lisa/cartesius
        datasets = {'RT_RDK', 'MEG-PL'};
end

set(groot, 'defaultaxesfontsize', 8, 'defaultaxestitlefontsizemultiplier', 1, ...
    'defaultaxestitlefontweight', 'bold', ...
    'defaultfigurerenderermode', 'manual', 'defaultfigurerenderer', 'painters');

for d = 1:length(datasets),
    results = readtable(sprintf('~/Data/%s/HDDM/summary/allindividualresults.csv', datasets{d}));
    
    % ============================================ %
    % compute repetition parameters from separate HDDM models
    % ============================================ %
    
    results.dc_prevresp__stimcodingdczprevresp = ...
        results.dc_1__stimcodingdczprevresp - results.dc_2__stimcodingdczprevresp;
    
    results.z_prevresp__stimcodingdczprevresp = ...
        results.z_1__stimcodingdczprevresp - results.z_2__stimcodingdczprevresp;
    
    % ============================================ %
    % RENAME PARAMETERS
    % ============================================ %
    
    results.Properties.VariableNames{'dc_prevresp__stimcodingdczprevresp'}      = 'dc_seq_stimcoding';
    results.Properties.VariableNames{'v_prevresp__regressdczprevresp'}          = 'dc_seq_regress';
    results.Properties.VariableNames{'z_prevresp__stimcodingdczprevresp'}       = 'z_seq_stimcoding';
    results.Properties.VariableNames{'z_prevresp__regressdczprevresp'}          = 'z_seq_regress';
    
    % ============================================ %
    % SEPARATE OR JOINT FIT
    % ============================================ %
    
    close;
    corrplot(results, {'dc_seq_stimcoding', ...
        'z_seq_stimcoding', 'dc_seq_regress', ...
        'z_seq_regress'}, ...
        {'repetition'});
    suplabel(sprintf('%s', datasetnames{d}), 't');
    print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/%s_correlation.pdf', datasetnames{d}));
    
    % ============================================ %
    % STIMCODING VS REGRESSION MODELS
%     % ============================================ %
%     
%     close;
%     corrplot(results, {'dc_seq_regress', ...
%         'z_seq_regress'}, ...
%         {'repetition'});
%     suplabel(sprintf('%s, regression', datasetnames{d}), 't');
%     print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/%s_correlation_regress.pdf', datasetnames{d}));
%     
    % ============================================ %
    % STABILITY OF SERIAL CHOICE BIAS
    % ============================================ %
    %
    %     subjects    = unique(results.subjnr(results.session == max(results.session)));
    %
    %     results.repeat_s1 = nan(size(results.p_repeat));
    %     results.repeat_s1(results.session == 0 & ismember(results.subjnr, subjects)) = ...
    %         results.p_repeat(results.session == 1 & ismember(results.subjnr, subjects));
    %     results.repeat_s2 = nan(size(results.p_repeat));
    %     results.repeat_s2(results.session == 0 & ismember(results.subjnr, subjects)) = ...
    %         results.p_repeat(results.session == 2 & ismember(results.subjnr, subjects));
    %
    %     results.criterionshift_s1 = nan(size(results.p_repeat));
    %     results.criterionshift_s1(results.session == 0 & ismember(results.subjnr, subjects)) = ...
    %         results.criterionshift(results.session == 1 & ismember(results.subjnr, subjects));
    %     results.criterionshift_s2 = nan(size(results.p_repeat));
    %     results.criterionshift_s2(results.session == 0 & ismember(results.subjnr, subjects)) = ...
    %         results.criterionshift(results.session == 2 & ismember(results.subjnr, subjects));
    %
    %     close;
    %     corrplot(results, {'repeat_s1', ...
    %         'criterionshift_s1'}, ...
    %         {'repeat_s2', ...
    %         'criterionshift_s2'});
    %     suplabel('Session 1', 'x');
    %     suplabel('Session 2', 'y');
    %     print(gcf, '-dpdf', sprintf('~/Data/%s/HDDM/summary/stability.pdf', datasets{d}));
    %
    %     % ============================================ %
    %     % use separate HDDM fits
    %     % ============================================ %
    %
    %     if d == 2,
    %         results2 	= readtable(sprintf('~/Data/%s/HDDM/summary/allindividualresults_separatesessions.csv', datasets{d}));
    %         results2.dc_seq__stimcoding_prevresp_dc_z = results2.dc_1__stimcoding_prevresp_dc_z - results2.dc_2__stimcoding_prevresp_dc_z;
    %         results2.z_seq__stimcoding_prevresp_dc_z = results2.z_2__stimcoding_prevresp_dc_z - results2.z_1__stimcoding_prevresp_dc_z;
    %
    %         vars        = results2.Properties.VariableNames';
    %         subjects    = unique(results2.subjnr(results2.session == 2));
    %
    %         clf; cnt = 1;
    %         for v = [39 40],
    %             subplot(3,3,cnt); cnt = cnt + 1;
    %             plot(results2.(vars{v})(results2.session == 1 & ismember(results2.subjnr, subjects)), ...
    %                 results2.(vars{v})(results2.session == 2 & ismember(results2.subjnr, subjects)), '.');
    %             axis square; axisNotSoTight; box off;
    %             xlabel(vars{v}(1:end-26), 'interpreter', 'none');
    %             ylabel(vars{v}(1:end-26), 'interpreter', 'none');
    %             [rho, pval] = corr(results2.(vars{v})(results2.session == 1 & ismember(results2.subjnr, subjects)), ...
    %                 results2.(vars{v})(results2.session == 2 & ismember(results2.subjnr, subjects)), 'type', 'spearman', 'rows', 'complete');
    %             if pval < 0.05, lsline; end
    %             title(sprintf('\\rho %.2f p %.3f', rho, pval));
    %         end
    %         suplabel('Session 1, MEG', 'x');
    %         suplabel('Session 2, MEG', 'y');
    %
    %         print(gcf, '-dpdf', sprintf('~/Data/%s/HDDM/summary/stability_HDDM.pdf', datasets{d}));
    %
    %     end
    %
    %     % ============================================ %
    %     % DIC VALUES
    %     % ============================================ %
    %
    %     models = {'regress_dc_prevresp', 'regress_z_prevresp', 'regress_dc_z_prevresp', ...
    %         'regress_dc_prevresp_prevpupil_prevrt', 'regress_z_prevresp_prevpupil_prevrt', ...
    %         'regress_dc_z_prevresp_prevpupil_prevrt'};
    %     alldic = nan(30, length(models));
    %     for m = 1:length(models),
    %         load(sprintf('~/Data/%s/HDDM/summary/%s_all.mat', datasets{d}, models{m}));
    %         alldic(:, m) = (dic);
    %     end
    %     alldic = nanmean(alldic);
    %
    %     close; subplot(221);
    %     bar(alldic(1:3), 'basevalue', nanmean(alldic(1:3)), 'facecolor', linspecer(1));
    %     box off;
    %     ylabel('DIC');
    %     set(gca, 'xticklabel', {'dc', 'z', 'both'});
    %     title('Only previous repsonse');
    %     set(gca, 'YTickLabel', num2str(get(gca, 'YTick')'));
    %     axisNotSoTight;
    %
    %     subplot(222);
    %     bar(alldic(4:6), 'basevalue', nanmean(alldic(4:6)), 'facecolor', linspecer(1));
    %     box off;
    %     ylabel('DIC');
    %     set(gca, 'xticklabel', {'dc', 'z', 'both'});
    %     title('With pupil and RT');
    %     set(gca, 'YTickLabel', num2str(get(gca, 'YTick')'));
    %     axisNotSoTight;
    %     print(gcf, '-dpdf', sprintf('~/Data/%s/HDDM/summary/DICcomparison.pdf', datasets{d}));
    %
    %     % ============================================ %
    %     % ADD RT AND PUPIL IN
    %     % ============================================ %
    %
    %     % RT and pupil
    %     results.Properties.VariableNames{'v_prevpupil_prevresp__regress_dc_prevresp_prevpupil_prevrt'} ...
    %         = 'dc_pupil_seq_regress_joint';
    %     results.Properties.VariableNames{'v_prevrt_prevresp__regress_dc_prevresp_prevpupil_prevrt'} ...
    %         = 'dc_rt_seq_regress_joint';
    %     results.dc_seq_regress   = results.v_prevresp__regress_dc_prevresp_prevpupil_prevrt;
    %
    %     close;
    %     corrplot(results, ...
    %         {'dc_seq_regress'}, ...
    %         {'dc_rt_seq_regress_joint', 'dc_pupil_seq_regress_joint'});
    %     print(gcf, '-dpdf', sprintf('~/Data/%s/HDDM/summary/individualCorr_dc.pdf', datasets{d}));
    %
    %     % USE TRACES FOR STATISTICS
    %     dat = readtable(sprintf('~/Data/%s/HDDM/summary/regress_dc_prevresp_prevpupil_prevrt_all_traces_concat.csv', datasets{d}));
    %
    %     close;
    %     subplot(331);
    %     histogram(dat.v_prevpupil_prevresp, 'displaystyle', 'stairs');
    %     xlabel('Effect of pupil on repetition');
    %     box off;
    %     pval = mean(dat.v_prevpupil_prevresp > 0);
    %     title(sprintf('p = %.3f', pval));
    %     subplot(332);
    %     histogram(dat.v_prevrt_prevresp, 'displaystyle', 'stairs');
    %     xlabel('Effect of RT on repetition');
    %     box off;
    %     pval = mean(dat.v_prevrt_prevresp > 0);
    %     title(sprintf('p = %.3f', pval));
    %     print(gcf, '-dpdf', sprintf('~/Data/%s/HDDM/summary/pupilRT.pdf', datasets{d}));
    %
    %     writetable(results, sprintf('~/Data/%s/HDDM/summary/allindividualresults_recoded.csv', datasets{d}));
    %
    %     % ============================================ %
    %     % ANY DIFFERENCE BETWEEN PHARMA GROUPS?
    %     % ============================================ %
    %
    %     close;
    %     at = strcmp(results.drug, 'atomoxetine');
    %     pl = strcmp(results.drug, 'placebo');
    %     dp = strcmp(results.drug, 'donepezil');
    %
    %     [~, pval] = ttest2(results.dc_seq_regress(at), results.dc_seq_regress(pl))
    %     [~, pval] = ttest2(results.dc_seq_regress(dp), results.dc_seq_regress(pl))
    %
    %     [~, pval] = ttest2(results.dc_rt_seq_regress_joint(at), results.dc_rt_seq_regress_joint(pl))
    %     [~, pval] = ttest2(results.dc_rt_seq_regress_joint(dp), results.dc_rt_seq_regress_joint(pl))
    %
    %     [~, pval] = ttest2(results.dc_pupil_seq_regress_joint(at), results.dc_pupil_seq_regress_joint(pl))
    %     [~, pval] = ttest2(results.dc_pupil_seq_regress_joint(dp), results.dc_pupil_seq_regress_joint(pl))
    
    
end
