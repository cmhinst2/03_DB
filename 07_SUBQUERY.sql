/*
 * SUBQUERY (서브쿼리 == 내부 쿼리)
 * - 하나의 SQL문 안에 포함된 또다른 SQL(SELECT)문
 * - 메인쿼리(==외부 쿼리, 기존쿼리)를 위해 보조 역할을 하는 쿼리문
 * 
 * - 메인쿼리가 SELECT 문일 때
 * - SELECT, FROM, WHERE, HAVING 절에서 사용가능
 * 
 * */

-- 서브쿼리 예시 1.

-- 부서코드가 노옹철 사원과 같은 소속의 직원의
-- 이름, 부서코드 조회

-- 1) 노옹철의 부서코드 조회 (서브쿼리)
SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철'; -- 'D9'


-- 2) 부서코드가 'D9'인 직원의 이름, 부서코드 조회 (메인쿼리)
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D9';



-- 3) 부서코드가 노옹철 사원과 같은 소속의 직원 명단 조회
--> 위의 2개의 단계를 하나의 쿼리로!! 
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = (SELECT DEPT_CODE
					FROM EMPLOYEE
					WHERE EMP_NAME = '노옹철');


				
-- 서브쿼리 예시 2.
-- 전 직원의 평균 급여보다 많은 급여를 받고 있는 직원의
-- 사번, 이름, 직급코드, 급여 조회
				
-- 1) 전 직원의 평균 급여 조회하기 (서브쿼리)
SELECT CEIL(AVG(SALARY))
FROM EMPLOYEE; -- 3047663


-- 2) 직원 중 급여가 3047663원 이상인 사원들의
-- 사번, 이름, 직급코드, 급여 조회 (메인쿼리)
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3047663;

				
-- 3) 위의 2단계를 하나의 쿼리로! 
-- 전 직원의 평균 급여보다 많은 급여를 받고 있는 직원의
-- 사번, 이름, 직급코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= (SELECT CEIL(AVG(SALARY))
				FROM EMPLOYEE);				
			

-----------------------------------------------------------------------------
			
/* 서브쿼리 유형
 * 
 * - 단일행 (단일열) 서브쿼리 : 서브쿼리의 조회 결과 값의 개수가 1개일 때
 * 
 * - 다중행 (단일열) 서브쿼리 : 서브쿼리의 조회 결과 값의 개수가 여러개일 때
 * 
 * - 다중열 서브쿼리 : 서브쿼리의 SELECT 절에 나열된 항목수가 여러개일 때
 * 
 * - 다중행 다중열 서브쿼리 : 조회 결과 행 수와 열 수가 여러개일 때
 * 
 * - 상(호연)관 서브쿼리 : 서브쿼리가 만든 결과 값을 메인쿼리가 비교 연산할 때
 * 						메인쿼리 테이블의 값이 변경되면 
 * 						서브쿼리의 결과값도 바뀌는 서브쿼리
 * 
 * - 스칼라 서브쿼리 : 상관 쿼리이면서 결과 값이 하나인 서브쿼리
 * 
 * ** 서브쿼리 유형에 따라 서브쿼리 앞에 붙는 연산자가 다름 ** 
 * 
 * */			
			
			
-- 1. 단일행 서브쿼리 (SINGLE ROW SUBQUERY)
--    서브쿼리의 조회 결과 값의 개수가 1개인 서브쿼리
--    단일행 서브쿼리 앞에는 비교 연산자 사용
--    < , >, <= , >= , = , != / <> / ^=			
			
			
-- 전 직원의 급여 평균보다 많은(초과) 급여를 받는 직원의
-- 이름, 직급명, 부서명, 급여를 직급 순으로 정렬하여 조회

SELECT EMP_NAME, JOB_NAME, DEPT_TITLE, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE SALARY > (SELECT AVG(SALARY) FROM EMPLOYEE)
ORDER BY JOB_CODE;
-- SELECT절에 명시되지 않은 컬럼이라도
-- FROM, JOIN 으로 인해 테이블상 존재하는 컬럼이면
-- ORDER BY 절 사용 가능!			
			
			
-- 가장 적은 급여를 받는 직원의
-- 사번, 이름, 직급명, 부서코드, 급여, 입사일 조회
			
