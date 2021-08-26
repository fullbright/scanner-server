HOST=127.0.0.1
TEST_PATH=./
PROJECTPATH=$PWD
DOCKER_IMAGE_VERSION=0.4
DOCKER_FILE?=Dockerfile

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

docker-build: Dockerfile
	docker build -f $(DOCKER_FILE) -t fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) .
	docker tag fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) fullbright/scannerserver:latest

docker-run:
	# docker run -it --rm --device /dev/bus/usb:/dev/bus/usb:rwm -v $(PWD):/myApp -v $(PWD)/config:/config --network bridge fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) /bin/bash
	docker run -it --rm --privileged \
		-v $(PWD)/temp/:/myApp/temp/ \
		-v /dev:/dev --network bridge \
		-v ~/.config/rclone/rclone.conf:/root/.config/rclone/rclone.conf
		fullbright/scannerserver:latest /bin/bash

docker-startapp:
	# docker run -it --rm --device /dev/bus/usb:/dev/bus/usb:rwm -v $(PWD):/myApp -v $(PWD)/config:/config fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) ./start_scan.sh
	docker run -it --rm --privileged --device /dev/bus/usb:/dev/bus/usb:rwm fullbright/scannerserver:$(DOCKER_IMAGE_VERSION)

docker-deploy: docker-build
	#docker tag fullbright/scannerserver:$(DOCKER_IMAGE_VERSION) fullbright/scannerserver:latest
	docker push fullbright/scannerserver:$(DOCKER_IMAGE_VERSION)
	docker push fullbright/scannerserver:latest
