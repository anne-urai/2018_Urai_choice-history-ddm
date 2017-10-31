function sv_comparison()

addpath(genpath('~/code/Tools'));
warning off; close all;
global datasets datasetnames mypath

for d = 1:length(datasets),
    
    % check that sv is smaller for models that include history
    traces_nohist = readtable(sprintf('%s/%s/stimcoding_nohist/group_traces.csv', mypath, datasets{d}));
    traces_withhist = readtable(sprintf('%s/%s/stimcoding_dc_z_prevresp/group_traces.csv', mypath, datasets{d}));
    
    % color in different grouos
    colors = cbrewer('seq', 'Greens', 5);
    
    close all;
    subplot(4,4,1); hold on;
    h2 = histogram_smooth(traces_nohist.sv, [0 0 0]);
    h1 = histogram_smooth(traces_withhist.sv, colors(end, :));
    
    % show if these are significant - two sided
    % https://github.com/jwdegee/2017_eLife/blob/master/hddm_regression.py, line 273
    
    axis tight; axis square;
    xlims = get(gca, 'xlim');
    xlim([xlims(1) xlims(2)*1.2]);
    set(gca, 'xtick', [0 max(get(gca, 'xtick'))]);
    offsetAxes_y;
    title(datasetnames{d}{1});
    tightfig;
    print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/sv_comparison_d%d.pdf', d));

end

end

function h = histogram_smooth(x, color2)

[f,xi] = ksdensity(x);
a1 = area(f, xi, 'edgecolor', 'none', 'facecolor', ...
    color2, 'facealpha', 0.4, 'showbaseline', 'off');

% % Make area transparent
% drawnow; % pause(0.05);  % This needs to be done for transparency to work
% a1.Face.ColorType = 'truecoloralpha';
% a1.Face.ColorData(4) = 255 * 0.3; % Your alpha value is the 0.3

% area
h = plot(f, xi, 'color', color2, 'linewidth', 1);
set(gca, 'color', 'none');

end

function offsetAxes_y()

if ~exist('ax', 'var'), ax = gca;
end
if ~exist('offset', 'var'), offset = 4;
end

% ax.YLim(1) = ax.YLim(1)-(ax.YTick(2)-ax.YTick(1))/offset;
ax.YLim(2) = ax.YLim(2)+(ax.YTick(2)-ax.YTick(1))/offset;

% this will keep the changes constant even when resizing axes
addlistener(ax, 'MarkedClean', @(obj,event)resetVertex(ax));
end

function resetVertex ( ax )
% repeat for Y (set 2nd row)
ax.YRuler.Axle.VertexData(2,1) = min(get(ax, 'Ytick'));
ax.YRuler.Axle.VertexData(2,2) = max(get(ax, 'Ytick'));
% X, Y and Z row of the start and end of the individual axle.
ax.XRuler.Axle.VertexData(1,1) = min(get(ax, 'Xtick'));
ax.XRuler.Axle.VertexData(1,2) = max(get(ax, 'Xtick'));
end