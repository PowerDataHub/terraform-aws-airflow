#!/bin/bash

set -x

function install_dependencyes() {
    sudo apt-get update
    sudo apt-get install -yqq \
      python3 \
      python3-pip \
      git \
      gcc \
      jq \
      curl \
      bzip2 \
      openssl
}

function install_python_and_python_packages() {

    pip3 install -q --upgrade pip

    PYCURL_SSL_LIBRARY=openssl pip3 install \
      --no-cache-dir --compile --ignore-installed \
      pycurl
    SLUGIFY_USES_TEXT_UNIDECODE=yes pip3 install \
      apache-airflow[celery,postgres,s3,crypto]==1.10.2 \
      celery[sqs] \
      billiard==3.5.0.4 \
      tenacity==4.12.0

    pip3 install -qU setuptools --ignore-installed
}


START_TIME=$(date +%s)

install_dependencyes
install_python_and_python_packages

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed was [$ELAPSED] seconds"
