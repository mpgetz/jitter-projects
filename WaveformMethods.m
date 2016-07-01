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

        function [out] = something(self, in)
            %runs subtraction for particular 
            for i=1:1%length(wv)
                candidate = wv;
                template = repmat(candidate, 1, 1, 54+1);
                k = 8;
                m = ms{k};

                for j=0:54
                    %m is avg waveform of particular neuron
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
                    template(:, :, j+1) = template(:, :, j+1) - ref;
                end

                %find subtraction which minimizes the variance
            end
        end

    end

end
