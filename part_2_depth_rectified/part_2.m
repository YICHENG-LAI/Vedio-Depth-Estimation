%% This code is Estimate Depth from Rectified Stereo Images
disp('------------Estimate Depth from Rectified Stereo Images------------');
%% load iamge
img_left1 = imread('im2_left.png');
img_right1 = imread('im2_right.png');
img_left = double(img_left1);
img_right = double(img_right1);
H = size(img_left,1); % image width
W = size(img_left,2); % image Height
N = W * H; % number of pixels
%show the initial image
figure('name','initial image')
imshow(img_left1);

%% set parameters
%initial label 
segclass = zeros(N,1); % 168750 * 1
line_search = 60;% length of the searching line 
C = line_search + 1; %number of disparities
lambda = 1.9;
%initial distance (data term)
unary = zeros(C,N); % 61 * 168750
%initial graph structure 168750 * 168750 
pairwise_x = [];
pairwise_y = [];
%label cost (Prior term)
[X, Y] = meshgrid(0:C-1, 0:C-1);
labelcost = abs(X - Y);
%compute parameters
for row = 0:H-1
  for col = 0:W-1
    pixel = 1+ row*W + col;
    % find location for sparse pairwise matrix
    if row+1 < H
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+col+(row+1)*W;
    end
    if row-1 >= 0
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+col+(row-1)*W;
    end 
    if col+1 < W
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+(col+1)+row*W;
    end
    if col-1 >= 0
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+(col-1)+row*W;
    end
    % build unary
    j = 1;
    for i = col-line_search+1:col+1
        if i <= 0
            unary(j,pixel) = 60;
        else
            unary(j,pixel) = dist(img_left(row+1,col+1,:),img_right(row+1,i,:));
        end
        j = j + 1;
    end
    % compute the image labels
    segclass(pixel) = 61 - find(unary(:,pixel) == min(unary(:,pixel)),1);
  end
end

% update pairwise
pairwise = sparse(pairwise_x,pairwise_y,lambda,N,N);

%% graphcut
[labels, E, Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost),1);
% show the results of energy minimization
fprintf('E: %d , Eafter: %d \n', E, Eafter);

%% rebuild depth map
depth_map = reshape(labels,W,H)/max(labels);
figure('name','Depth Map')
imshow(depth_map');

%% distance function
function d = dist(pixel1, pixel2)
    d = (abs(pixel1(1)-pixel2(1))+abs(pixel1(2)-pixel2(2))+abs(pixel1(3)-pixel2(3))) / 3;
end