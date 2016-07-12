%Exploratory code for finding overlapping wave synch in spk data

%compute all pca's for new templates
for i=1:length(cands)
    cand_fets{i} = zeros(8, 55);
    for j=1:8
        %for now, take only first pc
        test_fets = reshape(cands{i}(j, :, :), 54, [])'*coeffs{j}(:, 1);
        cand_fets{i}(j, :) = reshape(test_fets, 1, []);
    end
end

%THIS IS GROSS
lcd = length(clu_data);

for i=1:length(cand_fets)
    p{i} = zeros(lcd, 55);
    for j=1:length(cand_fets{i})
        for k=1:length(clu_data)
            m = clu_data{k}(:, 1);
            s = clu_data{k}(:, 2);
            %compute (not a) probability for each candidate
            p{i}(k, j) = sum(abs(m - cand_fets{i}(:, j))./s);
        end
    end
end
