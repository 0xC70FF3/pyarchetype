FROM python:3.5
MAINTAINER "0xC70FF3"

# installing base tools for building
RUN apt-get update && apt-get install -y \
	python3 \
	zip \
	curl

# installing easy setup	
RUN curl -O https://bootstrap.pypa.io/ez_setup.py
RUN python3 ez_setup.py

# copy requirements
COPY requirements.txt /tmp/

# installing pip3 and dependencies
RUN curl -O https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py
RUN python3 get-pip.py
RUN pip3 install -r /tmp/requirements.txt

ENV PYTHONPATH $PYTHON_PATH:/src 
ENV STATS_CLUSTER_HOSTS elasticsearch

COPY src /src
COPY VERSION /

ENTRYPOINT ["python3", "/src/__main__.py"]
