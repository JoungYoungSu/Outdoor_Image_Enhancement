% 핵심 알고리즘 함수 color_cast_correction

function StageA = color_cast_correction(i)

%1-1. 쿼드 트리 영역 분할 방식을 이용한 영상 대기광 검출
[StageA.Area, StageA.npass, StageA.index, ...
 StageA.LAB, StageA.a_initial, StageA.b_initial, StageA.atm] ...
    = detect_atmospheric_light(i);

%1-2. 영상의 색조 분류 및 화이트 밸런스
[StageA.a_corr, StageA.b_corr] = ...
    apply_white_balance(StageA.a_initial, StageA.b_initial, StageA.atm, StageA.npass);

StageA.L = StageA.LAB(:,:,1); % L 호출할 수 있도록 명시하기

end