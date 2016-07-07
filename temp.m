% Assorted exploratory methods which do not yet serve a more general purpose
% Largely used as a record of command-line work
%tm = TrainMethods;

%%compute all across-shank synch pairs
%inq = [];
%for i=1:7
%    set1 = unique(clus{i});
%    set2 = unique(clus{i+1});
%    %trim off '0' cluster (usually artifact)
%    set1 = set1(find(set1));
%    set2 = set2(find(set2));
%
%    for j=1:length(set1)
%        for k = 1:length(set2)
%            %synch = [];
%            %t1 = fets{i}(find(clus{i}==set1(j)));
%            %t2 = fets{i+1}(find(clus{i+1}==set2(k)));
%            %synch = tm.find_synch(t1, t2, -.0005, .0005);
%            %inq = [inq; length(synch)/length(t1), i, j, i+1, k];
%            inq = [inq; 0, i, j, i+1, k];
%        end
%    end
%end
%
%%loop over all synch pairs and consider only those which
%% have at least one event in each of 10 bins at .5msec increments
%
%candidates = [];
%edges = [-.00375:.0005:.00375];
%
%for i = 1:length(inq)
%    fet1 = fets{inq(i, 2)};
%    fet2 = fets{inq(i, 4)};
%    t1 = fet1(find(clus{inq(i, 2)}==inq(i, 3)));
%    t2 = fet2(find(clus{inq(i, 4)}==inq(i, 5)));
%
%    %check for excess size and sample if >10000
%    if length(t1)>5000
%    	t1 = randsample(t1, 5000);
%    end
%    if length(t2)>5000
%    	t2 = randsample(t2, 5000);
%    end
%
%    %compute hist values and reject any with 0 in a bin
%    diff = repmat(t1', length(t2), 1) - repmat(t2, 1, length(t1));
%    counts = histcounts(diff, edges);
%    if length(find(counts)) == length(edges)-1
%    	 candidates = [candidates; inq(i, :)];
%    end
%
%    %figure;
%    %bar(counts);
%end
%
%figure;
%tm.cch(t1, t2, .001, 0);


for i = 1:length(candidates)
    subplot(3, 5, i);
    fet1 = fets{candidates(i, 2)};
    fet2 = fets{candidates(i, 4)};
    t1 = fet1(find(clus{candidates(i, 2)}==candidates(i, 3)));
    t2 = fet2(find(clus{candidates(i, 4)}==candidates(i, 5)));

    if length(t1)>5000
    	t1 = randsample(t1, 5000);
    end
    if length(t2)>5000
    	t2 = randsample(t2, 5000);
    end

    tm.cch(t1, t2, .00005, 15);
end



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


