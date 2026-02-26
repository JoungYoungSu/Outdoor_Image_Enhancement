# Project A : 색조 기반 화이트 밸런스 보정 (Adaptive White Balance)

## 📌 Overview
본 프로젝트는 석사 졸업 연구 주제인 "야외 촬영 환경에서 영상의 가시성 및 품질 개선" 파이프라인의 1단계인 **색조 기반 화이트 밸런스 보정 알고리즘**을 독립적인 프로젝트로 정리한 것이다. 

야외 영상에서 발생하는 색 왜곡(Color Cast)을 해결하기 위해, 기존 '회색 세계 가설(Gray World Assumption)'를 비롯한 화이트 밸런스의 한계를 분석하고, 이를 보완하는 **해석 가능한 통계 기반의 화이트 밸런스 알고리즘**을 제안합니다. 쿼드 트리(Quad-tree) 방식의 대기광 영역 검출과 영상의 색조를 직접 분류 하여 가중치 화이트 밸런스를 설계하였습니다.

<br>

## 🎯 Problem Definition
기존 화이트 밸런스 방식은 야외 환경의 복잡한 조명 조건에서 다음과 같은 한계를 가집니다. 
1. **회색 세계 가설의 오류**: 장면 평균을 무채색으로 가정하여, 화이트 밸런스하므로 특정색의 객체가 넓게 분포하거나, 컬러 캐스트와 유사한 색이 존재할 경우 **과보정(Over-correction)** 발생
2. **대기광 오검출**: 단순히 영상 내 상위 0.1% 밝기의 화소를 대기광으로 추정하는 방식은, 근경의 밝은 흰색 객체(예: 흰 차, 건물)를 대기광으로 잘못 인식하는 문제 유발
3. **색상 과증폭 현상**: RGB 색 공간에서 화이트 밸런스 적용 시, 밝기와 색상이 분리되지 않아 반대 색상이 비정상적으로 증폭되는 부작용 발생

> **💡목표:** 본 연구는 **영역 기반 대기광 추정**과 **LAB 색 공간 기반의 적응형 가중치**를 도입하여 이러한 한계들을 수학적/통계적으로 완화하는 것을 목표로 합니다.

<br>

## 📂 Repository Structure

```text

├── main\_color\_cast.m    # 화이트 밸런스 전체 실행 파이프라인
├── core\_methods/        # 핵심 알고리즘 모듈 (리팩토링 완료)
│   ├── color\_cast\_correction.m  # 전체 실행 
│   ├── detect\_atmospheric\_light.m  # 1. 대기광 검출 함수
│   ├── split\_into\_quadrants.m  # 쿼드 트리 영역 분할 함수
│   ├── apply\_white\_balance.m  # 2. 적응형 화이트 밸런스 함수  
│   └── lab\_to\_rgb.m # CIELAB을 RGB로 다시 변환하는 함수
├── results/             # 단계별 결과 및 비교 시각화 이미지
│   ├── comparison/  # 기존 방법과 비교
|	  │   ├── Airligt detection/  
|   │   ├── White Balance/  
|   │   └── Simulation/ 			
|	  └── outputs/ 
└── README.md

```


---


## 🧠 Methodology

### 1. 쿼드 트리(Quad-Tree) 기반 대기광 영역 검출 

기존 밝기 기반의 단순 검출을 대체하여, 하늘 영역의 밝고 분산이 낮은 특성을 바탕으로 가장 안정적인 하늘/대기광 영역을 탐색합니다.

* **Step 1:** 입력 영상을 4개의 하위 영역으로 분할 -> 그림
* **Step 2:** 각 영역의 평균(Mean)과 표준편차(Std)를 기반으로 Score를 계산하여 가장 큰 영역 선택
* **Step 3:** 최소 영역 크기(100×3)에 도달하거나, 최대 분할 횟수(7회)를 만족할 때까지 반복 -> 그림
* **Step 4:** 최종 검출된 영역을 LAB 색 공간으로 변환하여 대기광(Airlight) 영역으로 확장

<details>
<summary> <b>대기광 영역 검출 알고리즘 구조도 (Click)</b></summary>
![대기광 영역 검출 알고리즘](./results/method/Flowchart of airlight dectetion.png)
</details>

<br>

### 2. 영상의 색조 분류 및 화이트 밸런스 적용

밝기(L)와 색채(a, b)가 독립적인 LAB 색 공간을 활용하여, 밝기 손실 없이 색조만 정교하게 보정합니다.

* **Step 1:** 선별된 대기광 영역의 색조 강도($E\_{atm}$) 계산 -> 그림
  $$E\_{atm} = \\sqrt{a^2 + b^2}$$

* **Step 2:** 대규모 데이터셋 시뮬레이션을 통해 경험적으로 도출된 임계값을 기준으로 4가지 Case 분류 및 가중치(Level) 할당
  - Case 1. $E\_{atm} > 0.1$ → Level = 1.0 (강한 보정)
  - Case 2. $0.04 \\le E\_{atm} \\le 0.1$ → Level = 0.8
  - Case 3. $0.02 \\le E\_{atm} \\le 0.04$ → Level = 0.6
  - Case 4. $E\_{atm} < 0.02$ → Level = 0 (보정 불필요)

