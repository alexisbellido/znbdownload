FROM python:3.7.3-slim-stretch as builder
WORKDIR /root

RUN set -e \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    git-core \
    python3-dev \
    ssh \
  && rm -rf /var/lib/apt/lists/*

ARG SSH_PRIVATE_KEY
RUN mkdir -p /root/.ssh/ \
  && echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa \
  && chmod 600 /root/.ssh/id_rsa \
  && echo "StrictHostKeyChecking no " > /root/.ssh/config

# Private repositories can be cloned now so the following will work on the
# intermediate container.
# git clone git@github.com:user/project.git
# pip install -e git://git.example.com/MyProject#egg=MyProject

COPY requirements.txt /root/requirements.txt

RUN python -m venv /env \
  && . /env/bin/activate \
  && pip install --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]