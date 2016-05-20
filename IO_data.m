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
            path2 = '~/Documents/Diba-analysis/';
    end

    methods
        %import clu file and strip off first elem. 
        function [clu] = clu_in(self, electrodeGroup)
            if ischar(electrodeGroup) == 0
                electrodeGroup = int2str(electrodeGroup);
            end

            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.clu.' electrodeGroup];
            clu = load(filename);
            f_e = clu(1);
            clu = clu(2:end);
        end

        %pair with res file (spike times)

        function [forms] = spk_in(self, electrodeGroup)
            if ischar(electrodeGroup) == 0
                electrodeGroup = int2str(electrodeGroup);
            end

            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.spk.' electrodeGroup];
            file = fopen(filename);
            if file == -1
                display(filename);
            end

            wvfm = fread(file, 'int16');
                %best to reshape into a 3D matrix
                %dims: electrode:sample:spike

            %spikes = length(clu_data);
            forms = reshape(wvfm, self.electrodes, self.samples, []);
        end

        function [features] = fet_in(self, electrodeGroup) %electrodeGroup corresponds to shank number
            % Load .fet file
            if ischar(electrodeGroup) == 0
                electrodeGroup = int2str(electrodeGroup);
            end

            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.fet.' electrodeGroup];
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

%        %Lazy read functions for segmenting
%        function [] = read_clu()
%        end
%
%        function [nFeatures, fet] = read_fet(self, electrodeGroup)
%            filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.fet.' electrodeGroup];
%            file = fopen(filename,'r');
%            if file == -1,
%                error(['Cannot open file ''' filename '''.']);
%            end
%            nFeatures = fscanf(file,'%d',1);
%            fet = fscanf(file,'%d',[nFeatures,inf])';
%            fclose(file);
%        end

    %Write functions 
        function [] = write_clu(self, clu_data, clu_num)
            %clu_num is unique file identifier; should not overwrite existing clu file
            if ischar(clu_num) == 0
                clu_num = int2str(clu_num);
            end

            file_name = strcat(self.path2, 'Kamran Diba - 2006-6-09_22-24-40.clu.', clu_num);
            num_clusters = length(unique(clu_data));
            fid = fopen(file_name, 'w');
            fprintf(fid, '%d\n', num_clusters, clu_data, '');
        end

        function [] = write_fet(self, fet_var, fet_num)
        %MAY WANT TO WRITE A PREP FUNCTION TO FIX FET VARIABLE FOR EXPORT
        %would be necessary in general case: [nFeatures, fet] = self.read_fet(fet_var);
            nFeatures = 31;
            if ischar(fet_num) == 0
                fet_num = int2str(fet_num);
            end

            file_name = strcat(self.path2, 'Kamran Diba - 2006-6-09_22-24-40.fet.', fet_num);
            num_clusters = length(unique(fet_var));
            fid = fopen(file_name, 'w');
            fprintf(fid, '%d\n', nFeatures);
            s = size(fet_var);
            for i =1:s(1)
                fprintf(fid, '%d ', fet_var(i, :));
                fprintf(fid, '\n');
            end
            %fprintf(fid, '%d\n', '')
        end

        function [] = write_spk(self, spk_var, spk_num)
            if ischar(spk_num) == 0
                spk_num = int2str(spk_num);
            end

            spk_var = reshape(spk_var, [], 1);
            file_name = strcat(self.path2, 'Kamran Diba - 2006-6-09_22-24-40.spk.', spk_num);
            fid = fopen(file_name, 'w');
            fwrite(fid, spk_var, 'int16');
            
        end

        %Write new set of trace files
        function [] = write_all(self, files)
            self.write_clu(clu_file)
            self.write_fet(fet_file)
            %self.write_res(res_file)
            self.write_spk(spk_file)
        end

    %Data manipulation functions    
        %assume vector of synchronous spike times, synch
        %find position in resp. fet variable for reference/wvfm plotting
        function [v] = get_positions(self, fet, synch)
            v = zeros(1, length(synch));
            for i=1:length(synch); 
                v(i) = find(fet(:,1)==synch(i)); 
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
