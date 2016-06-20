% Assorted exploratory methods which do not yet serve a more general purpose
% Largely used as a record of command-line work
%tm = TrainMethods;

for i=1:length(wv)
    candidate = wv(i);
    template = repmat(candidate, 1, 1, 54);

    for j=26:54
        %m is avg waveform of particular neuron
        if j < 27
            ref = [m(:, 27-j:end), zeros(8, 54-j)]     
        else
            ref = [zeros(8, j-27), m(:, 1:54-(j-27))]     
        end
        pt.plot_wvs(ref)
        pause(5);
        close

        %template(:, :, j) = template(:, :, j) - ref;
    end

    %find subtraction which minimizes the variance
end

%% extract msec synch spikes from refcell wrt tcell
%refcell = cell1{3};
%tcell = cell2{1};
%synch = zeros(1, length(refcell));
%
%for i=1:length(refcell)
%    if ~isempty(find(refcell(i)>=tcell & tcell>=refcell(i)-.00015))
%    %if ~isempty(find(refcell(i)+.00015>=tcell & tcell>=refcell(i)))
%        synch(i) = refcell(i);
%    end
%end
%
% remove hanging zeros
%synchp = find(synch);
%synch = synch(synchp);

% compared synchronous events for two different neuron pairs
%%count = 0; 
%l1 = []; l2 = [];
%for i=1:649; 
%    %count = count + sum(abs(synch-synch811(i))<1); 
%    if sum(abs(synch-synch811(i))<1) > 0
%        l1 = [l1, synch(find(abs(synch-synch811(i))<1))];
%        l2 = [l2, synch811(i)];
%    end 
%end;

% computes position of synch from above relative to entire time series
%n = zeros(1, length(spike.t));
%for i=1:length(synch); 
%    k = find((spike.t/32552)==synch(i)); 
%    n(k(1)) = synch(i); 
%end;
%n = find(n);

%% the code below plots the spikes assigned to n on a map of the position
%x = spike.x(n);

%figure
%plot(spike.x, spike.y);
%line([x, x], [.2, .25], 'Color', 'r');

% plot group of msec cchs given by column pairs in var objs
%objs = [3, 1];
%for j=1:1
%    subplot(1, 1, (j))
%    tm.cch(cell1{objs(j, 1)}, cell2{objs(j, 2)}, .00003, 1, 20);
%    title(strcat('n11 shank', int2str(ns1(objs(j, 1))), '-->', 'n34 shank', int2str(ns2(objs(j, 2)))));
%    xlabel('.03ms bin');
%end

%% plot group of cchs
%figure
%k = 1;
%for i=1:4
%%for i=1:(length(cell)-1)
%    for j=1:1
%    %for j=(i+1):length(cell)
%        subplot(1, 4, (k))
%        tm.cch(cell1{i}, cell2{j}, .001, 1, 10);
%        title(strcat('n11 shank', int2str(ns1(i)), '-->', 'n34 shank', int2str(ns2(j))));
%        k = k+1;
%        i,j
%    end
%end

%% compute direction of movement wrt x-axis
%angles8 = zeros(1, length(n));
%for elem=1:length(n)
%    s = n(elem);
%    x8 = spike.x(s+1)-spike.x(s-1);
%    y8 = spike.y(s+1)-spike.y(s-1);
%    [theta, rho] = cart2pol(x8, y8);
%    angles8(elem) = theta;
%end

%%t = all interneurons
%%train_labels = label for interneurons
%tf = []; 
%% returns position of interneuron spikes wrt entire train
%for i=1:13 
%    tf = [tf, find(spike.cluster==train_labels(i))']; 
%end
%tf = sort(tf);
%t = spike.t(tf)/32552;

%t_s = spike.t/32552;
%trate = zeros(size(spike.t));
%i = 0;
%bin = .01;
%
%while i<=max(t_s)
%    k = histcounts(t_s, [i, i+bin])/bin;
%    trate(find(t_s >= i & t_s < i+bin)) = k;
%    i = i + bin;
%end

%avg = (length(t)/range(t));
%visualize rates
%plot(r); hold on;
%plot(0:10:length(r), avg*ones(size(0:10:length(r))),'r-.');
