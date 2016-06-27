%Specific to analysis of Diba data
%some code below modified from: http://fmatoolbox.sourceforge.net/

classdef IO_data
    properties
            channels = 96;
            shanks = 12;
            electrodes = 8;
            samples = 54;
            y_samples = 32;
            rate = 32552;
            y_rate = 20000;
            path = '~/Documents/Diba-data/';
            y_path = '~/Documents/Yuta-data/YutaMouse41-150910-01/';
            path2 = '~/Documents/Diba-analysis/';
    end

    methods
        %import clu file and strip off first elem. 
        function [clu] = clu_in(self, electrodeGroup)
            if ischar(electrodeGroup) == 0
                electrodeGroup = int2str(electrodeGroup);
            end

            filename = [self.y_path 'YutaMouse41-150910-01.clu.' electrodeGroup];
            %filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.clu.' electrodeGroup];
            clu = load(filename);
            f_e = clu(1);
            clu = clu(2:end);
        end

        %pair with res file (spike times)

        function [forms] = spk_in(self, electrodeGroup)
            if ischar(electrodeGroup) == 0
                electrodeGroup = int2str(electrodeGroup);
            end

            filename = [self.y_path 'YutaMouse41-150910-01.spk.' electrodeGroup];
            %filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.spk.' electrodeGroup];
            file = fopen(filename);
            if file == -1
                display(filename);
            end

            wvfm = fread(file, 'int16');
                %best to reshape into a 3D matrix
                %dims: electrode:sample:spike

            %spikes = length(clu_data);
            forms = reshape(wvfm, self.electrodes, self.y_samples, []);
            %forms = reshape(wvfm, self.electrodes, self.samples, []);
        end

        function [features] = fet_in(self, electrodeGroup) %electrodeGroup corresponds to shank number
            % Load .fet file
            if ischar(electrodeGroup) == 0
                str_electrodeGroup = int2str(electrodeGroup);
            end

            filename = [self.y_path 'YutaMouse41-150910-01.fet.' electrodeGroup];
            %filename = [self.path 'Kamran Diba - 2006-6-09_22-24-40.fet.' str_electrodeGroup];
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
            
            features = [fet(:,end)/self.y_rate electrodeGroup*ones(size(clu)) clu fet(:,1:end-1)];
            %features = [fet(:,end)/self.rate electrodeGroup*ones(size(clu)) clu fet(:,1:end-1)];
        end

        function [new_set] = prep_data(self, data, reference)
            %type = clu, fet or spk
            %if clu:
            new_set = data(reference);

            %if fet:
            new_set = [data(reference, 3:end), data(reference, 1)*32552];

            %if spk:
            new_set = data(:, :, reference);
        end

        function [new_clu] = recluster(self, data, ref)
            %assigns a new cluster value to a subset of spikes specified by ref variable
            new_clu = data;
            i = max(data) + 1;
            new_clu(ref) = i;
        end
    
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
            fet_var = int32(fet_var);
            nFeatures = 31;
            if ischar(fet_num) == 0
                fet_num = int2str(fet_num);
            end
            s = size(fet_var);

            file_name = strcat(self.path2, 'Kamran Diba - 2006-6-09_22-24-40.fet.', fet_num);
            num_clusters = length(unique(fet_var));
            fid = fopen(file_name, 'w', 'n', 'US-ASCII');
            fprintf(fid, '%i\n', nFeatures);
%            fclose(fid);
%            dlmwrite(file_name, fet_var, 'delimiter','\t', 'precision', '-append');
            format long;
            for i =1:s(1)
                fprintf(fid, '%i\t', fet_var(i, [1:end-1]));
                fprintf(fid, '%i\n', fet_var(i, end));
            end
            fprintf(fid, '\n', '')
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
        function [] = write_all(self, clu_var, fet_var, spk_var, group_num)
            self.write_clu(clu_var, group_num)
            self.write_fet(fet_var, group_num)
            self.write_spk(spk_var, group_num)
            %self.write_res(res_file)
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
