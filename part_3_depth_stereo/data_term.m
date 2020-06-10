%% This file is to generate data term unary
function unary = data_term(img_left,img_right,C,alfa,sigma)
% camera matrices
k1 = [1221.2270770	0.0000000	479.5000000;	
      0.0000000	1221.2270770	269.5000000;	
      0.0000000	0.0000000	1.0000000];
r1 = [1.0000000000	0.0000000000	0.0000000000	
      0.0000000000	1.0000000000	0.0000000000	
      0.0000000000	0.0000000000	1.0000000000];
t1 = [0.0000000000	0.0000000000	0.0000000000]';
k2 = [1221.2270770	0.0000000	479.5000000	
      0.0000000	1221.2270770	269.5000000	
      0.0000000	0.0000000	1.0000000];
r2 = [0.9998813487	0.0148994942	0.0039106989	
     -0.0148907594	0.9998865876	-0.0022532664	
     -0.0039438279	0.0021947658	0.9999898146];
t2 = [-9.9909793759	0.2451742154	0.1650832670]';

H = size(img_left,1); % image width
W = size(img_left,2); % image Height
N = W * H; % number of pixels
%initial distance (data term)
disp('------compute unary-------');
unary = zeros(C,N); % 61 * 168750
segclass = zeros(1,N);
for row = 0:H-1
   for col = 0:W-1
        pixel = 1+ row*W + col;
        % build unary
        x1 = [col+1,row+1,1]';
        j = 1;
        x2 = [0 0 1]';
        fd = zeros(C,1);
        for i = 1:200
            x2_tmpt = k2*r2'*r1*(k1\x1) + alfa*i*k2*r2'*(t1-t2);
            x2_tmpt = round(x2_tmpt / x2_tmpt(3));
            if x2_tmpt == x2
                continue
            else
                x2 = x2_tmpt;
                if x2(1) <= 0 || x2(2) <= 0 || x2(1) >= W || x2(2) >= H
                    fd(j) = 80;
                else
                    d = dist(img_left(row+1,col+1,:),img_right(x2(2),x2(1),:));
                    fd(j) = d;
                end
            end
            j = j + 1;
            if j == C+1
                break
            end
        end
        P = sigma ./ (sigma + fd);
        L = P;
        Ux = 1 / max(P);
        unary(:,pixel) = 1 - Ux .* L;
        segclass(pixel) = C - find(unary(:,pixel) == min(unary(:,pixel)),1);
  end
end
end

%% distance function of intensity for images
function d = dist(pixel1, pixel2)
    d = (abs(pixel1(1)-pixel2(1))+abs(pixel1(2)-pixel2(2))+abs(pixel1(3)-pixel2(3))) / 3;
end