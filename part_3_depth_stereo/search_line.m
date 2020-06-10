%% load iamge
img_left1 = imread('im3_left.jpg');
img_right1 = imread('im3_right.jpg');
img_left = double(img_left1);
img_right = double(img_right1);
H = size(img_left,1); % image width
W = size(img_left,2); % image Height
N = W * H; % number of pixels


%% camera matrices
k1 = [1221.2270770	0.0000000	479.5000000;	
      0.0000000	1221.2270770	269.5000000;	
      0.0000000	0.0000000	1.0000000];
r1 = [1.0000000000	0.0000000000	0.0000000000	
      0.0000000000	1.0000000000	0.0000000000	
      0.0000000000	0.0000000000	1.0000000000];
t1 = [0.0000000000	0.0000000000	0.0000000000]';
c1 = -r1'* t1;
k2 = [1221.2270770	0.0000000	479.5000000	
      0.0000000	1221.2270770	269.5000000	
      0.0000000	0.0000000	1.0000000];
r2 = [0.9998813487	0.0148994942	0.0039106989	
     -0.0148907594	0.9998865876	-0.0022532664	
     -0.0039438279	0.0021947658	0.9999898146];
t2 = [-9.9909793759	0.2451742154	0.1650832670]';
c2 = -r2'* t2;

%% Set parameters
%initial label 
segclass = zeros(N,1); % 168750 * 1
n_d = 60;% number of depth
alfa = 0.0001;
C = n_d + 1; %number of disparities
d = [0:n_d];
lambda = 100;
%initial distance (data term)
unary = zeros(C,N); % 61 * 168750
%initial graph structure 168750 * 168750 
pairwise_x = [];
pairwise_y = [];
%label cost (Prior term)
[X, Y] = meshgrid(0:C-1, 0:C-1);
labelcost = abs(X - Y);
imx = [];
imy = [];
%mx = 720;
%my = 300;
figure('name','initial image')
imshow(img_left1);
[mx my] = ginput(1);
hold on
scatter(mx,my,25,'r','filled');
hold off

 x1 = [mx,my,1]';
    j = 1;
 
        x2 = [0 0 1]';
        for i = 1:200
            x2_tmpt = k2*r2'*r1*inv(k1)*x1 + alfa*i*k2*r2'*(t1-t2);
            x2_tmpt = round(x2_tmpt / x2_tmpt(3));
            if x2_tmpt == x2
                continue
            else
                x2 = x2_tmpt;
                if x2(1) <= 0 || x2(2) <= 0 || x2(1) >= W || x2(2) >= H
                    continue
                else
                    imx = [imx;x2(1)];
                    imy = [imy;x2(2)];
                end
            end
            j = j + 1;
            if j == 102
                break
            end
        end
        
%show the initial image

figure('name','line search')
imshow(img_right1);
hold on
scatter(imx,imy,25,'r','filled');
hold off