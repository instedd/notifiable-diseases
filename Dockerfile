FROM node:0.12

RUN \
  apt-get update && \
  apt-get install -y ruby-compass && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g bower grunt-cli

RUN mkdir /nndd
WORKDIR /nndd

COPY package.json /nndd/
RUN npm install

COPY bower.json /nndd/
RUN bower --allow-root install

COPY . /nndd/

CMD ["grunt", "build"]
