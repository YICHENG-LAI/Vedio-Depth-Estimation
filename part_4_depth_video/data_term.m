%% This file is to generate data term unary
function unary = data_term(all_img,C,alfa,sigma,k,r,t,sigma_d)
H = 540; % image width
W = 960; % image Height
N = W * H; % number of pixels
img_1 = all_img(:,:,:,1);
img_2 = all_img(:,:,:,2);
img_3 = all_img(:,:,:,3);
%initial distance (data term)
disp('------compute unary-------');
unary = zeros(C,N); % 61 * 168750
segclass = zeros(N,1);
for row = 0:H-1
   for col = 0:W-1
        pixel = 1+ row*W + col;
        % build unary
        x1 = [col+1,row+1,1]';
        j = 1;
        x2 = [0 0 1]';
        x3 = [0 0 1]';
        fd = zeros(C,1);
        m = 1;% number of frames
        P = zeros(C,m);
        q = zeros(C,1);
        for i = 1:200
            x2_tmpt = k(:,:,2)*r(:,:,2)'*r(:,:,1)*(k(:,:,1)\x1) + ...
                        alfa*i*k(:,:,2)*r(:,:,2)'*(t(:,:,1)-t(:,:,2));
            %x2_tmpt = k2*r2'*r1*(k1\x1) + alfa*i*k2*r2'*(t1-t2);
            x2_tmpt = round(x2_tmpt / x2_tmpt(3));
            if x2_tmpt == x2
                continue
            else
                x2 = x2_tmpt;
                if x2(1) <= 0 || x2(2) <= 0 || x2(1) >= W || x2(2) >= H
                    fd(j) = 80;
                else
                    d = dist(img_1(row+1,col+1,:),img_2(x2(2),x2(1),:));
                    fd(j) = d;
                end
                x2_1 = k(:,:,1)*r(:,:,1)'*r(:,:,2)*(k(:,:,2)\x2) + ... 
                        alfa*i*k(:,:,1)*r(:,:,1)'*(t(:,:,2)-t(:,:,1));
                x2_1 = round(x2_1 / x2_1(3));
                q(j) = exp(-((x1(1)-x2_1(1))^2+(x1(2)-x2_1(2))^2)/(2*sigma_d^2));
            end
            j = j + 1;
            if j == C+1
                break
            end
        end
        P(:,1) = sigma ./ (sigma + fd) .* q;
        %P(:,1) = sigma ./ (sigma + fd);
       
        L = P(:,1);
        Ux = 1 ./ max(L);
        unary(:,pixel) = 1 - Ux .* L;
        %segclass(pixel) = sum(C - find(unary(:,pixel) == min(unary(:,pixel)),1));
  end
end
end

%% distance function of intensity for images
function d = dist(pixel1, pixel2)
    d = (abs(pixel1(1)-pixel2(1))+abs(pixel1(2)-pixel2(2))+abs(pixel1(3)-pixel2(3))) / 3;
end