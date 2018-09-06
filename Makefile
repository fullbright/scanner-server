HOST=127.0.0.1
TEST_PATH=./
PROJECTPATH=$PWD

clean:
	rm --force --recursive build/
	rm --force --recursive dist/
	rm --force --recursive *.egg-info

install:
	sudo apt-get install texlive-bibtex-extra biber


build:
	echo "Compiling project $(project)"
	pdflatex -interaction=nonstopmode $(project).tex
	biber $(project)
	pdflatex -interaction=nonstopmode $(project).tex
	pdflatex -interaction=nonstopmode $(project).tex


docker-run:
	docker build \
      --file=./Dockerfile \
      --tag=my_project ./
	docker run \
      --detach=false \
      --name=my_project \
      --publish=$(HOST):8080 \
      my_project
