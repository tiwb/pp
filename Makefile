.PHONY: build run

build:
	jekyll

run: build
	open http://localhost:8080
