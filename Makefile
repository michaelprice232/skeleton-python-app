build:
	docker build -t skeleton-python-app .

run: build
	docker run -p 8000:8000 skeleton-python-app

curl: run
	curl -i http://localhost:8000/
