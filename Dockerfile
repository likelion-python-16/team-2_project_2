# Python 3.12을 기반으로 하는 슬림한 이미지를 사용합니다 (용량이 작고 필요 최소한만 포함)
FROM python:3.12-slim

# Python이 .pyc 파일을 생성하지 않도록 설정
ENV PYTHONDONTWRITEBYTECODE=1
# 표준 출력과 표준 에러를 버퍼링하지 않도록 설정 (로그 실시간 출력)
ENV PYTHONUNBUFFERED=1

# 작업 디렉터리를 컨테이너 내부에서 /app으로 설정
WORKDIR /app

# 현재 디렉토리의 requirements.txt 파일을 컨테이너의 /app으로 복사
COPY requirements.txt .

# pip을 최신 버전으로 업그레이드한 후, 의존성 패키지 설치
RUN pip install --upgrade pip && pip install -r requirements.txt

# 현재 프로젝트의 모든 파일을 컨테이너의 /app 디렉터리에 복사
COPY . .

# Django 정적 파일을 수집 (collectstatic은 설정된 STATIC_ROOT로 정적 파일을 모음)
# 배포 시 필요한 모든 정적 파일(css/js 등)을 하나의 위치로 복사
RUN python manage.py collectstatic --noinput

# 컨테이너가 8000 포트를 외부에 노출
EXPOSE 8000

# 컨테이너 실행 시 gunicorn으로 Django 앱 실행
# - `proj.wsgi:application`: WSGI 엔트리포인트
# - `--bind 0.0.0.0:8000`: 모든 IP에서 포트 8000으로 요청 수신
CMD ["gunicorn", "proj.wsgi:application", "--bind", "0.0.0.0:8000"]