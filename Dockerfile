FROM greyltc/archlinux-aur:latest

USER root

RUN echo "Updating pacman"
RUN pacman-key --refresh-keys
RUN yes | pacman -Syyu

ENV LANG en_US.UTF-8

# Installing vim, elixir and phoenix
RUN yes | pacman -Sy vim binutils sed make curl git libunistring python-pip

RUN yes | pacman -Sy elixir
RUN yes | pacman -Sy youtube-dl
RUN yes | pacman -Scc

# Set path for erlang bin files
#RUN echo $(dirname /usr/lib/erlang/*/bin/inet_gethost)
#RUN export PATH=$PATH:$(dirname /usr/lib/erlang/erts-*/bin/inet_gethost)
#ENV PATH=${PATH}:/usr/lib/erlang/erts-8.1.1/bin
RUN ln -s $(ls /usr/lib/erlang/erts-*/bin/inet_gethost) /usr/local/bin

#install phoenix
RUN mix local.hex --force && mix local.rebar --force
RUN yes | mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

USER docker

RUN yes | pacaur -y --noconfirm libkeyfinder-git
RUN yes | pacaur -y --noconfirm keyfinder-cli-git

USER root

EXPOSE 4000

# ADD DEPENDENCY FILES
ADD ./mix.exs ./detektor-backend/
ADD ./mix.lock ./detektor-backend/
WORKDIR /detektor-backend

# BUILD DEPENDENCIES
RUN yes | mix deps.get

# Make sure that youtube-dl is up to date
RUN yes | pip install --upgrade youtube-dl

# ADD REST OF APPLICATION CODE
ADD . /detektor-backend

# RUN PHOENIX SERVER AS ENTRYPOINT
CMD ["iex", "-S", "mix", "phoenix.server"]
