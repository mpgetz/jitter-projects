classdef WaveformMethods
    properties
        wv_set
        wv_mins
        wv_means
    end

    %UNDER CONSTRUCTION
    methods
    %{
        function self = WaveformMethods(wvs)
        %sets up functionality for spike overlap parsing given clustered waveforms
        %should/could be moved to a separate method/class to isolate functionality
            self.wv_set = wvs;
            
            %derive array of min value/channel refs
            for i=1:38 
                self.wv_mins(1, i) = min(min(ms{i}, [], 2)); 
                self.wv_mins(2, i) = find(min(ms{i}, [], 2) == self.wv_mins(1, i)); 
            end

            %derive means of clustered waveforms (needs knowledge of cluster structure)
            m = {}; 
            u = unique(clus{2}); 
            for i=1:length(u); 
                n = find(clus{2}==u(i)); 
                m{i} = wvs{2}(:, :, n); 
            end
        end
     %}   

        %helper function to find wv templates to subtract
        function [ref_wvs] = get_ref_wvs(self)
            %find channel of max neg deflection
            channel = find(min(min(wv, [], 2)));
            ref_wvs = self.wv_mins(find(wv_mins(2, :) == channel));
        end

        function [coeffs, clu_data] = get_fets(self, wvs, clus)
            %re-computes pca on waveset and stores top 3 coeff vectors for
            %eg. use with waveform subtraction, below
            
            %collect all waveforms from each channel & compute pca
            samples = 54;
            u_clus = unique(clus);
            u_clus = u_clus(find(u_clus ~= 0 & u_clus ~= 1));

            for i=1:8
                vec{i} = reshape(wvs(i, :, :), samples, [])';
                coeffs{i} = pca(vec{i});

                for j=1:length(u_clus)
                    clu = find(clus == u_clus(j));
                    fets1 = vec{i}(clu, :)*coeffs{i}(:, 1);
                    fets2 = vec{i}(clu, :)*coeffs{i}(:, 2);
                    fets3 = vec{i}(clu, :)*coeffs{i}(:, 3);
                    clu_data{j}(i, :, 1) = [mean(fets1), mean(fets2), mean(fets3)];                
                    clu_data{j}(i, :, 2) = [std(fets1), std(fets2), std(fets3)];                
                end
            end
        end

        function [templates] = get_template_wvs(self, wvs, clus, shank)
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
                templates{i} = reshape(avgs, 8, 54, []);
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

            %crude first pass based on max deflection (abs min)

            %{
            %compute primary channels for templates
            primary_channel = [];
            mins = reshape(min(templates, [], 2), 8, size(templates, 3));
            maxs = min(mins, [], 1);
            for i=1:size(templates, 3)
                primary_channel(i) = find(maxs(i)==mins(:, i));
            end

            target = min(shell, [], 2);
            first_channel = find(target==min(target));
            %select templates which have matching max deflection
            sub_temps = find(primary_channel==first_channel);
            %}
            %THIS IS A HACK
            sub_temps = [1:size(templates, 3)];

            candidates = {};

            for i=1:length(sub_temps)
                stack = repmat(shell, 1, 1, 54+1);

                for j=0:54
                    m = templates(:, :, sub_temps(i));

                    if j < 27
                        ref = [m(:, 27-j:end), zeros(8, 27-j-1)];     
                    else
                        ref = [zeros(8, j-27), m(:, 1:54-(j-27))];     
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

        function [wvfm, clu1, clu2, epsilon] = resolve_synch(self, wv, wvs, clus, shank)
            %collects methods to return most probable cluster resolution of
            %overlapping waveforms from the noise
            %wv expects a single waveform to be resolved;
            %shank expects an int

            %CACHE ALL THIS ON THE class
            [coeffs, clu_data] = self.get_fets(wvs{shank}, clus{shank});
            templates = self.get_template_wvs(wvs, clus, shank);
            [cands, sub_temps] = self.do_subtraction(wv, templates{shank});

            %compute all pca's for new templates
            %ALL BASED ON DIBA'S 54 samples
            for i=1:length(cands)
                cand_fets{i} = zeros(8, 3, 55);
                for j=1:8
                    test_fets1 = reshape(cands{i}(j, :, :), 54, [])'*coeffs{j}(:, 1);
                    test_fets2 = reshape(cands{i}(j, :, :), 54, [])'*coeffs{j}(:, 2);
                    test_fets3 = reshape(cands{i}(j, :, :), 54, [])'*coeffs{j}(:, 3);
                    cand_fets{i}(j, :, :) = [test_fets1, test_fets2, test_fets3]';
                end
            end

            %THIS IS GROSS
            lcd = length(clu_data);

            for i=1:length(cand_fets)
                p{i} = zeros(lcd, 55);
                for j=1:length(cand_fets{i})
                    for k=1:lcd
                        m = clu_data{k}(:, :, 1);
                        s = clu_data{k}(:, :, 2);
                        %compute (not a) probability for each candidate
                        p{i}(k, j) = sum(sum(sum(abs(m - cand_fets{i}(:, :, j))./s)));
                    end
                end
            end

            coords = []; 
            for i=1:length(cand_fets); 
                coords = [coords; min(min(p{i})), find(p{i}==min(min(p{i})))]; 
            end        

            display(coords)
            b = find(min(coords(:, 1))) %if THERE IS MORE THAN ONE, THROW A FIT

            clu_set = unique(clus{shank});
            clu_set = clu_set(find(clu_set ~= 0 & clu_set ~= 1));
            subset = clu_set(sub_temps)
            [k, j] = find(p{b}==coords(b));
            clu1 = subset(b);
            clu2 = clu_set(k);
            wvfm = cands{b}(:, :, j);
            epsilon = abs(27-j);
        end

    end

end
