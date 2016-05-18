%Specific to analysis of Diba data
%some code below modified from: http://fmatoolbox.sourceforge.net/

classdef IO_data
    properties
            channels = 96;
            shanks = 12;
            electrodes = 8;
            samples = 54;
            rate = 32552;
            path = '~/Documents/Diba-data/';
    end

    methods
        %import clu file and strip off first elem. 
        function [clu] = clu_in(self, electrodeGroup)
            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.clu.' electrodeGroup];
            clu = load(filename);
            f_e = clu(1);
            clu = clu(2:end);
        end

        %pair with res file (spike times)

        function [forms] = spk_in(self, electrodeGroup)
            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.spk.' electrodeGroup];
            file = fopen(filename);
            wvfm = fread(file, 'int16');
                %best to reshape into a 3D matrix
                %dims: electrode:sample:spike

            %spikes = length(clu_data);
            forms = reshape(wvfm, self.electrodes, self.samples, []);
        end

        function [features] = fet_in(self, electrodeGroup) %electrodeGroup corresponds to shank number
            % Load .fet file
            filename = ['Kamran Diba - 2006-6-09_22-24-40.fet.' electrodeGroup];
            clu = self.clu_in(electrodeGroup);

            if ~exist(filename),
                error(['File ''' filename ''' not found.']);
            end
            file = fopen(filename,'r');
            if file == -1,
                error(['Cannot open file ''' filename '''.']);
            end
            nFeatures = fscanf(file,'%d',1);
            fet = fscanf(file,'%f',[nFeatures,inf])';
            fclose(file);
            
            features = [fet(:,end)/self.rate electrodeGroup*ones(size(clu)) clu fet(:,1:end-1)];
        end

        %Lazy read functions for segmenting
        function [] = read_clu()
        end

        function [nFeature, fet] = read_fet(self, electrodeGroup)
            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.fet.' electrodeGroup];
            file = fopen(filename,'r');
            if file == -1,
                error(['Cannot open file ''' filename '''.']);
            end
            nFeatures = fscanf(file,'%d',1);
            fet = fscanf(file,'%d',[nFeatures,inf])';
            fclose(file);
        end
 
%Ignore for now.
        function [] = write_clu(self, clu_var)
            %clu_data
            %append 'Kamran Diba - 2006-6-09_22-24-40.'
            num_clusters = length(unique(clu_var));
            fid = fopen(file_name);
            fprintf(fid, '%d\n', num_clusters, clu_var, '-ascii');
        end

        function [] = write_fet(self, fet_var)
            [nFeatures, fet] = self.read_fet(fet_var);
            fet_w = fet*spike_set;
        end

        function [] = write_spk(self, spk_var)
            
        end

        %Write new set of trace files
        function [] = write_all(self, files)
            self.write_clu(clu_file)
            self.write_res(res_file)
            self.write_spk(spk_file)
        end

    %Data manipulation functions    
        %assume vector of synchronous spike times, v
        v = zeros(1, 649);
        for i=1:649; 
            p(i) = find(fet(:,1)==synch811(i)); 
        end

        %Moved to new file
        %clean up to dynamically adjust; or set ylim to max/min amp of recording
        function [] = plot_wv(self, array)
            electrodes = 8;
            for i=1:electrodes
                subplot(electrodes, 1, i);
                plot(array(i, :));
                ylim([min(min(min(array))), max(max(max(array)))]);
            end
        end
    end

end

%{
MATLAB var reference

spike: sorted, aggregated cell of spikes
interns: interneurons pulled from spike cell
clu_x: (x int) imported cluster data
wv_x: waveform array

%}
