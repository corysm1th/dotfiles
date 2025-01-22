FROM ubuntu:noble

RUN apt update && \
	apt install --assume-yes --fix-broken \
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

# RUN chsh -s $(which zsh)

ENV TERM xterm-256color

# RUN git clone https://github.com/corysm1th/dotfiles.git

# WORKDIR /home/ubuntu/dotfiles

# COPY .zshrc /home/ubuntu/.zshrc

# RUN curl -L -O https://go.dev/dl/go1.23.5.linux-amd64.tar.gz && \
	 # rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.5.linux-amd64.tar.gz && \
	 # echo "export PATH=$PATH:/usr/local/go/bin:/home/ubuntu/go/bin" >> /home/ubuntu/.zshrc

# RUN /usr/local/go/bin/go install github.com/justjanne/powerline-go@latest && \
	# ln -s /home/ubuntu/go/bin/powerline-go /bin/powerline-go

CMD [ "zsh" ]

