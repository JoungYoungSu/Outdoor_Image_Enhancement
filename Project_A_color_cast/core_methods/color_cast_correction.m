% 핵심 알고리즘 함수 color_cast_correction

function [result] = color_cast_correction(i)

%1-1. 쿼드 트리 영역 분할 방식을 이용한 영상 대기광 검출
[~, npass, ~, LAB, a, b, atm] = detect_atmospheric_light(i);

%1-2. 영상의 색조 분류 및 화이트 밸런스
[a, b] = apply_white_balance(a, b, atm, npass);

% 화이트 밸런스한 a, b 값 입력해 출력영상 확인
result = lab_to_rgb(i, LAB(:,:,1), a, b);
end