-- 서브쿼리 
SELECT MIN(SALARY) FROM EMPLOYEE; -- 1380000

-- 메인쿼리 + 서브쿼리
SELECT EMP_ID, EMP_NAME, JOB_NAME, DEPT_CODE, SALARY, HIRE_DATE
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE SALARY = (SELECT MIN(SALARY) FROM EMPLOYEE);


-- 노옹철 사원의 급여보다 많이 (초과) 받는 직원의
-- 사번, 이름, 부서명, 직급명, 급여 조회


-- 서브쿼리
SELECT SALARY FROM EMPLOYEE
WHERE EMP_NAME = '노옹철'; -- 3700000


-- 메인쿼리 + 서브쿼리
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_ID = DEPT_CODE)
WHERE SALARY > (SELECT SALARY FROM EMPLOYEE
				WHERE EMP_NAME = '노옹철');



-- 부서별(부서가 없는 사람 포함) 급여의 합계 중
-- 가장 큰 부서의 부서명, 급여 합계를 조회
			
			
-- 1) 부서별 급여 합 중 가장 큰 값 조회
SELECT MAX(SUM(SALARY))
FROM EMPLOYEE
GROUP BY DEPT_CODE; -- 17,700,000


-- 2) 부서별 급여합이 17,700,000인 부서의 부서명과 급여합 조회
SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON(DEPT_ID = DEPT_CODE)
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = 17700000;


-- 3) 위의 두 쿼리를 합쳐 부서별 급여 합이 큰 부서의
--    부서명, 급여 합 조회
SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON(DEPT_ID = DEPT_CODE)
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = (SELECT MAX(SUM(SALARY))
					FROM EMPLOYEE
					GROUP BY DEPT_CODE);


---------------------------------------------------------------------------------
				
-- 2. 다중행 서브쿼리 (MULTI ROW SUBQUERY)
--    서브쿼리의 조회 결과 값의 개수가 여러행일 때

/* 
 * >> 다중행 서브쿼리 앞에는 일반 비교연산자 사용 X
 * 
 * - IN / NOT IN : 여러 개의 결과값 중에서 한 개라도 일치하는 값이 있다면
 * 								 혹은 없다면 이라는 의미 (가장 많이 사용!)
 * 
 * - > ANY, < ANY : 여러개의 결과값 중에서 한 개라도 큰 / 작은 경우
 * 									가장 작은 값 보다 큰가? / 가장 큰 값 보다 작은가?
 * 
 * - > ALL, < ALL : 여러개의 결과값의 모든 값 보다 큰 / 작은 경우
 * 									가장 큰 값 보다 큰가? / 가장 작은 값 보다 작은가?
 * 
 * - EXISTS / NOT EXISTS : 값이 존재하는가? / 존재하지 않는가?
 * 
 * 
 * */										
							
				
-- 부서별 최고 급여를 받는 직원의
-- 이름, 직급, 부서, 급여를 
-- 부서 순으로 정렬하여 조회
				
				
-- 부서별 최고 급여 (서브쿼리)
SELECT MAX(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE; -- 7행 1열 (다중행)

				
-- 메인쿼리 + 서브쿼리
SELECT EMP_NAME, JOB_CODE, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY IN (SELECT MAX(SALARY)
				FROM EMPLOYEE
				GROUP BY DEPT_CODE)
ORDER BY DEPT_CODE;
				
				

-- 사수에 해당하는 직원에 대해 조회
-- 사번, 이름, 부서명, 직급명, 구분(사수/사원)
				
-- * 사수 == MANAGER_ID 컬럼에 작성된 사번
SELECT * FROM EMPLOYEE;


-- 1) 사수에 해당하는 사원번호 조회  (서브쿼리) 
SELECT DISTINCT MANAGER_ID
FROM EMPLOYEE
WHERE MANAGER_ID IS NOT NULL;


-- 2) 직원의 사번, 이름, 부서명, 직급명 조회 (메인쿼리)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);


