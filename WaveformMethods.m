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

        function [templates] = get_template_wvs(self, wvs, clus)
            for i=2:2
                %compute template waves
                clu_set = unique(clus{i});
                %remove '0' cluster
                clu_set = clu_set(find(clu_set));

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

        function [candidates] = do_subtraction(self, shell, templates)
            %runs subtraction for particular shell waveform (usu. noise)
            %assumes templates is 8x54x[] %%NEED TO GENERALIZE

            %crude first pass based on max deflection (abs min)

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
                    %pt.plot_wvs(ref)
                    %pause(5);
                    %close

                    %display(size(template(:, :, j+1))); 
                    %display(size(ref));
                    stack(:, :, j+1) = stack(:, :, j+1) - ref;
                end
                candidates{i} = stack;

                %find subtraction which minimizes the variance
            end
        end

    end

end
