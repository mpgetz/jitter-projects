classdef WaveformMethods
    %Collection of methods for waveform analysis and manipulation
    %Properties serve to cache data which is reused through repeated
    % calls to a particular method.

    properties
        templates = [];
        coeffs = {};
        clu_data = [];
        clu_set = [];
    end

    methods
        function self = WaveformMethods(wvs, clus, shank)
            %class init function

            self.templates = self.get_template_wvs(wvs, clus, shank);
            [self.coeffs, self.clu_data] = self.get_fets(wvs{shank}, clus{shank});
            %FOR NOW, clus MUST BE A CELL
            if ~iscell(clus)
                self.clu_set = unique(clus); 
            else
                self.clu_set = unique(clus{shank}); 
            end
        end

        function [ex, lag, clu1, clu2] = build_example(self, wvs, clus, shank)
            %builds an example of random overlapping waveforms from data
            % by selecting two existing waveforms from wvs and summing them
            % with lag
            %Output: ex is example wv.
            %   lag is the randomly chosen offset 
            %   clu1, clu2 give chosen clusters, for reference

            clu_set = unique(clus{shank});
            clu_set = clu_set(find(clu_set ~= 0 & clu_set ~= 1));

            lag = randsample([-15:1:15], 1);
            clu1 = randsample(clu_set, 1);
            clu2 = randsample(clu_set, 1);

            %insures refractory period is not violated
            while clu1==clu2
                clu2 = randsample(clu_set);
            end
            
            wv1 = wvs{shank}(:, :, randsample(find(clus{shank}==clu1), 1));
            wv2 = wvs{shank}(:, :, randsample(find(clus{shank}==clu2), 1));
            if lag >= 0
                ex = wv1 + [wv2(:, (54-lag)+1:end), wv2(:, 1:54-lag)];
            else
                ex = wv1 + [wv2(:, (54+lag)+1:end), wv2(:, 1:54+lag)];
            end
        end

        %PROBABLY USELESS
        function [ref_wvs] = get_ref_wvs(self)
            %helper function to find wv templates to subtract

            %find channel of max neg deflection
            channel = find(min(min(wv, [], 2)));
            ref_wvs = self.wv_mins(find(wv_mins(2, :) == channel));
        end

        function [coeffs, clu_data] = get_fets(self, wvs, clus)
            %re-computes pca on waveset and stores top 3 coeff vectors for
            %eg. use with waveform subtraction, below
            %wvs, clus expect 3-dimensional arrays
            
            %collect all waveforms from each channel & do pca
            samples = 54;
            u_clus = unique(clus);
            %u_clus = u_clus(find(u_clus ~= 0 & u_clus ~= 1));

            for i=1:8
                vec{i} = reshape(wvs(i, :, :), samples, [])';
                coeffs{i} = pca(vec{i});

                for j=1:length(u_clus)
                    clu = find(clus == u_clus(j));
                    fets = vec{i}(clu, :)*coeffs{i}(:, 1:10);
                    clu_data{j}(i, :, 1) = [mean(fets)];                
                    clu_data{j}(i, :, 2) = [std(fets)];                
                end
            end
        end

        function [pc1, pc2, cand] = get_pcs(self, wvs, clus, shank, clu1, clu2, candidate)
            %As of now, a prep function for pca_ui input
            %candidate is (presumably) a candidate waveform for comparison
            % with existing clusters

            samples = 54;
            coeffs = self.coeffs;

            cs1 = wvs{shank}(:, :, find(clus{shank}==clu1));
            cs2 = wvs{shank}(:, :, find(clus{shank}==clu2));

            pc1 = zeros(8, 3, length(cs1));
            pc2 = zeros(8, 3, length(cs2));
            cand = zeros(8, 3);

            for i=1:8
                fets1 = reshape(cs1(i, :, :), 54, [])'*coeffs{i}(:, 1:3);
                fets2 = reshape(cs2(i, :, :), 54, [])'*coeffs{i}(:, 1:3);
                fetsc = candidate(i, :)*coeffs{i}(:, 1:3);
                
                pc1(i, :, :) = reshape(fets1, 1, 3, []);
                pc2(i, :, :) = reshape(fets2, 1, 3, []);
                cand(i, :) = fetsc;
            end

            pc1 = reshape(pc1, 24, []);
            pc2 = reshape(pc2, 24, []);
            cand = reshape(cand, 24, []);
        end

        function [templates] = get_template_wvs(self, wvs, clus, shank)
            %Creates template waveforms for each cluster on a specific shank
	        %expects cells for wvs and clus. may make more flexible later
            %expects int for shank

            if nargin < 4
                j = 1;
                k = length(wvs);
            else
                j = shank;
                k = shank;
            end

            for i=j:k
                %compute template waves
                clu_set = unique(clus{i});
                %remove '0' and '1' clusters
                clu_set = clu_set(find(clu_set ~= 0 & clu_set ~= 1));

                avg = [];
                avgs = [];
                for j=1:length(clu_set)
                    avg = mean(wvs{i}(:, :, find(clus{i}==clu_set(j))), 3);
                    avgs = [avgs, avg];
                end
                templates = reshape(avgs, 8, 54, []);
                %sort template waves 

                %for wv=1:size(wvs{i}, 3)
                %    if isempty(find(max(wvs{i}(:, :, wv))>200))
                %        candidates = [candidates, wvs{i}(:, :, wv)];
                %    end
                %end
                %examples{i} = candidates;
            end
        end

        function [candidates, sub_temps] = do_subtraction(self, shell, templates)
            %runs subtraction for particular shell waveform (usu. noise)
            %sub_temps returns position of particular templates used
            %(used in resolve_synch to ID clu of interest)
            %assumes templates is 8x54x[] %%NEED TO GENERALIZE

            %THIS IS A HACK
            sub_temps = [1:size(templates, 3)];

            candidates = {};

            for i=1:length(sub_temps)
                stack = repmat(shell, 1, 1, 54);

                for j=0:53
                    m = templates(:, :, sub_temps(i));

                    if j < 27
                        ref = [m(:, 27-j:end), zeros(8, 27-j-1)];     
                    else
                        ref = [zeros(8, (j+1)-27), m(:, 1:54-((j+1)-27))];     
                    end

                    wv = stack(:, :, j+1) - ref;

                    %recenter remaining waveform on max neg. deflection
                    col = min(wv, [], 2);
                    row = find(min(col)==col);
                    peak = find(wv(row, :)==min(col));
                    diff = 27 - peak(1);
                    %TO DO: change 54 to generic 'samples'
                    if diff >= 0
                        wv = [zeros(8, diff), wv(:, 1:54-diff)];
                    else
                        wv = [wv(:, abs(diff):end), zeros(8, abs(diff)-1)];
                    end
                    stack(:, :, j+1) = wv;
                end
                candidates{i} = stack;
            end
        end

        function [clu] = get_clu(self, wv, wvs, clus, shank)
            %recomputes cluster value for given waveform based
            % on local pca
            %note: largely for verification

            [coeffs, clu_data] = self.get_fets(wvs{shank}, clus{shank});
            templates = self.get_template_wvs(wvs, clus, shank);

            cand_fets = zeros(8, 10);

            %loop over all channels
            for j=1:8
                %convert candidate wvfms into pca space, with 10 pc's
                test_fets = wv(j, :)*coeffs{j}(:, 1:10);
                cand_fets(j, :) = [test_fets];
            end

            p = zeros(length(clu_data), 1);

            for k=1:length(clu_data)
                m = clu_data{k}(:, :, 1);
                s = clu_data{k}(:, :, 2);
                p(k) = sum(sum(sum(abs(m - cand_fets)./s)));
            end

            clu_set = unique(clus{shank});
            clu_set = clu_set(find(clu_set ~= 0 & clu_set ~= 1));
            display(p)
            loc = find(p == min(p))
            clu = clu_set(loc)
        end

        function [wvfm, clu1, clu2, epsilon] = resolve_synch(self, wv) %wvs, clus, shank
            %collects methods to return most probable cluster resolution of
            %overlapping waveforms from the noise
            %Input: wv expects a single waveform to be resolved;
            %   shank expects an int
            %Output: wvfm returns subtracted wvfm
            %   clu1 refers to the subtracted wave;
            %   clu2 gives the cluster best matching wvfm
            %   epsilon returns the offset distance between the putative waveforms
            %NOTE: at present, a 'top ten list' is returned for all above variables,
            % in order, for manual post hoc curation

            coeffs = self.coeffs;
            clu_data = self.clu_data;
            templates = self.templates;
            [cands, sub_temps] = self.do_subtraction(wv, templates);

            %compute all pc's for new templates
            %10 pc's based on %var explained analysis
            %ALL BASED ON DIBA'S 54 samples
            for i=1:length(cands)
                cand_fets{i} = zeros(8, 10, 54);
                for j=1:8
                    %convert candidate wvfms into pca space, with 10 pc's
                    test_fets = reshape(cands{i}(j, :, :), 54, [])'*coeffs{j}(:, 1:10);
                    cand_fets{i}(j, :, :) = [test_fets]';
                end
            end

            clu_set = self.clu_set;
            subset = find(clu_set ~= 0 & clu_set ~= 1);
            clu_set = clu_set(subset);

            clu_data = clu_data(subset);
            lcd = length(clu_data);
            display(lcd)

            %THIS IS GROSS
            %compute metric for each candidate
            for i=1:length(cand_fets)
                p{i} = zeros(lcd, 54);
                for j=1:size(cand_fets{i}, 3)
                    for k=1:lcd
                        m = clu_data{k}(:, :, 1);
                        s = clu_data{k}(:, :, 2);
                        %original metric
                        %p{i}(k, j) = sum(sum(sum(abs(m - cand_fets{i}(:, :, j))./s)));
                        %modified metric based on mean of min channel values
                        temp = sort(sum(abs(m - cand_fets{i}(:, :, j))./s, 2));
                        p{i}(k, j) = mean(temp(1:3));
                    end
                end
            end

            coords = []; 
            for i=1:length(cand_fets); 
                val = min(min(p{i}));
                index = i; 
                loc = find(p{i}==min(min(p{i})));
                if length(loc) > 1
                    val = repmat(val, length(loc), 1);
                    index = repmat(index, length(loc), 1);
                end
                coords = [coords; index, val, loc']; 
            end        

            rank = sortrows(coords, 2);
            %for now, take top ten results
            rank = rank(1:10, :);
            display(rank)
            %b = find(coords(:, 1)==min(coords(:, 1))) 

            %[k, j] = find(p{b}==coords(b, 1));
            [k, j] = ind2sub([lcd, 54], rank(:, 3));
            clu1 = clu_set(rank(:, 1));
            display(k)
            clu2 = clu_set(k);
            for i=1:10
                wvfm(:, :, i) = cands{rank(i, 1)}(:, :, j(i));
            end
            epsilon = j-27;
        end

    end

end
