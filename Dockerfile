FROM ubuntu:noble

RUN apt update && \
	apt install --assume-yes --fix-broken \
	neofetch \
	man \
	man-db \
	manpages-posix \
	sudo \
	unminimize

RUN yes| unminimize

RUN passwd -d ubuntu && \
	usermod -a -G sudo ubuntu && \
	echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu && \
	chmod 044 /etc/sudoers.d/ubuntu

USER ubuntu:ubuntu
WORKDIR /home/ubuntu

COPY bootstrap.sh /home/ubuntu/bootstrap.sh

RUN sudo chmod +x /home/ubuntu/bootstrap.sh && \
	/home/ubuntu/bootstrap.sh

CMD [ "zsh" ]

