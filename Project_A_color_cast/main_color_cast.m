% 색조 기반 화이트 밸런스 main 스크립트

% 입력
img = imread(input_path);
img = double(img)/255; % 스케일링

% grayscale(1채널)인 경우, 3채널로
[x,y,z]=size(img);
if z==1, img(:,:,2)=img(:,:,1);img(:,:,3)=img(:,:,1);end

% 핵심 알고리즘(color_cast_correction) 실행
white_result = color_cast_correction(img);

imwrite(white_result, output_path); %출력