-- 3) 사수에 해당하는 직원에 대한 정보 추출 조회 (구분 '사수'로)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사수' 구분
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID IN (SELECT DISTINCT MANAGER_ID
				FROM EMPLOYEE
				WHERE MANAGER_ID IS NOT NULL);


-- 4) 일반 직원에 해당하는 사원들 정보 조회 (구분은 '사원'으로)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사원' 구분
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID NOT IN (SELECT DISTINCT MANAGER_ID
				FROM EMPLOYEE
				WHERE MANAGER_ID IS NOT NULL);			


-- 5) 3,4 의 조회 결과를 하나로 조회 		
			
-- 1. 집합 연산자 (UNION 합칩합) 사용방법
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사수' 구분
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID IN (SELECT DISTINCT MANAGER_ID
				FROM EMPLOYEE
				WHERE MANAGER_ID IS NOT NULL)
UNION
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사원' 구분
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID NOT IN (SELECT DISTINCT MANAGER_ID
				FROM EMPLOYEE
				WHERE MANAGER_ID IS NOT NULL);
			
			

-- 2. 선택함수 사용~!
--> DECODE(컬럼명, 값1, 1인경우, 값2, 2인경우, .... , 일치하지 않는경우);
--> CASE WHEN 조건1 THEN 값1
--  	WHEN 조건2 THEN 값2
--      ELSE 값
--  END 별칭

SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, 
	CASE WHEN EMP_ID IN (SELECT DISTINCT MANAGER_ID
						FROM EMPLOYEE
						WHERE MANAGER_ID IS NOT NULL)
		THEN '사수'
		ELSE '사원'
	END 구분
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
ORDER BY EMP_ID;



-- 대리 직급의 직원들 중에서 
-- 과장 직급의 최소 급여보다
-- 많이 받는 직원의 
-- 사번, 이름, 직급명, 급여 조회

-- > ANY : 가장 작은 값 보다 큰가?


-- 1) 직급이 대리인 직원들의 사번, 이름, 직급, 급여 조회 (메인쿼리)
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '대리';

-- 2) 직급이 과장인 직원들의 급여 조회 (서브쿼리)
SELECT SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '과장';

			
-- 3) 대리 직급의 직원들 중에서 과장 직급의 최소 급여보다
-- 많이 받는 직원의 사번, 이름, 직급명, 급여 조회


-- 방법 1) MIN 을 이용해서 단일행 서브쿼리를 만듦.
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '대리'
AND SALARY > (SELECT MIN(SALARY)
				FROM EMPLOYEE
				JOIN JOB USING(JOB_CODE)
				WHERE JOB_NAME = '과장');

-- 방법 2) ANY 를 이용하기
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '대리'
AND SALARY > ANY (SELECT SALARY
				FROM EMPLOYEE
				JOIN JOB USING(JOB_CODE)
				WHERE JOB_NAME = '과장');



-- 차장 직급의 급여 중 가장 큰 값보다 많이 받는 과장 직급의 직원
-- 사번, 이름, 직급, 급여 조회
			
-- > ALL, < ALL : 가장 큰 값 보다 크냐? / 가장 작은 값보다 작냐?
			
-- 서브쿼리
SELECT SALARY 
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '차장';
			

-- 메인쿼리 + 서브쿼리
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '과장'
AND SALARY > ALL (SELECT SALARY 
				FROM EMPLOYEE 
				JOIN JOB USING(JOB_CODE)
				WHERE JOB_NAME = '차장');



-- 서브쿼리 중첩 사용 (응용편!)
			
-- LOCATION 테이블에서 NATIONAL_CODE가 KO인 경우의 LOCAL_CODE와
-- DEPARTMENT 테이블의 LOCATION_ID와 동일한 DEPT_ID가
-- EMPLOYEE테이블의 DEPT_CODE와 동일한 사원을 구하시오.								
			
-- 1) LOCATION 테이블에서 NATIONAL_CODE가 KO인 경우의 LOCAL_CODE 조회
SELECT LOCAL_CODE
FROM LOCATION 
WHERE NATIONAL_CODE = 'KO'; -- 'L1'


