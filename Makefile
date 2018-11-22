HOST=127.0.0.1
TEST_PATH=./
PROJECTPATH=$PWD
DOCKER_IMAGE_VERSION=0.1

clean:
	rm --force --recursive build/
	rm --force --recursive dist/
	rm --force --recursive *.egg-info

install: build


build: docker-build

run-test-scan:
	echo "Scanning A4 documents"
	./start_scan.sh

run-test:
	today=`date +%Y-%m-%d.%H:%M:%S`; ./scan2pdf.sh temp/testscan_$(today).pdf

docker-build:
	docker build -t fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) .

docker-run:
	docker run -it --rm --device /dev/bus/usb:/dev/bus/usb:rwm -v $(PWD):/myApp -v $(PWD)/config:/config --network bridge fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) /bin/bash

docker-startapp:
	docker run -it --rm --device /dev/bus/usb:/dev/bus/usb:rwm -v $(PWD):/myApp -v $(PWD)/config:/config fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) ./start_scan.sh
