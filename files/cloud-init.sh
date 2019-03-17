#!/bin/bash

set -x

function install_dependencyes() {
    sudo apt-get update
    sudo apt-get install -y \
      python3 \
      python3-pip \
      python3-dev \
      python3-wheel \
      git \
      gcc \
      jq \
      curl \
      libcurl4-openssl-dev \
      libssl-dev \
      bzip2 \
      postgresql-client \
      openssl
}

function install_python_and_python_packages() {

    pip install -q --upgrade pip

    PYCURL_SSL_LIBRARY=openssl sudo -H pip install \
      --no-cache-dir --compile --ignore-installed \
      pycurl

    export SLUGIFY_USES_TEXT_UNIDECODE=yes
    pip install \
      apache-airflow[celery,postgres,s3,crypto]==1.10.2 \
      celery[sqs] \
      billiard==3.5.0.4 \
      tenacity==4.12.0

    sudo -H pip install -qU setuptools --ignore-installed
}


START_TIME=$(date +%s)

install_dependencyes
install_python_and_python_packages

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed was [$ELAPSED] seconds"
