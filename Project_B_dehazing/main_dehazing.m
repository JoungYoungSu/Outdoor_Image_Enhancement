% CIELAB 색공간에서의 디헤이징 main 스크립트

% 깊이 추정 모델은 Zhu et al.의 
% Color Attenuation Prior(CAP, TIP 2015)의 아이디어를 참고하여
% CIELAB 색공간에 맞게 재정의하였습니다.

addpath(genpath(fileparts(mfilename('fullpath'))));

% 입력
img = imread(input_path);
img = double(img)/255; % 스케일링

% grayscale(1채널)인 경우, 3채널로
[x,y,z]=size(img);
if z==1, img(:,:,2)=img(:,:,1);img(:,:,3)=img(:,:,1);end

% 파라미터 입력(parameter_estimation의 결과)
a1 = -0.0391; 
a2 = 0.9180; 
a3 = -1.8072; 

% 핵심 알고리즘(estimate_lab_depth_model: 깊이 추정 모델) 실행
% 본 논문에서는 L=StageA.L, a=StageA.a_corr, b=StageA.b_corr 사용
StageA = color_cast_correction(img); % 프로젝트 A의 출력값

Dehazing_result = estimate_lab_depth_model(img, ...
 StageA.L, StageA.a_corr, StageA.b_corr, StageA.atm, ...
 a1, a2, a3);

% 출력 확인하기
figure, imshow(Dehazing_result) % 2. 디헤이징한 밝기(L) 출력

rgb_Dehazing = lab_to_rgb(Dehazing_result, StageA.a_corr, StageA.b_corr);
figure, imshow(rgb_Dehazing) % 3. rgb 변환한 디헤이징 출력 영상

imwrite(Dehazing_result, output_path);
imwrite(rgb_Dehazing, output_path); 