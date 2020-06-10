%% This code is Estimate Depth from video
disp('------------Estimate Depth from video------------');
%% load iamge
img_left1 = imread('im3_left.jpg');
img_right1 = imread('im3_right.jpg');
img_left = double(img_left1);
img_right = double(img_right1);
H = size(img_left,1); % image width
W = size(img_left,2); % image Height
N = W * H; % number of pixels

%% Set parameters
%initial label 
segclass = zeros(N,1); % 518400 * 1
C = 81; %number of disparities
sigma = 10;%(unary-dataterm)
Ws = 0.2; %prior weight (pairwise-lambda)
epsilon = 50;%prior weight (pairwise-lambda)
ita = 6;%prevent labelcost from being too large(labelcost)
alfa = 0.0001;%for searching points in the right image

%% Get parameters
pairwise = pairwise_structure(img_left,Ws,epsilon);
labelcost = label_prior(ita,C);
unary = data_term(img_left,img_right,C,alfa,sigma);

%% graphcut
disp('-------running GCMex---------');
[labels, E, Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost),1);
% show the results of energy minimization
fprintf('E: %d , Eafter: %d \n', E, Eafter);

%% rebuild depth map
depth_map = reshape(labels,W,H)/max(labels);
figure('name','Depth Map')
imshow(depth_map');