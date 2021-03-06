%%
% Repeat Example5 situation but with Poisson train and phase matched to frate Hz sine wave
% (+1 if [0, pi), -1 if [-pi, 2*pi)
% msec discretization
T = 1000;%sec
trials = 10000;
num_jitter_trials = 10000;
ups1 = zeros(1,trials);
dns1 = zeros(1,trials);
prefs = zeros(1, trials);
lengths = zeros(1, trials);
probs1 = zeros(1, trials);
probstu = zeros(1, trials);
probstd = zeros(1, trials);

win = 0.006; %1/2 jitter window width
bins = 0:.001:(T-.001); 
interval = 0:.001:(2*win)-.001;

% neuron data
%frate = 5;
m = 20;

% phase data
freq = 120; 

%how to compute a numerical alpha?
for runs=1:trials
    %{
    ISI_avg=1/frate;  % ISI mean rate
    %n1 = exprnd(ISI_avg);
    n1 = round(exprnd(ISI_avg), 3);
    while n1(end) < T, 
        n1(end+1) = n1(end) + round(exprnd(ISI_avg), 3); 
    end; 
    n1 = n1(n1<=(1-win));
    %}

    %choose exactly m spikes from msec bins:
    n1 = randsample(bins, m);
    dur1 = m;

    pref = rphase_stat(n1, freq);
%    display(pref);
    jit_stats1 = zeros(1,num_jitter_trials);

    % perform basic jitter
    for t=1:num_jitter_trials
        jit = n1 + ((datasample(interval ,dur1))-win);

        %jit_stats1(1,t) = rphase_stat(jit, freq);
        jit_stats1(1,t) = sum(sin(freq*2*pi*jit)>0);

    end
    
    %calculate p-value
    up1 = (1+sum(jit_stats1>=pref))/(1+num_jitter_trials);
    dn1 = (1+sum(pref>=jit_stats1))/(1+num_jitter_trials);
    %display(up);
    %display(dn);
    ups1(1,runs) = up1;
    dns1(1,runs) = dn1;

    if mod(runs, 100) == 0
        display(runs);
        display(pref);
    end

end

%compute hallucination %%NOTE: THIS WAS PREVIOUSLY COMPUTED ON THE COMMAND LINE
%probstu(1,runs) = sum((pref/dur1)==1);
%probstd(1,runs) = sum((pref/dur1)==0);
%probs1(1,runs) = sum((prefs./lengths)==1)/trials;
alpha = 0.0001;
pdist = (ups1<=alpha);
k = (sum(pdist)/length(ups1))/alpha;
pDdist = (dns1<=alpha);
kD = (sum(pDdist)/length(dns1))/alpha;
