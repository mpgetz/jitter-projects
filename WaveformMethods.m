classdef WaveformMethods
    properties
        wv_set
        wv_mins
        wv_means
    end

    %UNDER CONSTRUCTION
    methods
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

        %helper function to find wv templates to subtract
        function [ref_wvs] = get_ref_wvs(self)
            %find channel of max neg deflection
            channel = find(min(min(wv, [], 2)));
            ref_wvs = self.wv_mins(find(wv_mins(2, :) == channel));
        end
    end

end
