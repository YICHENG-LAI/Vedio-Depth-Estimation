%% This file is to generate data term unary
function [segclass_test,unary] = data_term5(all_img,m,frame,C,alfa,sigma,k,r,t,sigma_d)
H = 540; % image width
W = 960; % image Height
N = W * H; % number of pixels
%initial distance (data term)
disp('------compute unary-------');
unary = zeros(C,N); % 21 * 168750
segclass_test = zeros(1,N);
for row = 0:H-1
   for col = 0:W-1
        pixel = 1+ row*W + col;
        % build unary
        x1 = [col+1,row+1,1]';
        fd = zeros(C,1);
        P = zeros(C,m);
        q = zeros(C,1);
        e = 1;
        if frame == 1
            n1 = 2:m;
        elseif frame == 2
            n1 = [1,3:m];
        else
            n1 = [frame-m/2:frame-1,frame+1:frame+m/2];
        end
        for n = n1
        for i = 1:C
            x2 = k(:,:,n)*r(:,:,n)'*r(:,:,frame)*(k(:,:,frame)\x1) + ...
                        alfa*i*k(:,:,n)*r(:,:,n)'*(t(:,:,frame)-t(:,:,n));
            %x2_tmpt = k(:,:,2)*r(:,:,2)'*r(:,:,1)*(k(:,:,1)\x1) + ...
                        %alfa*i*k(:,:,2)*r(:,:,2)'*(t(:,:,1)-t(:,:,2));
            x2 = round(x2 / x2(3));
                if x2(1) > 0 && x2(2) > 0 && x2(1) <= W && x2(2) <= H
                    d = dist(all_img(row+1,col+1,:,frame),all_img(x2(2),x2(1),:,n));
                    fd(i) = d;
                else
                    fd(i) = 80;
                end
                x2_1 = k(:,:,frame)*r(:,:,frame)'*r(:,:,n)*(k(:,:,n)\x2) + ... 
                        alfa*i*k(:,:,frame)*r(:,:,frame)'*(t(:,:,n)-t(:,:,frame));
                x2_1 = round(x2_1 / x2_1(3));
                q(i) = exp(-((x1(1)-x2_1(1))^2+(x1(2)-x2_1(2))^2)/(2*sigma_d^2));
        end
        P(:,e) = sigma ./ (sigma + fd) .* q;
        e = e + 1;
        end
        L = sum(P,2);
        Ux = 1 ./ max(L);
        unary(:,pixel) = 1 - Ux .* L;
        segclass_test(pixel) = C - find(unary(:,pixel) == min(unary(:,pixel)),1); 
  end
end
end

%% distance function of intensity for images
function d = dist(pixel1, pixel2)
    d = (abs(pixel1(1)-pixel2(1))+abs(pixel1(2)-pixel2(2))+abs(pixel1(3)-pixel2(3))) / 3;
end