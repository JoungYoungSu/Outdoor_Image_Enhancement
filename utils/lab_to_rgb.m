%LAB -> 원영상(RGB) 출력 결과보기

function [rgb_result] = lab_to_rgb(i, L, a, b)

[x,y,z]=size(i);

% 각 채널에 코드 결과 입력하기
result = zeros(x,y,z);
result(:,:,1) = L;
result(:,:,2) = a+0.5; 
result(:,:,3) = b+0.5;
result=uint8(result.*255);

% RGB로 변환
cform_lab2srgb = makecform('lab2srgb'); 
rgb_result = applycform(result, cform_lab2srgb);
end