classdef PlotTools
    properties
    end

    methods
        function [] = plot_wvs(self, wv_data, p, test2, m, n)
            figure;
            %x a multiple of 8 as there are 8 channels per shank
            %if y > 4, newline
            for y=1:n; 
                %add optional array of timestamps here
                for i=1:8; 
                    subplot(8*m, n, y+(n*(i-1))); 
                    plot(wv_data(i, :, p(y))); 
                    ylim([min(min(test2(:,:,p(y)))), max(max(test2(:,:,p(y))))]); 
                end 
            end
        end
    end
end
