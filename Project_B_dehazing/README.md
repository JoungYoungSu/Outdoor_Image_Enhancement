# Project A : 색조 기반 화이트 밸런스 보정 (Adaptive White Balance for Color Cast Correction)

## 📌 Overview
본 프로젝트는 석사 졸업 연구 주제인 "야외 촬영 환경에서 영상의 가시성 및 품질 개선" 파이프라인의 1단계인 **색조 기반 화이트 밸런스 보정 알고리즘**을 독립적인 프로젝트로 정리한 것이다. 

야외 영상에서 발생하는 색 왜곡(Color Cast)을 해결하기 위해, 기존 '회색 세계 가설(Gray World Assumption)'를 비롯한 화이트 밸런스의 한계를 분석하고, 이를 보완하는 **해석 가능한 통계 기반의 화이트 밸런스 알고리즘**을 제안합니다. 쿼드 트리(Quad-tree) 방식의 대기광 영역 검출과 영상의 색조를 직접 분류 하여 가중치 화이트 밸런스를 설계하였습니다.

<br>

## 🎯 Problem Definition
기존 화이트 밸런스 방식은 야외 환경의 복잡한 조명 조건에서 다음과 같은 한계를 가집니다. 
1. **회색 세계 가설의 오류**: 장면 평균을 무채색으로 가정하여, 화이트 밸런스하므로 특정색의 객체가 넓게 분포하거나, 컬러 캐스트와 유사한 색이 존재할 경우 **과보정(Over-correction)** 발생
2. **대기광 오검출**: 단순히 영상 내 상위 0.1% 밝기의 화소를 대기광으로 추정하는 방식은, 근경의 밝은 흰색 객체(예: 흰 차, 건물)를 대기광으로 잘못 인식하는 문제 유발
3. **색상 과증폭 현상**: RGB 색 공간에서 화이트 밸런스 적용 시, 밝기와 색상이 분리되지 않아 반대 색상이 비정상적으로 증폭되는 부작용 발생

> **💡목표:** 본 연구는 **영역 기반 대기광 추정**과 **LAB 색 공간 기반의 적응형 가중치**를 도입하여 위 한계들을 수학적/통계적으로 완화하도록 합니다.

<br>

## 📂 Repository Structure

```text

├── main_color_cast.m          # 화이트 밸런스 전체 실행 파이프라인
├── core_methods/              # 핵심 알고리즘 모듈 (리팩토링 완료)
│   ├── color_cast_correction.m    # 알고리즘 통합 실행 함수
│   ├── detect_atmospheric_light.m # 1. 대기광 검출 함수
│   ├── split_into_quadrants.m     # 쿼드 트리 기반 영역 분할 함수
│   ├── apply_white_balance.m      # 2. 적응형 가중치 화이트 밸런스 함수  
│   └── lab_to_rgb.m               # CIELAB을 RGB로 변환하는 함수
├── assets/                    # README 작성용 흐름도 및 시각화 이미지 모음
├── Simulation_Outputs/        # 기존 방법과 결과 비교 모음
└── README.md                  

```

---


## 🧠 Methodology

### 1. 쿼드 트리(Quad-Tree) 기반 대기광 영역 검출 

기존 밝기 기반의 단순 검출을 대체하여, 하늘 영역의 밝고 분산이 낮은 특성을 바탕으로 가장 안정적인 하늘/대기광 영역을 탐색합니다.

* **Step 1:** 입력 영상을 4개의 하위 영역으로 분할 

  <details> 
  <summary> <b> 쿼드 트리(Quad-Tree) 분할 과정 및 결과 예시 (Click)</b></summary>
  <br>

  <img src="assets/Methods/Airlight_dectetion/Step1/quad_tree_example.png" width="400">
  <br><sup><b>[그림] 쿼드 트리(Quad-Tree) 분할 및 영역 정의 구조도</b></sup>
  <br><br>

  **[표] 원본 영상 및 4분할(Quad-Tree) 영역 시각화**
  | Original Input | A1 | A2 | A3 | A4 |
  | :---: | :---: | :---: | :---: | :---: |
  | <img src="assets/Methods/Airlight_dectetion/Step1/input.png" width="150"><br><sup>원본 입력 영상</sup> | <img src="./assets/Methods/Airlight_dectetion/Step1/A1.png" width="150"><br><sup>좌측 상단</sup> | <img src="./assets/Methods/Airlight_dectetion/Step1/A2.png" width="150"><br><sup>우측 상단</sup> | <img src="./assets/Methods/Airlight_dectetion/Step1/A3.png" width="150"><br><sup>좌측 하단</sup> | <img src="./assets/Methods/Airlight_dectetion/Step1/A4.png" width="150"><br><sup>우측 하단</sup> |

  <br>
  
  </details>

