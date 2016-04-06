% Assorted exploratory methods which do not yet serve a more general purpose
% Largely used as a record of command-line work
%tm = TrainMethods;

% extract msec synch spikes from refcell wrt tcell
refcell = cell{5};
tcell = cell{8};
c8 = zeros(1, length(refcell));

for i=1:length(refcell)
    if ~isempty(find(refcell(i)+.00015>=tcell & tcell>=refcell(i)))
        c8(i) = refcell(i);
    end
end

%remove hanging zeros
c8p = find(c8);
c8 = c8(c8p);

% plot group of msec cchs given by column pairs in var objs
%objs = [8, 12; 8, 11; 5, 12; 8, 9; 8, 13; 9, 13; 4, 12; 6, 10];
%for j=1:8
%    subplot(4, 2, (j))
%    tm.cch(cell{objs(j, 1)}, cell{objs(j, 2)}, .00003, 1, 20);
%    title(strcat(int2str(ns(objs(j, 1))), '-->', int2str(ns(objs(j, 2)))));
%end

%% plot group of cchs
%figure
%k = 1;
%for i=6:10
%%for i=1:(length(cell)-1)
%    for j=11:13
%    %for j=(i+1):length(cell)
%        subplot(3, 5, (k))
%        %subplot(3, 5, (k))
%        tm.cch(cell{i}, cell{j}, .001, 1, 10);
%        title(strcat(int2str(ns(i)), '-->', int2str(ns(j))));
%        k = k+1;
%        i,j
%    end
%end

% compute direction of movement wrt x-axis
angles8 = zeros(1, length(c8p));
for elem=1:length(c8p)
    s = c8p(elem);
    x8 = spike.x(s+1)-spike.x(s-1);
    y8 = spike.y(s+1)-spike.y(s-1);
    [theta, rho] = cart2pol(x8, y8);
    angles8(elem) = theta;
end