-- 2) DEPARTMENT 테이블의 위의 결과(L1)와 동일한 LOCATION_ID를 가지고 있는 DEPT_ID 조회
SELECT DEPT_ID
FROM DEPARTMENT
WHERE LOCATION_ID = (SELECT LOCAL_CODE
					FROM LOCATION 
					WHERE NATIONAL_CODE = 'KO');
			
				
-- 3) 최종적으로 EMPLOYEE 테이블에서 위의 결과들과 동일한 DEPT_CODE를 가진 사원을 조회			
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE IN (SELECT DEPT_ID -- 다중행
					FROM DEPARTMENT
					WHERE LOCATION_ID = (SELECT LOCAL_CODE
										FROM LOCATION 
										WHERE NATIONAL_CODE = 'KO')); -- 단일행
			
----------------------------------------------------------------------------------------------
										
-- 3. (단일행) 다중열 서브쿼리
--    서브쿼리 SELECT 절에 나열된 컬럼 수가 여러개 일 때										
			
			
-- 퇴사한 여직원과 같은 부서, 같은 직급에 해당하는
-- 사원의 이름, 직급코드, 부서코드, 입사일 조회

-- 1) 퇴사한 여직원 조회
SELECT DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE ENT_YN = 'Y'
AND SUBSTR(EMP_NO, 8, 1) = '2'; -- D8  J6 (이태림)

-- 2) 퇴사한 여직원과 같은 부서, 같은 직급 조회

-- 방법1 ) 단일행 단일열 서브쿼리 2개를 사용해서 조회
SELECT DEPT_CODE
FROM EMPLOYEE
WHERE ENT_YN = 'Y'
AND SUBSTR(EMP_NO, 8, 1) = '2';

SELECT JOB_CODE
FROM EMPLOYEE
WHERE ENT_YN = 'Y'
AND SUBSTR(EMP_NO, 8, 1) = '2';



SELECT EMP_NAME, JOB_CODE, DEPT_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE DEPT_CODE = (SELECT DEPT_CODE
					FROM EMPLOYEE
					WHERE ENT_YN = 'Y'
					AND SUBSTR(EMP_NO, 8, 1) = '2')
AND JOB_CODE = (SELECT JOB_CODE
				FROM EMPLOYEE
				WHERE ENT_YN = 'Y'
				AND SUBSTR(EMP_NO, 8, 1) = '2');



-- 방법2 ) 다중열 서브쿼리 사용
--> WHERE 절에 작성된 컬럼 순서에 맞게
-- 서브쿼리의 조회된 컬럼과 비교하여 일치하는 행만 조회
-- 컬럼 순서가 중요!!
SELECT EMP_NAME, JOB_CODE, DEPT_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE
								FROM EMPLOYEE
								WHERE ENT_YN = 'Y'
								AND SUBSTR(EMP_NO, 8, 1) = '2');
										
			
---------------연습 문제 ---------------------------

-- 1. 노옹철 사원과 같은 부서, 같은 직급인 사원을 조회(단, 노옹철 제외)
-- 사번, 이름, 부서코드, 직급코드, 부서명, 직급명
SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB_CODE, DEPT_TITLE, JOB_NAME
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_ID = DEPT_CODE)
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE 
								FROM EMPLOYEE
								WHERE EMP_NAME = '노옹철')
AND EMP_NAME != '노옹철';



-- 2. 2000년도에 입사한 사원의 부서와 직급이 같은 사원을 조회
--    사번, 이름, 부서코드, 직급코드, 입사일     
SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE
								FROM EMPLOYEE
								WHERE EXTRACT(YEAR FROM HIRE_DATE) = 2000);




-- 3. 77년생 여자 사원과 동일한 부서이면서 동일한 사수를 가지고 있는 사원 조회
--    사번, 이름, 부서코드, 사수번호, 주민번호, 입사일    
		
SELECT EMP_ID, EMP_NAME, DEPT_CODE, MANAGER_ID, EMP_NO, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, MANAGER_ID) = (SELECT DEPT_CODE, MANAGER_ID
								FROM EMPLOYEE
								WHERE EMP_NO LIKE '77%'
								AND SUBSTR(EMP_NO, 8, 1) = '2'); 
			
