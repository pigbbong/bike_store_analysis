-- Oracle 21c XE는 기본적으로 CDB(Container DB)와 PDB(Pluggable DB) 구조를 가짐
-- 실제 업무/실습용 객체는 PDB(XEPDB1)에서 생성해야 하므로,
-- 세션을 XEPDB1 컨테이너로 전환.
ALTER SESSION SET CONTAINER = XEPDB1;


-- 분석용 계정 생성
-- 사용자명/비밀번호: bike / bike
-- 학습 및 분석을 위한 별도 전용 스키마
CREATE USER bike IDENTIFIED BY "bike";


-- 권한 부여
-- CONNECT : 데이터베이스 접속 권한
-- RESOURCE : 객체(테이블, 뷰 등) 생성 권한
GRANT CONNECT, RESOURCE TO bike;


-- 외부 디렉토리 생성
-- Oracle Database에서 외부 CSV 파일을 읽거나 쓸 수 있도록 매핑하는 가상 경로
-- 실행할 환경에 맞춰서 경로 부분을 수정하면 됨
--    - 주의사항:
--        * 로컬 PC에서 실행시킬 경우, 반드시 Oracle DB 서버 프로세스가 접근 가능한 경로여야 함
--        * 클라이언트 PC 로컬 경로가 아닌, DB 서버 입장에서 접근 가능한 디렉토리 필요
--        * Oracle에서는 보안을 위해 직접 파일 경로를 지정하지 않고
--          DIRECTORY 오브젝트를 생성해 접근 권한을 제어
CREATE OR REPLACE DIRECTORY csv_dir AS 'C:\app\ojbs0\product\21c\oradata\table';


-- 디렉토리 권한 부여
-- bike 계정이 외부 디렉토리에 대해 읽기/쓰기 가능하도록 권한 부여
-- CSV 파일 Import/Export 시 필요
GRANT READ, WRITE ON DIRECTORY csv_dir TO bike;