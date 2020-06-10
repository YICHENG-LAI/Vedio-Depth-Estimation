%% This code is Estimate Depth from video
disp('------------Estimate Depth from video------------');
%% load iamge
load('video_image.mat'); % all_img (540,960,3,141)
load('cameras.mat'); % camera matrixes K R T
H = 540; % image height
W = 960; % image width
N = W * H; % number of pixels

%% Set parameters
%initial label 
segclass = zeros(N,1); % 518400 * 1
C = 20; %number of disparities
sigma = 20;%(unary-dataterm)
sigma_d = 2.5; %(unary-dataterm)
Ws = 0.0001; %prior weight (pairwise-lambda)
epsilon = 50;%prior weight (pairwise-lambda)
ita = 6;%prevent labelcost from being too large(labelcost)
alfa = 0.0005;%for searching points in the right image
m = 10; % number of frames

for ims = 100
frame = ims; % image sequence number

%% Get parameters
[segclass_test,unary] = data_term5(all_img,m,frame,C,alfa,sigma,K,R,T,sigma_d);
%unary = data_term3(all_img,C,alfa,sigma,K,R,T,sigma_d);
pairwise = pairwise_structure(all_img(:,:,:,frame),Ws,epsilon);
labelcost = label_prior(ita,C);

%% graphcut
disp('-------running GCMex---------');
[labels, E, Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost),1);
% show the results of energy minimization
fprintf('E: %d , Eafter: %d \n', E, Eafter);

%% rebuild depth map
% before graphcut
depth_map_before = reshape(segclass_test,W,H)/max(segclass_test);
depth_map_before = depth_map_before';
figure('name','Depth Map')
imshow(depth_map_before);
% after graphcut
depth_map = reshape(labels,W,H)/max(labels);
depth_map = depth_map';
depth_map = 1-depth_map;
figure('name','Depth Map')
imshow(depth_map);
path = ['D:\documents\NUS\Visual Computing\CA2\part_4_depth_video\depth\' num2str(ims) '.jpg'];
imwrite(depth_map,path);
end