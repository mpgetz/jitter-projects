% Modified code with discretized train and restricted synch def
% Code to make Figure 1 for Basic-Interval Jitter paper
% Generates Poisson spike trains and compares p-value distributions
% for interval vs. basic (spike-centered) jitter, using a synchrony
% statistic
 

function []=jitt_demo

    frate1 = 40; % neuron 1 firing in Hz
    frate2 = 40; % neuron 2 firing in Hz
    T = 1;  % end time in seconds
    %these variables unused in 0-lag synch def
    synch_def=.001;   % spikes x,y synchronous if |x-y|<synch_def in secs
    synch_range=[0 1]; % only count synch in this range (ie all synch spikes in neuron 1 \in synch_range)

    num_jitter = 1000;
    num_runs = 5000;
    jitter_width = 0.02;
    u = rand(num_runs,1);


    %%%%%%%
    %jit_times = 0:.001:(2*jitter_width);
    disc = .001;
    times = 0:.001:(T-disc);

%    frate1 = round(frate1*T);
%    frate2 = round(frate2*T);
    
    clear pval pvalr pval_int pvalr_int
    for ccc=1:num_runs

        n1 = randsample(times, frate1);
        n2 = randsample(times, frate2);
        %orig_syn=0; 

        % sample Poisson by sampling exponential ISI's
        % neuron 1
        %n1 = (rand(1, length(times)) <= disc*frate1);
        %n1 = find(n1).*disc;
        %display(n1);
        %input('');

        %n1 = n1(n1<=(T-(2*jitter_width)));
        %n1 = n1((2*jitter_width)<=n1);
        %n1 = unique(n1(n1<=(1-jitter_width)));
        %n1 = unique(round(n1(1:end-1), 3));

        % neuron 2
        %n2 = (rand(1, length(times)) <= disc*frate1);
        %n2 = find(n2).*disc;

        %n2 = n2(n2<=(T-(2*jitter_width)));
        %n2 = n2((2*jitter_width)<=n2);
        %n2 = unique(round(n2(1:end-1), 3));
        %display(n1);
        %display(n2);
        %input('');

        
        % compute initial synchrony
        orig_syn = synch_compute( n1,n2,synch_def,synch_range );
        orig_synb = orig_syn + (rand(1)-.5);   % randomized synchrony

        % [basic] jitter, and tabulate synchrony counts
        % set jitter sample set
        %sample = (-jitter_width):disc:(jitter_width);

        syn_surr= zeros(1, length(num_jitter)); 
        syn_surrb=zeros(1, length(num_jitter));
        n2_jitt = n2;
        l1 = length(n1);
        for k=1:num_jitter

            % jitter spikes, lazy (allows coincident spikes in same train)
            %n1_jitt = n1 + round(2*jitter_width*(rand(1,length(n1))), 3)-jitter_width;
            %n1_jitt = round(n1_jitt, 3);

            %slower, but avoids spike overlap
            n1_jitt = n1;
            e = 1;
            while e < l1
                jit = round(2*jitter_width*rand(), 3) - jitter_width;
                %jit = randsample(sample, 1);
                if sum(n1_jitt==n1(e) + jit) == 0
                    n1_jitt(e) = n1(e) + jit;
                    e = e + 1;
                end
            end
            %display(length(unique(n1_jitt))==length(n1));
    
            % compute synchrony
            s=synch_compute( n1_jitt,n2_jitt,synch_def,synch_range );

            syn_surr(k) = s;
            syn_surrb(k) = s+.5*rand(1);   % store synchrony for surrogate j

        end

        % [interval] jitter, and tabulate synchrony counts
        sample = 0:disc:((2*jitter_width)-disc);

        syn_surr_int = zeros(1, length(num_jitter)); 
        syn_surrb_int = zeros(1, length(num_jitter));
        n2_jitt = n2;

        for k=1:num_jitter

            % interval jitter (interval length jitter_width*2) spikes for n1
            %this could technically enter an infinite loop

            win = jitter_width*2;
            while true
                %for i=1:length(n1)
                %end
                %n1_jitt_int = (win)*floor(n1/(win)) + (win)*rand(1,length(n1));
                %n1_jitt_int = round(n1_jitt_int, 3);
                n1_jitt_int = (win)*floor(n1/(win)) + datasample(sample, length(n1));
                %display(n1);
                %display(n1_jitt_int);
                %input('');
                if length(unique(n1_jitt_int)) == length(n1)
                    break
                end
            end

            %n1_jitt_int = sort(win*floor(n1/win));
            %vals = floor(n1/win);
            %index = 1;

            %for i=0:(win/disc-1)
            %    ct = sum(vals==i);
            %    n1_jitt_int(index:index+ct-1) = n1_jitt_int(index:index+ct-1) + randsample(sample, ct);
            %    index = index + ct;
            %end

            %max( n1-n1_jitt )
            %display(n1_jitt_int);

            % compute synchrony
            s = synch_compute( n1_jitt_int,n2_jitt,synch_def,synch_range );

            syn_surr_int(k) = s;
            syn_surrb_int(k) = s + (rand(1)-.5);   % store synchrony for surrogate j
            %syn_surrb_int(k) = s + .5*rand(1);   % store synchrony for surrogate j

        end
            
        % compute pvalues
        % pval for basic jitter test
        pval(ccc)=(1+sum( syn_surr>=orig_syn))/(num_jitter+1);
        % pval for randomized basic jitter test
        pvalr(ccc)=(1+sum( syn_surrb>=orig_synb))/(num_jitter+1);
        % pval for interval jitter test
        pval_int(ccc)=(1+sum( syn_surr_int>=orig_syn))/(num_jitter+1);
        % pval for randomized interval jitter test
        pvalr_int(ccc)=(1+sum( syn_surrb_int>=orig_synb))/(num_jitter+1);


        if mod(ccc,10)==0
            orig_syn,ccc
            binw=.02;
            subplot(3,2,1)
            hold off, histogram(pval,0:binw:1,'Normalization','probability'), title('Raw basic pvals'), 
            %axis([0, 1, 0, .04])
            hold on, plot(0:.01:1,binw*ones( size(0:.01:1)),'r-.')  % draw line
            subplot(3,2,3)
            hold off, histogram(pvalr,0:binw:1,'Normalization','probability'), title('Randomized basic pvals')
            hold on, plot(0:.005:1,binw*ones( size(0:.005:1)),'r-.')  % draw line
            subplot(3,2,2)
            hold off, histogram(pval_int,0:binw:1,'Normalization','probability'), title('Raw interval pvals')
            %axis([0, 1, 0, .04])
            hold on, plot(0:.005:1,binw*ones( size(0:.005:1)),'r-.')  % draw line
            subplot(3,2,4)
            hold off, histogram(pvalr_int,0:binw:1,'Normalization','probability'), title('Randomized interval pvals')
            hold on, plot(0:.005:1,binw*ones( size(0:.005:1)),'r-.')  % draw line
           
            subplot(3,2,5)
            hold off, histogram(u(1:ccc),0:binw:1,'Normalization','probability'), title('Uniform')
            hold on, plot(0:.005:1,binw*ones( size(0:.005:1)),'r-.')  % draw line
            pause(.01)
            
        end
                    
    end
end

%nb=20;
%subplot(2,1,1)
%hist(pval,nb), title('Raw pvals')
%subplot(2,1,2)
%hist(pvalr,nb), title('Randomized pvals')

function synch = synch_compute(n1,n2,synch_def,synch_range);
	synch = 0;
    len = length(n2);
	for s=1:len
		synch = synch + sum(n1==n2(s));
	end
%    display(n2);
%    display(n1);
%    display(synch);
%    input('enter')
end

