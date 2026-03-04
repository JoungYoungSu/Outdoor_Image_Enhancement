% 색조 기반 화이트 밸런스 main 스크립트
addpath(genpath(fileparts(mfilename('fullpath'))));

% 입력
img = imread(input_path);
img = double(img)/255; % 스케일링

% grayscale(1채널)인 경우, 3채널로
[x,y,z]=size(img);
if z==1, img(:,:,2)=img(:,:,1);img(:,:,3)=img(:,:,1);end

% 핵심 알고리즘(color_cast_correction) 실행
StageA = color_cast_correction(img);

% 화이트 밸런스한 a, b 값 입력해 출력영상 확인
rgb_StageA = lab_to_rgb(img, StageA.L, StageA.a_corr, StageA.b_corr);

imwrite(rgb_StageA, output_path); %출력