* **Step 2:** 각 영역의 평균(Mean)과 표준편차(Std)를 기반으로 Score를 계산하여 가장 큰 영역 선택

* **Step 3:** 최소 영역 크기(100×3)에 도달하거나, 최대 분할 횟수(7회)를 만족할 때까지 반복 
  <details> 
  <summary> <b> 쿼드 트리 분할에서 검출된 영역 시각화 (Click)</b></summary>
  <br>

  | Counts | Input | 1 | 2 | 3 | 4 | 5 |
  | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
  | Image | <img src="assets/Methods/Airlight_dectetion/Step3/0.png" width="100"> | <img src="assets/Methods/Airlight_dectetion/Step3/1.png" width="100"> | <img src="assets/Methods/Airlight_dectetion/Step3/2.png" width="100"> | <img src="assets/Methods/Airlight_dectetion/Step3/3.png" width="100"> | <img src="assets/Methods/Airlight_dectetion/Step3/4.png" width="100"> | <img src="assets/Methods/Airlight_dectetion/Step3/5.png" width="100"> |
  | Size | 320×240×3 | 160×120×3 | 80×60×3 | 40×30×3 | 20×15×3 | 10×8×3 |

  <br>
  
  </details>

* **Step 4:** 최종 검출된 영역을 LAB 색 공간으로 변환하여 대기광(Airlight) 영역으로 확장

<br>

### 2. 영상의 색조 분류 및 화이트 밸런스 적용

밝기(L)와 색채(a, b)가 독립적인 LAB 색 공간을 활용하여, 밝기 손실 없이 색조만 정교하게 보정합니다.

* **Step 1:** 선별된 대기광 영역의 색조 강도($E_{atm}$) 계산
  $$E_{atm} = \sqrt{a^2 + b^2}$$

  <details> 
  <summary> <b> 컬러캐스트 영상의 색조 강도 예시 (Click)</b></summary>
  <br>

  <img src="assets/Methods/Chroma_and_Whitebalance/Chroma.png" width="500">
  <br>
  </details>

* **Step 2:** 대규모 데이터셋 시뮬레이션을 통해 경험적으로 도출된 임계값을 기준으로 4가지 Case 분류 및 가중치(Level) 할당
  - Case 1. $E_{atm} > 0.1$ → Level = 1.0 (강한 보정)
  - Case 2. $0.04 \le E_{atm} \le 0.1$ → Level = 0.8
  - Case 3. $0.02 \le E_{atm} \le 0.04$ → Level = 0.6
  - Case 4. $E_{atm} < 0.02$ → Level = 0 (보정 불필요)

* **Step 3:** 설정된 Level을 회색 세계 가설에 적용하여 가중 화이트 밸런스 수행
  - $a_{new} = a - (level \times a_{mean})$
  - $b_{new} = b - (level \times b_{mean})$


---


## 🔄 Processing Pipeline

### 1. 알고리즘 전체 흐름 요약
| 단계 | 주요 프로세스 | 결과 및 목적 |
| :---: | :--- | :--- |
| **Step 1** | **[Input Image]** | 처리할 영상 입력 |
| ↓ | **[Quad-Tree Airlight Detection]** | 쿼드트리 분할을 사용하여 대기광 영역($A$) 추출 |
| ↓ | **[LAB Color Space Conversion]** | RGB를 CIELAB 색공간으로 변환 |
| ↓ | **[Tone Intensity Calculation]** | 대기광의 색조 강도($E_{atm}$) 산출 |
| ↓ | **[Adaptive Weight Assignment]** | 4단계 Case 분류 및 가중치 Level 할당 |
| ↓ | **[Weighted Gray World WB]** | 가중치 기반 회색세계가설(화이트밸런스) 수행 |
| **Final Step** | **[Output Image]** | 최종 보정 영상 출력 및 저장 |

<br>

### 2. 상세 Flowchart

| 1단계: 대기광 영역 검출 알고리즘 | 2단계: 색조 분류 및 화이트 밸런스 |
| :---: | :---: |
| <img src="assets/Methods/Airlight_dectetion/Flowchart_of_airlight_dectetion.png" height="500"> | <img src="assets/Methods/Chroma_and_Whitebalance/Flowchart_of_whitebalance.png" height="500"> |
| <sup><b>[그림 1] 대기광 영역 검출(Airlight Detection)</b></sup> | <sup><b>[그림 2] 적응형 화이트 밸런스(Adaptive WB)</b></sup> |


