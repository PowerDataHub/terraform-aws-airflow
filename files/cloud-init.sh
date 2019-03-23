#!/bin/bash

set -x

function install_dependencies() {
    sudo apt-get update -yqq && sudo apt-get upgrade -yqq
	buildDeps='freetds-dev libkrb5-dev libsasl2-dev libssl-dev libffi-dev libpq-dev git' \
    && sudo apt-get install -yqq --no-install-recommends \
        $buildDeps \
		bzip2 \
		curl \
		gcc \
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
    && sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && sudo useradd -ms /bin/bash -d /etc/airflow airflow \
	&& sudo apt-get purge -y --auto-remove $buildDeps
}

function install_python_and_python_packages() {

	if [ -e /var/tmp/requirements.txt ]; then
	    SLUGIFY_USES_TEXT_UNIDECODE=yes pip3 install -r /var/tmp/requirements.txt
	fi

    PYCURL_SSL_LIBRARY=openssl pip3 install \
      --no-cache-dir --compile --ignore-installed \
      pycurl

	pip3 install -qU setuptools --ignore-installed

    SLUGIFY_USES_TEXT_UNIDECODE=yes pip3 install -U \
		Cython \
		pytz \
		pyOpenSSL \
		ndg-httpsclient \
		pyasn1 \
		wheel \
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

function setup_services() {
	source /etc/environment
	sudo tee -a /usr/bin/terraform-aws-airflow <<EOL
#!/bin/sh
if [ "$AIRFLOW_ROLE" == "SCHEDULER" ]
then exec airflow scheduler
elif [ "$AIRFLOW_ROLE" == "WEBSERVER" ]
then exec airflow webserver
elif [ "$AIRFLOW_ROLE" == "WORKER" ]
then exec airflow worker
else echo "AIRFLOW_ROLE value unknown" && exit 1
fi
EOL

	sudo chmod 755 /usr/bin/terraform-aws-airflow
	echo "AIRFLOW_HOME=/etc/airflow" | sudo tee -a /etc/environment
	cat /var/tmp/airflow-environment | sudo tee -a /etc/airflow/environment
	sudo cat /var/tmp/airflow.service >> /etc/systemd/system/airflow.service
	sudo systemctl enable airflow.service
	sudo systemctl start airflow.service
	sudo systemctl status airflow.service

}

function setup_airflow() {
	sudo chown -R airflow: /etc/airflow
    sudo mkdir -p /var/log/airflow
    airflow upgradedb
}


START_TIME=$(date +%s)

install_dependencies
install_python_and_python_packages
setup_services
setup_airflow

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed was [$ELAPSED] seconds"
