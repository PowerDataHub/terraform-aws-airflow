#!/usr/bin/env bash

set -x

function install_dependencies() {
    sudo apt-get update -yqq && sudo apt-get upgrade -yqq \
    && sudo apt-get install -yqq --no-install-recommends \
        freetds-dev \
		libkrb5-dev \
		libsasl2-dev \
		libffi-dev \
		libpq-dev\
		libxslt-dev \
		libxml2-dev \
		liblapack-dev \
		bzip2 \
		curl \
		git \
		jq \
		libcurl4-openssl-dev \
		libssl-dev \
		openssl \
		postgresql-client \
		python3 \
		python3-pip \
		python3-dev \
        apt-utils \
        build-essential \
        curl \
        freetds-bin \
        locales \
        netcat \
        rsync \
    && sudo sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
}

function install_python_and_python_packages() {

    PYCURL_SSL_LIBRARY=openssl pip3 install \
      --no-cache-dir --compile --ignore-installed \
      pycurl

	pip3 install -qU setuptools wheel --ignore-installed

	if [ -e /var/tmp/requirements.txt ]; then
		SLUGIFY_USES_TEXT_UNIDECODE=yes pip3 install -r /var/tmp/requirements.txt
	fi

    SLUGIFY_USES_TEXT_UNIDECODE=yes pip3 install -U \
		Cython \
		pytz \
		pyOpenSSL \
		ndg-httpsclient \
		pyasn1 \
		boto3 \
		boto \
		botocore \
		numpy \
		scipy \
		pandas \
		apache-airflow[celery,postgres,s3,crypto,jdbc,google_auth,redis,slack,ssh]==1.10.2 \
		celery[sqs] \
		billiard==3.5.0.4 \
		tenacity==4.12.0 \
		'redis>=2.10.5,<3'
}

function setup_airflow() {
	sudo tee -a /usr/bin/terraform-aws-airflow <<EOL
#!/usr/bin/env bash
if [ "\$AIRFLOW_ROLE" == "SCHEDULER" ]
then exec airflow scheduler
elif [ "\$AIRFLOW_ROLE" == "WEBSERVER" ]
then exec airflow webserver
elif [ "\$AIRFLOW_ROLE" == "WORKER" ]
then exec airflow worker
else echo "AIRFLOW_ROLE value unknown" && exit 1
fi
EOL

	sudo chmod 755 /usr/bin/terraform-aws-airflow
	sudo mkdir -p /var/log/airflow /etc/airflow
	sudo chown -R ubuntu: /etc/airflow
	sudo chmod -R 755 /etc/airflow
	sudo mkdir -p /etc/sysconfig/

	cat /etc/environment | sudo tee -a /etc/sysconfig/airflow
	sed 's/^/export /' -- </var/tmp/airflow_environment | sudo tee -a /etc/environment
	sudo cat /var/tmp/airflow.service >> /etc/systemd/system/airflow.service
	cat /var/tmp/airflow_environment | sudo tee -a /etc/sysconfig/airflow

	source /etc/environment

	sudo systemctl enable airflow.service
	sudo systemctl start airflow.service
	sudo systemctl status airflow.service

    airflow initdb
}


START_TIME=$(date +%s)

install_dependencies
install_python_and_python_packages
setup_airflow

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed was [$ELAPSED] seconds"
