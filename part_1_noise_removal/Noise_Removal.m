%% This code is to remove image noise
disp('------------remove noise------------');
%% load image
noise_img = imread('bayes_in.jpg');
W = size(noise_img,1); % image width
H = size(noise_img,2); % image Height
N = W * H; % number of pixels
C = 2; % number of classes
%show the initial image
figure('name','initial image')
imshow(noise_img);

%% set parameters
source_color = [0,0,255]; %Blue = foreground
sink_color = [245,210,110]; %yelow = background
lambda = 400;
%initial label 
segclass = zeros(N,1); % 440637 * 1
%initial distance (data term)
unary = zeros(C,N); % 2 * 440637
%initial graph structure 440637 * 440637 
pairwise_x = [];
pairwise_y = [];
%label cost (Prior term)
[X Y] = meshgrid(1:2, 1:2);
labelcost = (X - Y).*(X - Y);
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
    unary(1,pixel) = dist(noise_img(col+1,row+1,:),source_color);
    unary(2,pixel) = dist(noise_img(col+1,row+1,:),sink_color);
    % compute the image labels 
    if unary(1,pixel) >= unary(1,pixel)
        segclass(pixel) = 1;
    else
        segclass(pixel) = 0;
    end
  end
end
% update pairwise
pairwise = sparse(pairwise_x,pairwise_y,lambda,N,N);

%% graphcut
[labels, E, Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost),0);
% show the results of energy minimization
fprintf('E: %d , Eafter: %d \n', E, Eafter);

%% rebuild denoised image
denoised_image_label = reshape(labels,W,H);
denoised_image = zeros(W,H,3);
for row = 1:H
  for col = 1:W
      if denoised_image_label(col,row) == 0
          denoised_image(col,row,:) = source_color/255;
      else
          denoised_image(col,row,:) = sink_color/255;
      end
  end
end
figure('name','denoised_image')
imshow(denoised_image);

%% distance function
function d = dist(pixel1, pixel2)
    d = (abs(pixel1(1)-pixel2(1))+abs(pixel1(2)-pixel2(2))+abs(pixel1(3)-pixel2(3))) / 3;
end