---------------------------------------------------------------------

-- 4. 다중행 다중열 서브쿼리
-- 서브쿼리 조회 결과 행 수와 열 수가 여러개 일 때
							
-- 본인이 소속된 직급의 평균 급여를 받고있는 직원의
-- 사번, 이름, 직급코드, 급여 조회
-- 단, 급여와 급여 평균은 만원단위로 계산 TRUNC(컬럼명, -4)
							
-- 1) 직급별 평균 급여 (서브쿼리)
SELECT JOB_CODE, TRUNC(AVG(SALARY), -4)
FROM EMPLOYEE
GROUP BY JOB_CODE;
							
			
-- 2) 사번, 이름, 직급코드, 급여 조회 (메인쿼리 + 서브쿼리)			
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (SELECT JOB_CODE, TRUNC(AVG(SALARY), -4)
							FROM EMPLOYEE
							GROUP BY JOB_CODE);



------------------------------------------------------------
						
-- 5. 상[호연]관 서브쿼리                        
-- 상관 쿼리는 메인쿼리가 사용하는 테이블값을 서브쿼리가 이용해서 결과를 만듦
-- 메인쿼리의 테이블값이 변경되면 서브쿼리의 결과값도 바뀌게 되는 구조


-- 상관쿼리는 먼저 메인쿼리 한 행을 조회하고
-- 해당 행이 서브쿼리의 조건을 충족하는지 확인하여 SELECT를 진행함


-- ** 해석순서가 기존 서브쿼리와 다르게
-- 메인쿼리 1행 -> 1행에 대한 서브쿼리 수행
-- 메인쿼리 2행 -> 2행에 대한 서브쿼리 수행
-- ...
-- 메인쿼리의 행의 수 만큼 서브쿼리가 생성되어 진행됨



-- 직급별 급여 평균보다 급여를 많이 받는 직원의
-- 이름, 직급코드, 급여 조회
						

-- 메인쿼리 
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE;
						
						
-- 서브쿼리
SELECT AVG(SALARY)
FROM EMPLOYEE
WHERE JOB_CODE = 'J3';

-- 상관쿼리
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE MAIN
WHERE SALARY > (SELECT AVG(SALARY)
				FROM EMPLOYEE SUB
				WHERE MAIN.JOB_CODE = SUB.JOB_CODE);
			
-------------------------------------------------------------
			
-- 사수가 있는 직원의 사번, 이름, 부서명, 사수사번 조회
--> 상관 서브쿼리를 사용하여 각 직원의 MANAGER_ID가 
--  실제로 직원 테이블의 EMP_ID와 일치하는 확인			


-- 메인쿼리(직원의 사번, 이름, 부서명, 사수사번 조회)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, MANAGER_ID
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);
			
-- 서브쿼리(사수인 직원)

SELECT EMP_ID
FROM EMPLOYEE
WHERE EMP_ID = 214;


-- 상관쿼리
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, MANAGER_ID
FROM EMPLOYEE MAIN
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE MANAGER_ID = (SELECT EMP_ID
					FROM EMPLOYEE SUB
					WHERE SUB.EMP_ID = MAIN.MANAGER_ID);
				
				
-- 부서별 입사일이 가장 빠른 사원의
-- 사번, 이름, 부서코드, 부서명(NULL 이면 '소속없음'), 직급명, 입사일을 조회하고
-- 입사일이 빠른순으로 정렬해라.
-- 단, 퇴사한 직원은 제외해라.

-- 메인쿼리(사번, 이름, 부서코드, 부서명(NULL 이면 '소속없음'), 직급명, 입사일을 조회
-- 			단, 퇴사한 직원은 제외)
SELECT EMP_ID, EMP_NAME, DEPT_CODE, NVL(DEPT_TITLE, '소속없음'), JOB_NAME, HIRE_DATE
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON(DEPT_ID = DEPT_CODE);
--WHERE ENT_YN = 'N'; 


-- 서브쿼리(부서별 입사일이 가장 빠른 사원)
SELECT MIN(HIRE_DATE)
FROM EMPLOYEE
WHERE DEPT_CODE = 'D8'
--AND ENT_YN = 'N';
			
