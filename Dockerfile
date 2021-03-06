from ubuntu:latest

RUN apt-get update 
RUN apt-get install -y rclone sane sane-utils libsane-extras xsane

# Setup rclone


# Copy the code inside
COPY . /myApp

# Run few debug commands
RUN sane-find-scanner
RUN scanimage -L

#RUN mkdir /myApp
WORKDIR /myApp

#RUN the app
CMD ["./start_scan.sh"]