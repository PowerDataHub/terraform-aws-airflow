#!/usr/bin/env bash

set -x

############################################################
# Speedup DPKG and don't use cache for packages
############################################################

# Taken from here: https://gist.github.com/kwk/55bb5b6a4b7457bef38d
#
# this forces dpkg not to call sync() after package extraction and speeds up
# install
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
#

function install_dependencies() {
	DEBIAN_FRONTEND=noninteractive sudo apt-get update -yqq \
	&& DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -yqq \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yqq --no-install-recommends \
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
		python \
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
		zlib1g \
		zlib1g-dev \
		libncurses5-dev \
		libgdbm-dev \
		libnss3-dev \
		libssl-dev \
		libreadline-dev \
		libffi-dev \
    && sudo sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
	#
	# cd /usr/src
	# wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz
	# sudo tar xzf Python-3.7.3.tgz
	# cd Python-3.7.3
	# sudo ./configure --enable-optimizations
	# sudo make altinstall
	# sudo mv python /usr/bin/python3
}

function install_python_and_python_packages() {

    PYCURL_SSL_LIBRARY=openssl $(which pip3) install -U \
      --no-cache-dir --compile --ignore-installed \
      pycurl

	$(which pip3) install -qU setuptools wheel --ignore-installed

	if [ -e /tmp/requirements.txt ]; then
		SLUGIFY_USES_TEXT_UNIDECODE=yes $(which pip3) install -U -r /tmp/requirements.txt
	fi

    SLUGIFY_USES_TEXT_UNIDECODE=yes $(which pip3) install -U \
		Cython \
		pytz \
		pyOpenSSL \
		ndg-httpsclient \
		pyasn1 \
		boto3 \
		boto \
		botocore \
		apache-airflow[celery,postgres,s3,crypto,jdbc,google_auth,redis,slack,ssh]==1.10.2 \
		celery[sqs]
}

function setup_airflow() {
	sudo tee -a /usr/bin/terraform-aws-airflow <<EOL
#!/usr/bin/env bash
if [ "\$AIRFLOW_ROLE" == "SCHEDULER" ]
then exec airflow scheduler -n 10
elif [ "\$AIRFLOW_ROLE" == "WEBSERVER" ]
then exec airflow webserver && airflow flower
elif [ "\$AIRFLOW_ROLE" == "WORKER" ]
then exec airflow worker
else echo "AIRFLOW_ROLE value unknown" && exit 1
fi
EOL

	sudo chmod 755 /usr/bin/terraform-aws-airflow
	sudo mkdir -p /var/log/airflow /etc/airflow /etc/airflow/dags /etc/airflow/plugins
	sudo chmod -R 755 /etc/airflow
	sudo mkdir -p /etc/sysconfig/

	cat /etc/environment | sudo tee -a /tmp/airflow_environment
	cat /tmp/custom_env | sudo tee -a /tmp/airflow_environment
	sed 's/^/export /' -- </tmp/airflow_environment | sudo tee -a /etc/environment
	sudo cat /tmp/airflow.service >> /etc/systemd/system/airflow.service
	cat /tmp/airflow_environment | sudo tee -a /etc/sysconfig/airflow

	source /etc/environment

	if [ "$AIRFLOW__CORE__LOAD_DEFAULTS" = 0 ]; then
		airflow upgradedb
	else
		airflow initdb
	fi

	if [ "$AIRFLOW__WEBSERVER__RBAC" = 1 ]; then
		airflow create_user -r Admin -u ${ADMIN_USERNAME} -f ${ADMIN_NAME} -l ${ADMIN_LASTNAME} -e ${ADMIN_EMAIL} -p ${ADMIN_PASSWORD}
	fi

	sudo chown -R admin: /etc/airflow

	sudo systemctl enable airflow.service
	sudo systemctl start airflow.service
	sudo systemctl status airflow.service
}


START_TIME=$(date +%s)

install_dependencies
install_python_and_python_packages
setup_airflow

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed was [$ELAPSED] seconds"