-- 상관쿼리 (이태림이 D8부서에서 가장 빠른입사&퇴사자여서 걸러짐 - D8 부서 아예 제외)
SELECT EMP_ID, EMP_NAME, DEPT_CODE, NVL(DEPT_TITLE, '소속없음'), JOB_NAME, HIRE_DATE
FROM EMPLOYEE MAIN
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON(DEPT_ID = DEPT_CODE)
WHERE ENT_YN = 'N'
AND HIRE_DATE = (SELECT MIN(HIRE_DATE)
				FROM EMPLOYEE SUB
				WHERE SUB.DEPT_CODE = MAIN.DEPT_CODE)
ORDER BY HIRE_DATE;
				

-- 퇴사자인 이태림을 제외한 상태로, D8 부서의 가장 빠른 입사자도 포함
SELECT EMP_ID, EMP_NAME, DEPT_CODE, NVL(DEPT_TITLE, '소속없음'), JOB_NAME, HIRE_DATE
FROM EMPLOYEE MAIN
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON(DEPT_ID = DEPT_CODE)
--WHERE ENT_YN = 'N'
WHERE HIRE_DATE = (SELECT MIN(HIRE_DATE)
				FROM EMPLOYEE SUB
				WHERE SUB.DEPT_CODE = MAIN.DEPT_CODE
				AND ENT_YN = 'N'
				OR (SUB.DEPT_CODE IS NULL AND MAIN.DEPT_CODE IS NULL)) -- 소속없음까지
ORDER BY HIRE_DATE;

-------------------------------------------------------------------------------

-- 6. 스칼라 서브쿼리
--   SELECT절에 사용되는 서브쿼리 결과로 1행만 반환함
--   SQL 에서 단일 값을 '스칼라' 라고 함.
-- 즉, SELECT 절에 작성되는 단일행 단일열 서브쿼리를 스칼라 서브쿼리라고 함.


-- 모든 직원의 이름, 직급, 급여, 전체 사원 중 가장 높은 급여와의 차(급여 차)를 조회
SELECT EMP_NAME, JOB_CODE, SALARY, 
( SELECT MAX(SALARY) FROM EMPLOYEE ) - SALARY "급여 차"
FROM EMPLOYEE;



-- 모든 사원의 이름, 직급코드, 급여,
-- 각 직원들이 속한 직급의 급여 평균을 조회

-- 메인쿼리
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE;

-- 서브쿼리
SELECT AVG(SALARY) 
FROM EMPLOYEE
WHERE JOB_CODE = 'J2'; 
-- 단일행 단일열 -> SELECT 절에 쓰면 스칼라 서브쿼리

--( 스칼라 + 상관쿼리 )
SELECT EMP_NAME, JOB_CODE, SALARY,
		(SELECT CEIL(AVG(SALARY)) 
		FROM EMPLOYEE SUB
		WHERE SUB.JOB_CODE = MAIN.JOB_CODE) 평균
FROM EMPLOYEE MAIN
ORDER BY JOB_CODE;


-- 모든 사원의 사번, 이름, 관리자사번, 관리자명을 조회
-- 단, 관리자가 없는 경우 '없음'으로 표시

-- 스칼라 + 상관쿼리
SELECT EMP_ID, EMP_NAME, MANAGER_ID, 
	NVL((SELECT EMP_NAME 
		FROM EMPLOYEE SUB
		WHERE SUB.EMP_ID = MAIN.MANAGER_ID 
	), '없음') 관리자명
FROM EMPLOYEE MAIN;

-----------------------------------------------------------

-- 7. 인라인 뷰 (INLINE-VIEW)
--   FROM 절에서 서브쿼리를 사용하는 경우로
--   서브쿼리가 만든 결과의집합(RESULT SET)을 테이블 대신 사용.

-- 서브쿼리
SELECT EMP_NAME 이름, DEPT_TITLE 부서
FROM EMPLOYEE
JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);

-- 부서가 기술지원부인 모든 컬럼 조회
SELECT * 
FROM (SELECT EMP_NAME 이름, DEPT_TITLE 부서
		FROM EMPLOYEE
		JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID))