---


## 📊 Results & Comparison


### 1. 시각적 보정 결과 (Visual Comparison)

#### 1. 대기광 검출 비교
기존 상위 0.1% 기반 방식의 한계(근경의 밝은 객체 오검출)와 쿼드 트리 분할 방식을 통해 극복한 결과를 붉은색 화소로 나타낸 것입니다.
  | 기존 상위 0.1% 검출 방식 (흰색 객체 오검출) | 우: 쿼드 트리 기반 제안 방식 (안정적인 대기광 영역 확보) |
  | :---: | :---: |
  | <img src="assets/Visual_Comparison/Airligtdetection/Brightest_top_pixel.png" width="400"> | <img src="assets/Visual_Comparison/Airligtdetection/Quad-tree.png" width="400"> |
  <br>

#### 2. 색 공간 변환(RGB vs LAB) 비교
RGB 기반 회색 세계 가설(GWA)이 유발하는 반대 색상 증폭 현상을 LAB 색공간에서 밝기와 색체를 분리 처리하여 원 영상과 유사하게 안정성을 확보한 결과입니다.
  | | Original | Colorcast Image (베일 색 R 증폭) | RGB results of GWA (반대 색 B 증폭) | LAB results of GWA (안정성 확보) |
  | :---: | :---: | :---: | :---: | :---: |
  | **Image** | <img src="assets/Visual_Comparison/RGBvsLAB/Original.png" width="200"> |<img src="assets/Visual_Comparison/RGBvsLAB/Colorcast.png" width="200"> | <img src="assets/Visual_Comparison/RGBvsLAB/RGB_Whitebalance.png" width="200"> |<img src="assets/Visual_Comparison/RGBvsLAB/LAB.png" width="200"> |
  | **Histogram** | <img src="assets/Visual_Comparison/RGBvsLAB/Original_graph.png" width="200"> | <img src="assets/Visual_Comparison/RGBvsLAB/Colorcast_graph.png" width="200"> | <img src="assets/Visual_Comparison/RGBvsLAB/RGB_graph.png" width="200"> | <img src="assets/Visual_Comparison/RGBvsLAB/LAB_graph.png" width="200"> |
  <br>

  
#### 3. 색조 강도에 따른 적응형 보정
영상 특성에 맞춰 가중치(Level)가 적응적으로 작동하여 과보정없이 컬러 캐스트만 효과적으로 제거한 결과입니다.
  | | Case 1 (강한 보정, Level 1.0) | Case 2 (Level 0.8) | Case 3 (Level 0.6) | Case 4 (보정 없음, Level 0) |
  | :---: | :---: | :---: | :---: | :---: |
  | **Original Input** | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case1_Input.png" width="200"> | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case2_Input.png" width="200"> | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case3_Input.png" width="200"> |<img src="assets/Visual_Comparison/Adaptive_White_Balance/Case4_Input.png" width="200"> |
  | **Proposed Output** | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case1_Output.png" width="200"> | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case2_Output.png" width="200"> | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case3_Output.png" width="200"> | <img src="assets/Visual_Comparison/Adaptive_White_Balance/Case4_Output.png" width="200"> |
  <br>

<br>

### 2. 시뮬레이션(Simulation) 비교 알고리즘

본 연구는 화이트 밸런스 토대가 된 GWA(Gray World Assumption)와 GWA를 바탕으로한 기존 복합적 보정 알고리즘을 비교군으로 선택하여, 최종 출력 결과를 비교하였습니다. 비교군은 참고 논문에 표기하였습니다.
* **비교군:** GWA, HRDCP, NGCCLAHE 
* **결과:** 제안한 알고리즘(Proposed Algorithm)이 기존 혼합 방식에서 흔히 발생하는 **과보정(Over-enhancement) 및 붉은기/푸른기 편향 현상을 안정적으로 억제**했습니다.
* **기대:** 제안된 화이트 밸런스 처리를 통해 후속 영상 처리 과정에서 왜곡 없는 자연스러운 색채 복원이 가능할 것입니다.

#### 1. High Color Cast (야간/조명 왜곡 심함)
| Inputs(Colorcast) | GWA | HRDCP | NGC CLAHE | **Proposed Algorithm** |
| :---: | :---: | :---: | :---: | :---: |
| <img src="Simulation_Outputs/inputs/High colorcast.png" width="200"> | <img src="Simulation_Outputs/results/High_colorcast/GWA.png" width="200"> | <img src="Simulation_Outputs/results/High_colorcast/HRDCP.png" width="200"> | <img src="Simulation_Outputs/results/High_colorcast/NGCCLAHE.png" width="200"> | <img src="Simulation_Outputs/results/High_colorcast/Proposed.png" width="200"> |

