function e6_serialBias_SfN_modelFree_CRF_PPC_median
% ========================================== %
% conditional response functions from White & Poldrack
% run on simulated rather than real data
% ========================================== %

addpath(genpath('~/code/Tools'));
warning off; close all; clear;
global datasets datasetnames mypath colors

qntls{1} = [.2, .4, .6, .8, .95]; % White & Poldrack
qntls{2} = [0.1, 0.3, 0.5, 0.7, 0.9]; % Leite & Ratcliff
qntls{3} = [0.3 0.6 0.9];
qntls{4} = [0.5 0.95]; % median split

% redo this for each simulation
models = {'stimcoding_nohist', 'stimcoding_z_prevresp',  ...
    'stimcoding_dc_prevresp', 'stimcoding_dc_z_prevresp' ...
    'data'};
thesecolors = {[0.5 0.5 0.5],  colors(1, :), ...
    colors(2, :), {colors(2, :), colors(1, :)}, [0 0 0]};

fixedEffects = 0;
allcols = colors;

allds.fast  = nan(length(datasets), length(models));
allds.slow = nan(length(datasets), length(models));

for q = 1; %:length(qntls),
    for d = 1:length(datasets),
        
        switch datasets{d}
            case {'Bharath_fMRI', 'Anke_MEG', 'Anke_2afc_sequential', 'Anke_merged'}
                tps = [20 80];
            otherwise
                tps = 0;
        end
        
        % plot
        close all;
        subplot(441); hold on;
        
        for tp = 1:length(tps),
            
            for m = 1:length(models),
                
                switch models{m}
                    case 'data'
                        filename = dir(sprintf('%s/%s/*.csv', mypath, datasets{d}));
                        alldata  = readtable(sprintf('%s/%s/%s', mypath, datasets{d}, filename.name));
                    otherwise
                        if ~exist(sprintf('%s/%s/%s/ppc_data.csv', mypath, datasets{d}, models{m}), 'file'),
                            continue;
                        else
                            fprintf('%s/%s/%s/ppc_data.csv \n', mypath, datasets{d}, models{m});
                        end
                        % load simulated data - make sure this has all the info we need
                        alldata    = readtable(sprintf('%s/%s/%s/ppc_data.csv', mypath, datasets{d}, models{m}));
                        alldata    = sortrows(alldata, {'subj_idx'});
                end
                
                if ~any(ismember(alldata.Properties.VariableNames, 'transitionprob'))
                    alldata.transitionprob = zeros(size(alldata.subj_idx));
                else
                    assert(nanmean(unique(alldata.transitionprob)) == 50, 'rescale units');
                    alldata = alldata(alldata.transitionprob == tps(tp), :);
                end
                
                if m < length(models),
                    % use the simulations rather than the subjects' actual responses
                    alldata.rt          = abs(alldata.rt_sampled);
                    alldata.response    = alldata.response_sampled;
                end
                
                % only correct trials
                alldata = alldata(alldata.stimulus == alldata.response, :);
                
                % when there were multiple levels of evidence, do these plots
                % separately for each level
                if any(ismember(alldata.Properties.VariableNames, 'coherence'))
                    origNsubj = numel(unique(alldata.subj_idx));
                    alldata.subj_idx = findgroups(alldata.subj_idx, alldata.coherence);
                    newNsubj = numel(unique(alldata.subj_idx));
                    if origNsubj ~= newNsubj,
                        fprintf('splitting by coherence, nsubj %d newNsubj %d \n', origNsubj, newNsubj);
                    end
                end
                
                % make sure to use absolute RTs!
                alldata.rt = abs(alldata.rt);
                
                % recode into repeat and alternate for the model
                alldata.repeat = zeros(size(alldata.response));
                alldata.repeat(alldata.response == (alldata.prevresp > 0)) = 1;
                
                % for each observers, compute their bias
                [gr, sjs] = findgroups(alldata.subj_idx);
                sjrep = splitapply(@nanmean, alldata.repeat, gr);
                sjrep = sjs(sjrep < 0.5);
                
                % recode into biased and unbiased choices
                alldata.biased = alldata.repeat;
                altIdx = ismember(alldata.subj_idx, sjrep);
                if tps(tp) == 0,
                    alldata.biased(altIdx) = double(~(alldata.biased(altIdx))); % flip
                end
                
                % fixed effects
                if fixedEffects,
                    alldata.subj_idx = ones(size(alldata.subj_idx));
                end
                
                % get RT quantiles for choices that are in line with or against the bias
                [gr, sjidx, biased] = findgroups(alldata.subj_idx, alldata.biased);
                cpres               = array2table([sjidx, biased], 'variablenames', {'subj_idx', 'biased'});
                cpres.choice        = splitapply(@nanmedian, alldata.rt, gr); % choice proportion
                
                % make into a subjects by rtbin matrix
                mat = unstack(cpres, 'choice', 'biased');
                mat = mat{:, 2:end}; % remove the last one, only has some weird tail
                
                qntls{1} = [0 1];
                % biased choice proportion
                if m < length(models),
                    
                    switch models{m}
                        case 'stimcoding_z_prevresp'
                            %      assert(1==0);
                    end
                    
                    if isnumeric(thesecolors{m})
                        plot(qntls{q}, nanmean(mat, 1), 'color', thesecolors{m}, 'linewidth', 0.5);
                    elseif iscell(thesecolors{m}) % superimposed lines for dashed
                        plot(qntls{q}, nanmean(mat, 1), 'color', thesecolors{m}{1}, 'linewidth', 1.5);
                        plot(qntls{q}, nanmean(mat, 1), ':', 'color', thesecolors{m}{2}, 'linewidth', 1.5);
                    end
                else
                    %% ALSO ADD THE REAL DATA
                    h = ploterr(qntls{q}, nanmean(mat, 1), [], ...
                        1.96 *  nanstd(mat, [], 1) ./ sqrt(size(mat, 1)), 'k', 'abshhxy', 0);
                    set(h(1), 'color', 'k', 'marker', '.', ...
                        'markerfacecolor', 'k', 'markeredgecolor', 'k', 'linewidth', 0.5, 'markersize', 10, ...
                        'linestyle', 'none');
                    set(h(2), 'linewidth', 0.5);
                end
                
                % SAVE
                %                 avg = nanmean(mat, 1);
                %                 allds.fast(d, m) = nanmean(avg(1:2));
                %                 allds.slow(d, m) = nanmean(avg(end-3:end));
                %                 allds.all(d, m, :) = avg;
            end
        end
        
        axis tight; box off;
        set(gca, 'xtick', qntls{q});
        axis square;  offsetAxes;
        set(gca, 'xticklabel', {'alt', 'rep'});
        xlabel('Bias');
        set(gca, 'xcolor', 'k', 'ycolor', 'k');
        ylabel('Reaction time (s)');
        
        if tps(tp) > 0,
            switch tps(tp)
                case 20
                    title([datasetnames{d}{1} ' Alternating']);
                case 50
                    title([datasetnames{d}{1} ' Neutral']);
                case 80
                    title([datasetnames{d}{1} ' Repetitive']);
            end
        else
        end
        
        title(datasetnames{d}{1});
        tightfig;
        set(gca, 'xcolor', 'k', 'ycolor', 'k');
        
        if fixedEffects,
            print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/CRF_PPC_d%d_median_fixed.pdf', d));
        else
            print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/CRF_PPC_d%d_median.pdf', d));
        end
        fprintf('~/Data/serialHDDM/CRF_PPC_d%d_median.pdf \n', d);
    end
    
end
end
