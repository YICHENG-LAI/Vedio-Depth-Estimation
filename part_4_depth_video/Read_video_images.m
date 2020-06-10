%% read images
all_img = zeros(540,960,3,141); % initialize image data vectors
% read 141 images
imgPath = ['D:\documents\NUS\Visual Computing\CA2\part_4_depth_video\Road\src\']; % image file path
imgDir  = dir([imgPath '*.jpg']); % traverse all the jpg image
for j = 1:length(imgDir)          
    img = imread([imgPath imgDir(j).name]); % read every image
    %img1 = reshape(img,[1,numel(img)]);
    all_img(:,:,:,j) = img;
end
all_img = double(all_img)/255;
save('video_image.mat','all_img');

