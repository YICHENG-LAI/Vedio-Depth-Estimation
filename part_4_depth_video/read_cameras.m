%% read camera matrixes
ca = textread('cameras.txt');
K = zeros(3,3,141);
R = zeros(3,3,141);
T = zeros(3,1,141);
for i = 1:141
    K(:,:,i) = ca((i-1)*7+2:(i-1)*7+4,1:3);
    R(:,:,i) = ca((i-1)*7+5:(i-1)*7+7,1:3);
    T(:,:,i) = ca((i-1)*7+8,1:3);
end
save('cameras','K','R','T');