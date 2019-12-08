#!/usr/bin/env bash

set -ex

function install_dependencies() {
	sudo apt-get update
	sudo rm /boot/grub/menu.lst
	sudo update-grub-legacy-ec2 -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yqq \
	&& sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yqq \
    && sudo apt-get install -yqq --no-install-recommends \
		apt-utils \
		bzip2 \
		curl \
		freetds-dev \
		git \
		jq \
		libcurl4-openssl-dev \
		libffi-dev \
		libkrb5-dev \
		liblapack-dev \
		libpq-dev \
		libpq5 \
		libsasl2-dev \
		libssl-dev \
		libxml2-dev \
		libxslt-dev \
		postgresql-client \
		python \
		python3 \
		python3-dev \
		python3-pip \
        build-essential \
        freetds-bin \
        locales \
        netcat \
        rsync \
    && sudo sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

function install_python_and_python_packages() {
	pip3 install -qU setuptools wheel --ignore-installed

	PYCURL_SSL_LIBRARY=openssl pip3 install \
      --no-cache-dir --compile --ignore-installed \
      pycurl


	if [ -e /tmp/requirements.txt ]; then
		pip3 install -r /tmp/requirements.txt
	fi

    pip3 install -U \
		apache-airflow[celery,postgres,s3,crypto,jdbc,google_auth,redis,slack,ssh,sentry]==1.10.6 \
		boto3 \
		celery[sqs]==4.3.0 \
		cython \
		ndg-httpsclient \
		psycopg2-binary \
		pyasn1 \
		pydruid \
		pyopenssl \
		pytz \
		redis \
		wheel

	sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10

	}
}

function setup_airflow() {
	sudo tee -a /usr/bin/terraform-aws-airflow <<EOL
#!/usr/bin/env bash
if [ "\$AIRFLOW_ROLE" == "SCHEDULER" ]
then exec airflow scheduler -n 10
elif [ "\$AIRFLOW_ROLE" == "WEBSERVER" ]; then
	exec airflow webserver
elif [ "\$AIRFLOW_ROLE" == "WORKER" ]
then exec airflow worker
else echo "AIRFLOW_ROLE value unknown" && exit 1
fi
EOL

	sudo chmod 755 /usr/bin/terraform-aws-airflow
	sudo mkdir -p /var/log/airflow /usr/local/airflow /usr/local/airflow/dags /usr/local/airflow/plugins
	sudo chmod -R 755 /usr/local/airflow
	sudo mkdir -p /etc/sysconfig/

	cat /etc/environment | sudo tee -a /tmp/airflow_environment
	cat /tmp/custom_env | sudo tee -a /tmp/airflow_environment
	sed 's/^/export /' -- </tmp/airflow_environment | sudo tee -a /etc/environment
	sudo cat /tmp/airflow.service >> /etc/systemd/system/airflow.service
	cat /tmp/airflow_environment | sudo tee -a /etc/sysconfig/airflow

	source /etc/environment

	if [ "$AIRFLOW__CORE__LOAD_DEFAULTS" = false ]; then
			airflow upgradedb
	else
			airflow initdb
	fi

	if [ "$AIRFLOW__WEBSERVER__RBAC" = true ]; then
		airflow create_user -r Admin -u "${ADMIN_USERNAME}" -f "${ADMIN_NAME}" -l "${ADMIN_LASTNAME}" -e "${ADMIN_EMAIL}" -p "${ADMIN_PASSWORD}"
	fi

	sudo chown -R ubuntu: /usr/local/airflow

	sudo systemctl enable airflow.service
	sudo systemctl start airflow.service
	sudo systemctl status airflow.service
}

function cleanup() {
	apt-get purge --auto-remove -yqq $buildDeps \
	&& apt-get autoremove -yqq --purge \
	&& apt-get clean \
	&& rm -rf \
		/var/lib/apt/lists/* \
		/usr/share/man \
		/usr/share/doc \
		/usr/share/doc-base
}

START_TIME=$(date +%s)

install_dependencies
install_python_and_python_packages
setup_airflow
cleanup

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed: [$ELAPSED] seconds"
