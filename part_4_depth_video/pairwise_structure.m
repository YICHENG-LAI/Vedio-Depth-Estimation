%% This file is to generate pairwise 
function pairwise = pairwise_structure(img1,Ws,epsilon)
disp('------compute pairwise-------');
H = size(img1,1); % image width
W = size(img1,2); % image Height
N = W * H; % number of pixels
pairwise_x = [];
pairwise_y = [];
lambda = [];
% compute distance
for row = 0:H-1
  for col = 0:W-1
    pixel = 1+ row*W + col;
    Ux_tmpt = []; %initialize lambda parameter
    Nx = 0;%number of neighbors
    % find location for sparse pairwise matrix
    if row+1 < H
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+col+(row+1)*W;
        d = dist(img1(row+1,col+1,:),img1(row+2,col+1,:));
        Ux_tmpt(end+1) = 1 / (d + epsilon);
        Nx = Nx + 1;
    end
    if row-1 >= 0
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+col+(row-1)*W;
        d = dist(img1(row+1,col+1,:),img1(row,col+1,:));
        Ux_tmpt(end+1) = 1 / (d + epsilon);
        Nx = Nx + 1;
    end 
    if col+1 < W
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+(col+1)+row*W;
        d = dist(img1(row+1,col+1,:),img1(row+1,col+2,:));
        Ux_tmpt(end+1) = 1 / (d + epsilon);
        Nx = Nx + 1;
    end
    if col-1 >= 0
        pairwise_x(end + 1) = pixel; 
        pairwise_y(end + 1) = 1+(col-1)+row*W;
        d = dist(img1(row+1,col+1,:),img1(row+1,col,:));
        Ux_tmpt(end+1) = 1 / (d + epsilon);
        Nx = Nx + 1;
    end
    Ux = Nx / sum(Ux_tmpt);
    % set lambda
    if row+1 < H
        d = dist(img1(row+1,col+1,:),img1(row+2,col+1,:));
        lambda(end + 1) = Ws * Ux / (d + epsilon);
    end
    if row-1 >= 0
        d = dist(img1(row+1,col+1,:),img1(row,col+1,:));
        lambda(end + 1) = Ws * Ux / (d + epsilon);
    end 
    if col+1 < W
        d = dist(img1(row+1,col+1,:),img1(row+1,col+2,:));
        lambda(end + 1) = Ws * Ux / (d + epsilon);
    end
    if col-1 >= 0
        d = dist(img1(row+1,col+1,:),img1(row+1,col,:));
        lambda(end + 1) = Ws * Ux / (d + epsilon);
    end
  end
end

% update pairwise
pairwise = sparse(pairwise_x,pairwise_y,lambda,N,N);
end

%% distance function of intensity for images
function d = dist(pixel1, pixel2)
    d = (abs(pixel1(1)-pixel2(1))+abs(pixel1(2)-pixel2(2))+abs(pixel1(3)-pixel2(3))) / 3;
end