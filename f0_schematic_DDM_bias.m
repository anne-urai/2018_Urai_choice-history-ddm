function f0_schematic_DDM_bias

close all;
set(groot, 'defaultaxesfontsize', 7, 'defaultaxestitlefontsizemultiplier', 1, ...
    'defaultaxestitlefontweight', 'normal', ...
    'defaultfigurerenderermode', 'manual', 'defaultfigurerenderer', 'painters', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.05], 'defaultaxestickdir', 'out', 'DefaultAxesTickDirMode', 'manual', ...
    'defaultfigurecolormap', [1 1 1], 'defaultTextInterpreter','tex');

%% set parameters
cfg.timestep = 0.01; % 100 ms
cfg.time     = 0:cfg.timestep:1; % in seconds
cfg.a        = 1; % bound with, z = 0
cfg.cdW      = 0.1; % variance of normally distributed noise
cfg.v        = 1.25*cfg.timestep; % drift rate per timestep
cfg.z        = 0; % drift rate per timestep
cfg.seed     = 8;

%% make an overview of the two biasing mechanisms in the DDM

subplot(441); hold on;
arrow([cfg.time(1) cfg.z ], [cfg.time(end) cfg.z], 'linewidth', 0.5, 'color', 'k', 'length', 5);
y = ddm(cfg);
plot(cfg.time, y);

% show the unbiased average drift towards two stimuli
cfg.cdW = 0;
y = ddm(cfg);
plot(cfg.time, y,'k');
cfg.v = -cfg.v; % flip around drift rate
y = ddm(cfg);
plot(cfg.time, y,'k');

% now with drift criterion bias
cfg.dc = 0.3*cfg.timestep;
cfg.v = cfg.v+cfg.dc;
y = ddm(cfg);
plot(cfg.time, y, 'color', [0.5 0.5 0.5]);
cfg.v = -cfg.v + 2*cfg.dc; % flip around drift rate
y = ddm(cfg);
plot(cfg.time, y,'k', 'color', [0.5 0.5 0.5]);

%%  layout
ylim([-cfg.a cfg.a]);
set(gca, 'ytick', [-cfg.a cfg.z cfg.a], 'yticklabel', {'0', 'z', 'a'});
text(0.83, -0.2, 'Time', 'fontsize', 6);
title('Biased drift');
plot([cfg.time(1) cfg.time(end)], [cfg.a cfg.a], 'k', 'linewidth', 0.5);
box off; set(gca, 'xticklabel', [], 'xtick', []);


%% now change in starting point

cfg.timestep = 0.01; % 100 ms
cfg.time     = 0:cfg.timestep:1; % in seconds
cfg.a        = 1; % bound with, z = 0
cfg.cdW      = 0.1; % variance of normally distributed noise
cfg.v        = 1.25*cfg.timestep; % drift rate per timestep
cfg.z        = 0; % drift rate per timestep
cfg.seed     = 8;

subplot(442); hold on;
arrow([cfg.time(1) cfg.z ], [cfg.time(end) cfg.z], 'linewidth', 0.5, 'color', 'k', 'length', 5);
y = ddm(cfg);
plot(cfg.time, y);

% show the unbiased average drift towards two stimuli
cfg.cdW = 0;
y = ddm(cfg);
plot(cfg.time, y,'k');
cfg.v = -cfg.v; % flip around drift rate
y = ddm(cfg);
plot(cfg.time, y,'k');

% now with drift criterion bias
cfg.z = 0.1;
y = ddm(cfg);
plot(cfg.time, y, 'color', [0.5 0.5 0.5]);
cfg.v = -cfg.v;
y = ddm(cfg);
plot(cfg.time, y,'k', 'color', [0.5 0.5 0.5]);

% layout
ylim([-cfg.a cfg.a]);
set(gca, 'ytick', [-cfg.a 0 cfg.a], 'yticklabel', {'0', 'z', 'a'});
text(0.83, -0.2, 'Time', 'fontsize', 6);
title('Biased starting point');
set(gca, 'xticklabel', [], 'xtick', []);
plot([cfg.time(1) cfg.time(end)], [cfg.a cfg.a], 'k', 'linewidth', 0.5);
box off;

%% now add the equations!

subplot(445);
xoffset = 0.02;
text(xoffset,1.15, '$$ dy = (sv + \mathbf{dc})dt + cdW$$ ' , 'interpreter', 'latex', 'fontsize', 8);
text(xoffset,1, '$$y(0) = 0$$ ' , 'interpreter', 'latex', 'fontsize', 8);
axis off;

subplot(446);
text(xoffset,1.15, '$$ dy = svdt + cdW$$ ' , 'interpreter', 'latex', 'fontsize', 8);
text(xoffset,1, '$$y(0) = \mathbf{z}$$ ' , 'interpreter', 'latex', 'fontsize', 8);
axis off;

%% save
% offsetAxes;
tightfig;
print(gcf, '-depsc', sprintf('~/Data/serialHDDM/DDMschematic.eps'));


end


function y = ddm(cfg)

% generate a sample of evidence for each moment in time
evidence = cfg.v * ones(size(cfg.time));

% add noise
rng(cfg.seed); % make sure this is the same each time
noise = randn(size(evidence)) .* cfg.cdW;
noise(1) = cfg.z; % start with no noise
noisyevidence = evidence + noise;

integratedevidence = cumsum(noisyevidence);
y = integratedevidence;

end