* **Step 3:** 설정된 Level을 회색 세계 가설에 적용하여 가중 화이트 밸런스 수행
  - $a\_{new} = a - (level \\times a\_{mean})$
  - $b\_{new} = b - (level \\times b\_{mean})$

<details>
<summary> <b>색조 분류 및 화이트 밸런스 구조도 (Click)</b></summary>
(그림 2. 영상의 색조 분류 및 화이트 밸런스 구조도)
</details>


---


## 🔄 Processing Pipeline

[Input Image] 
&nbsp; ↓ 
[Quad-Tree Airlight Detection] ──> 안정적인 대기광 영역 추출

&nbsp; ↓ 
[LAB Color Space Conversion] ──> 밝기와 색채 정보 분리

&nbsp; ↓ 

[Tone Intensity Calculation] ──> E\_atm 산출

&nbsp; ↓ 

[Adaptive Weight Assignment] ──> 4단계 Case 분류 및 Level 결정

&nbsp; ↓ 

[Weighted Gray World WB] ──> 색 왜곡 보정

&nbsp; ↓ 

[Output Image]


---


## 📊 Results (Before \& After)


### 1. 시각적 보정 결과 (Visual Comparison)
* **색조 강도에 따른 적응형 보정:** 영상 특성에 맞춰 가중치(Level)가 적응적으로 작동하여 과보정없이 컬러 캐스트만 효과적으로 제거한 결과입니다.
![색조 강도 보정 결과](./results/best\_result\_sample.png) 
*(좌: 원본(Color Cast 발생) / 우: 제안하는 화이트 밸런스 적용)*


* **대기광 검출 비교:** 기존 상위 0.1% 기반 방식의 한계(근경의 밝은 객체 오검출)를 쿼드 트리 분할 방식을 통해 극복한 결과입니다.
![대기광 검출 비교](./results/result\_airlight\_detection.png)
*(좌: 기존 상위 0.1% 방식 (흰색 객체 오검출) / 우: 쿼드 트리 기반 제안 방식 (안정적인 대기광 영역 확보))*


* **색 공간 변환(RGB vs LAB) 비교:** RGB 기반 회색 세계 가설(GWA)이 유발하는 반대 색상 증폭 현상을 LAB 색공간에서 밝기와 색체를 분리 처리하여 안정성을 확보한 결과입니다.
![색 공간 비교](./results/result\_colorspace\_lab.png)
*(좌: RGB 기반 GWA 적용 시 색상 왜곡 발생 / 우: LAB 기반 제안 알고리즘 적용 시 색상 유지)*

<br>

### 2. 시뮬레이션(Simulation) 비교 알고리즘
* **비교군:** GWA(Gray World Assumption), HRDCP, NGCCLAHE
* **결과:**Proposed Algorithm(PA)이 과보정 없이 가장 안정적인 색조 복원 결과를 시각적으로 달성함.
![비교 결과 이미지](./results/comparison\_with\_gwa.png)


**💡 덧붙임:** 위 이미지는 대표적인 하이라이트 결과이며, **전체 시뮬레이션 비교군(HRDCP, NGCCLAHE 등) 및 다수의 테스트 셋 결과**는 아래 폴더에 모두 정리되어 있습니다.
👉 **[상세 결과 이미지 및 데이터 보러가기](./results/Simulation Outputs/)**


※ 본 프로젝트는 전체 알고리즘의 1단계 모듈이므로, 단일 모듈에 대한 정량적 수치 평가 대신 시각적 안정성 확보에 주력하였습니다. 전체 시스템의 정량적 평가(PSNR/SSIM) 결과는 \[최상위 연구 레포지토리]에 통합되어 있습니다. 


---


## 💡 Limitations \& Future Work
### Limitations (현 알고리즘의 한계)
* **경험적 임계값 의존:** 색조 강도($E\_{atm}$) 분류 파라미터가 데이터셋의 시뮬레이션 설정으로 고정되어 데이터에 따라 재튜닝 필요. 복잡한 장면에서는 딥러닝에 비해 일반화 성능 제한 가능
* **공간적 한계:** 하늘 영역이 극히 적거나 존재하지 않는 실내/근경 위주의 뷰에서는 쿼드 트리 분할 방식이 오검출 낼 가능성 존재
* **회색 세계 가설의 근본적 한계:** 장면의 실제 평균 색상이 회색과 거리가 먼 경우 보정에 태생적 제약

<br>

### Future Work(개선 방향)
* **학습 기반 하이브리드 설계:** $E\_{atm}$ 분포 데이터를 활용하여, 적응형 임계값을 자동 도출하는 머신러닝/딥러닝 결합 구조로 고도화
* **검출 방식 고도화:** 에지(Edge) 분포 및 깊이 맵(Depth Map) 정보를 쿼드 트리 로직과 결합하여 대기광 검출 정확도 향상
* **국소적(Local) 보정 확장:** 영상 전체에 동일한 가중치를 주지 않고, 영역별 조명 변화를 감지하는 Local 화이트 밸런스 기법으로 발전


---


## 📄 Related Publication
* [석사 졸업 연구 보고서] 야외 촬영 환경에서 영상의 가시성 및 품질 개선 (2024)
* [SCIE] "Saturation-Based Airlight Color Restoration of Hazy Images", Applied Sciences, 2023.
* [Conference] "변형된 회색 세계 가정을 이용한 안개 영상의 가시성 개선", 한국정보통신학회, 2023.



