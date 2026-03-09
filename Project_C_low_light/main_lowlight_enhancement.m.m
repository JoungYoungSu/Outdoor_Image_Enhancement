% "밝기 가중치 기반 Retinex와 디헤이징 혼합" 메인 스크립트

% 입력: 디헤이징된 영상 RGB 영상
rgb_J = imread(input_path); 

% LAB 변환
cform=makecform('srgb2lab');
LAB=applycform(rgb_J, cform); 
LAB = double(LAB)/255; % 스케일링

% 채널 분리
J = LAB(:,:,1);     % 밝기 채널
a = LAB(:,:,2)-0.5;
b = LAB(:,:,3)-0.5;

% Retinex + Dehazing fusion 함수
R = brightness_weighted_retinex_fusion(J);

% RGB 복원
rgb_R = lab_to_rgb(R, a, b); % SSR 결과 컬러

% 결과 출력
figure

subplot(1,2,1)
imshow(rgb_J)
title('Input J')

subplot(1,2,2)
imshow(rgb_R)
title('Low-light Enhanced Result')