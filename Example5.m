%{
Example 5 adaptation, Stark and Abeles 
One spike train and an external oscillating field,
piece-wise discretized. Train fires M=m spikes with P(m)=1.
Assume fixed trial length of 1s=1000ms
%}

T = 1000;%total trial duration, msec
trials = 500;
num_jitter_trials = 500;
ups = ones(1,trials);
dns = ones(1,trials);
prefs = zeros(1,trials);

%Randomly select total number of spikes leq 100
%m = round(rand()*(10^(ceil(rand()*2))));
m = round(rand()*10);

for runs=1:trials
    train = round(rand(1, m), 3);
    %Replace any duplications in train to fire exactly m spikes
    test_train = unique(train);
    l = length(test_train);

    while l < m
        nt = round(rand(1, m-l), 3);
        test_train = unique([test_train, nt]);
        l = length(test_train);
    end
    %adjust times to integer values
    train = test_train.*T;
    dur = length(train);
    %store initial statistic for ref
    pref = phase_stat(train);
    %store prefs for numerical prob(alpha) computation
    prefs(1,trials) = pref/l;

    %Perform basic jitter
    j_width = 1;
    jit_stats = zeros(1, num_jitter_trials);

    for t=1:num_jitter_trials
        jit = double(rand(1,dur));
        jit(jit>=(2/3)) = 1;
        jit(jit<(1/3)) = -1;
        jit(abs(jit)~=1) = 0;
        jit_stats(1,t) = phase_stat(train+jit);
    end

    %may analytically compute probability of observing perfect phase locking:
    %prob = nchoosek(floor(T/2),m)/nchoosek(T,m);
    %display(prob);

    %calculate p-value
    up = (1+sum(pref>=jit_stats))/(1+num_jitter_trials);
    dn = (1+sum(pref<=jit_stats))/(1+num_jitter_trials);
    %display(up);
    %display(dn);
    ups(runs) = up;
    dns(runs) = dn;
end    

    %compute hallucination in both up and down phases
    alpha = (1/3)^m;
    probn = sum(prefs==1)/length(prefs);
    p_alphau = sum(ups<=alpha)/length(ups);
    p_alphad = sum(dns<=alpha)/length(dns);
    ku = p_alphau/probn;
    kd = p_alphad/probn;


