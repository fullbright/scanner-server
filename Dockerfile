from ubuntu:latest

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update 
RUN apt-get install -y rclone sane sane-utils xsane imagemagick

# Setup rclone


# Copy the code inside
COPY . /myApp
COPY ./config/etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml

# Run few debug commands
RUN sane-find-scanner
RUN scanimage -L

#RUN mkdir /myApp
WORKDIR /myApp

#RUN the app
CMD ["./start_scan.sh"]