WHERE 부서 = '기술지원부';



-- 인라인뷰를 활용한 TOP-N 분석

-- 전 직원 중 급여가 높은 상위 5명의
-- 순위, 이름, 급여 조회


-- ROWNUM 컬럼 : 행 번호를 나타내는 가상 컬럼
-- SELECT , WHERE, ORDER BY 절 사용가능

/*3*/SELECT ROWNUM, EMP_NAME, SALARY
/*1*/FROM EMPLOYEE
/*2*/WHERE ROWNUM <= 5
/*4*/ORDER BY SALARY DESC;
--> SELECT문의 해석 순서 때문에
-- 급여 상위 5명이 아니라
-- 조회 순서 상위 5명끼리의 급여 순위 조회됨

--> 인라인뷰를 이용해서 해결 가능!

-- 1) 이름, 급여를 급여 내림차순으로 조회한 결과를 인라인뷰 사용
--> FROM 절에 작성되기 때문에 해석 1순위
SELECT EMP_NAME, SALARY
FROM EMPLOYEE
ORDER BY SALARY DESC;


-- 2) 메인쿼리 조회 시 ROWNUM을 5 이하 까지만 조회
SELECT ROWNUM, EMP_NAME, SALARY
FROM (SELECT EMP_NAME, SALARY
		FROM EMPLOYEE
		ORDER BY SALARY DESC) -- 해석순위1위 FROM 절에서 전체 직원의 SALARY 내림차순 정렬
WHERE ROWNUM <= 5; -- 해석순위2위 WHERE절에서 이제 가상컬럼의 1~5 행까지만 조회



-- 급여 평균이 3위 안에 드는 부서의
-- 부서코드, 부서명, 평균급여 조회 
-- 인라인뷰 (+ GROUP BY)

/* 3 */SELECT DEPT_CODE, DEPT_TITLE, 평균급여
/* 1 */FROM ( SELECT DEPT_CODE, DEPT_TITLE, CEIL(AVG(SALARY)) 평균급여
		FROM EMPLOYEE
		LEFT JOIN DEPARTMENT ON (DEPT_ID = DEPT_CODE)
		GROUP BY DEPT_CODE, DEPT_TITLE
		ORDER BY 평균급여 DESC
)
/* 2 */ WHERE ROWNUM <= 3;


-------------------------------------------------------------------

-- 8. WITH
--    서브쿼리에 이름 붙여주고 사용 시 이름을 사용하게 함
--    인라인뷰로 사용될 서브쿼리에 주로 사용됨
--    실행속도가 빨라진다는 장점이 있음.


-- 전직원의 급여 순위
-- 순위, 이름, 급여 조회

WITH TOP_SAL AS(SELECT EMP_NAME, SALARY
				FROM EMPLOYEE
				ORDER BY SALARY DESC)
SELECT ROWNUM, EMP_NAME, SALARY
FROM TOP_SAL
WHERE ROWNUM <= 10;

--------------------------------------------------------------------------

-- 9. RANK() OVER / DENSE_RANK() OVER

-- RANK() OVER : 동일한 순위 이후의 등수를 동일한 인원 수 만큼 건너 뛰고 순위 계산
--  EX) 공동 1위가 2명이면 다음 순위 2위가 아니라 3위

-- 사원별 급여 순위

-- RANK() OVER(정렬순서) / DENSE_RANK() OVER(정렬순서)
SELECT RANK() OVER(ORDER BY SALARY DESC) 순위, EMP_NAME, SALARY
FROM EMPLOYEE;
-- 19	전형돈	2000000
-- 19	윤은해	2000000
-- 21	박나라	1800000

-- DENSE_RANK() OVER : 동일한 순위 이후의 등수를 이후 순위로 계산
--  EX) 공동 1위가 2명이어도 다음 순위 2위
SELECT DENSE_RANK() OVER(ORDER BY SALARY DESC) 순위, EMP_NAME, SALARY
FROM EMPLOYEE;
-- 19	전형돈	2000000
-- 19	윤은해	2000000
-- 20	박나라	1800000











