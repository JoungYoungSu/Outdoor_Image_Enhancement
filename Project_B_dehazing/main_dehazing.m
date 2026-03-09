% CIELAB 색공간에서의 디헤이징 main 스크립트

addpath(genpath(fileparts(mfilename('fullpath'))));

% 입력: raw image
img = imread(input_path);
img = double(img)/255; % 스케일링

% 프로젝트 A 실행 (화이트밸런스/색보정)
StageA = color_cast_correction(img); 

% 파라미터 입력(parameter_estimation의 결과)
a1 = -0.0391; 
a2 = 0.9180; 
a3 = -1.8072; 

% 디헤이징 실행
Dehazing_result = estimate_lab_depth_model(img, ...
 StageA.L, StageA.a_corr, StageA.b_corr, StageA.atm, ...
 a1, a2, a3);

% RGB 복원
rgb_Dehazing = lab_to_rgb(Dehazing_result, StageA.a_corr, StageA.b_corr);


% 결과 출력
figure, imshow(Dehazing_result) % 2. 디헤이징한 밝기(L) 출력
figure, imshow(rgb_Dehazing) % 3. rgb 변환한 디헤이징 출력 영상

% 저장
imwrite(Dehazing_result, output_path);
imwrite(rgb_Dehazing, output_path); 