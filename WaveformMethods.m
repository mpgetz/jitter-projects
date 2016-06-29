classdef WaveformMethods
    properties
        wv_set
        wv_mins
    end

    methods
        function self = WaveformMethods(wvs)
            self.wv_set = wvs;
            for i=1:38 
                self.wv_mins(1, i) = min(min(ms{i}, [], 2)); 
                self.wv_mins(2, i) = find(min(ms{i}, [], 2) == is(1, i)); 
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
