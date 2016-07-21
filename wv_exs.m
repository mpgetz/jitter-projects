%Exploratory code for finding overlapping wave synch in spk data

i = 1;
samples = 54;

c1 = 7;
c2 = 10;

cs1 = wvs{1}(:, :, find(clus{1}==c1));
cs2 = wvs{1}(:, :, find(clus{1}==c2));

pc1 = zeros(8, 3, length(cs1));
pc2 = zeros(8, 3, length(cs2));

for i=1:8
    fets1 = reshape(cs1(i, :, :), [], 54)*coeffs{i}(:, 1:3);
    fets2 = reshape(cs2(i, :, :), [], 54)*coeffs{i}(:, 1:3);
    
    pc1(i, :, :) = reshape(fets1, 1, 3, []);
    pc2(i, :, :) = reshape(fets2, 1, 3, []);
end

j = 5;
for i=1:3; 
    subplot(1, 3, i); 
    hold on; 
    scatter(pc1(j, i, :), pc1(4, 1, :)); 
    scatter(pc2(j, i, :), pc2(4, 1, :)); 
    hold off; 
end