#### 2. Little Color Cast (호박밭 / 색상 보존력 확인)
| Inputs(Colorcast) | GWA | HRDCP | NGC CLAHE | **Proposed Algorithm** |
| :---: | :---: | :---: | :---: | :---: |
| <img src="Simulation_Outputs/inputs/Little colorcast image.png" width="200"> | <img src="Simulation_Outputs/results/Little_colorcast/GWA.png" width="200"> | <img src="Simulation_Outputs/results/Little_colorcast/HRDCP.png" width="200"> | <img src="Simulation_Outputs/results/Little_colorcast/NGCCLAHE.png" width="200"> | <img src="Simulation_Outputs/results/Little_colorcast/Proposed.png" width="200"> |

<br>

**※ 덧붙임:** 위 이미지는 조명 조건에 따른 대표적인 시각적 비교 결과입니다. 시뮬레이션의 원본 영상 및 4가지 환경의 개별 상세 결과는 📁 `Simulation_Outputs/` 폴더 내에서 확인할 수 있습니다.

※ 본 프로젝트는 전체 알고리즘의 1단계 모듈이므로, 단일 모듈에 대한 정량적 평가 대신 시각적 안정성 확보에 주력하였습니다. 전체 시스템의 정량적 평가(PSNR/SSIM) 결과는 [최상위 레포지토리]에 통합할 예정입니다. 


---


## 💡 Limitations & Future Work

### Limitations (현 알고리즘의 한계)

* **경험적 임계값 의존:** 색조 강도($E_{atm}$) 분류 파라미터가 데이터셋의 시뮬레이션 설정으로 고정되어 데이터에 따라 재튜닝 필요. 복잡한 장면에서는 딥러닝에 비해 일반화 성능 제한 가능
* **공간적 한계:** 하늘 영역이 극히 적거나 존재하지 않는 실내/근경 위주의 뷰에서는 쿼드 트리 분할 방식이 오검출 낼 가능성 존재
* **회색 세계 가설의 근본적 한계:** 장면의 실제 평균 색상이 회색과 거리가 먼 경우 보정에 태생적 제약

<br>

### Future Work(개선 방향)

* **학습 기반 하이브리드 설계:** $E_{atm}$ 분포 데이터를 활용하여, 적응형 임계값을 자동 도출하는 머신러닝/딥러닝 결합 구조로 고도화
* **검출 방식 고도화:** 에지(Edge) 분포 및 깊이 맵(Depth Map) 정보를 쿼드 트리 로직과 결합하여 대기광 검출 정확도 향상
* **국소적(Local) 보정 확장:** 영상 전체에 동일한 가중치를 주지 않고, 영역별 조명 변화를 감지하는 Local 화이트 밸런스 기법으로 발전


---


## 📄 Related Publication

* [석사 졸업 연구 보고서] 야외 촬영 환경에서 영상의 가시성 및 품질 개선 (2024)
* [SCIE] "Saturation-Based Airlight Color Restoration of Hazy Images", Applied Sciences, 2023.
* [Conference] "변형된 회색 세계 가정을 이용한 안개 영상의 가시성 개선", 한국정보통신학회, 2023.


## 📚 References
비교 평가에 사용된 기존 화질 개선 알고리즘은 다음과 같습니다.
* **GWA:** K. He, J. Sun and X. Tang, "Single image haze removal using dark channel prior," in 2009 IEEE Conference on Computer Vision and Pattern Recognition: Miami, 2009, pp. 1956-1963, DOI: 10.1109/CVPR.2009.5206515.
* **HRDCP:** Z. Shi, Y. Feng, M. Zhao, E. Zhang and L. He, "Let You See in Sand Dust Weather: A Method Based on Halo-Reduced Dark Channel Prior Dehazing for Sand-Dust Image Enhancement," IEEE Access, vol. 7, pp. 116722-116733, 2019, DOI:  10.1109/ACCESS.2019.2936444.
* **NGC CLAHE:** Z. Shi, Y. Feng, M. Zhao, E. Zhang, and L. He, “Normalised gamma transformation-based contrast-limited adaptive histogram equalisation with colour correction for sand–dust image enhancement,” IET Image Processing vol. 4, pp. 747-756, 2020, DOI: 10.1049/iet-ipr.2019.0992.
