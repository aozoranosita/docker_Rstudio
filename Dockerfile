# Use Ubuntu as the base image
FROM ubuntu:24.04

# Install necessary dependencies for R and RStudio
RUN apt-get update && apt-get install -y \
    dirmngr \
    gnupg \
    software-properties-common \
    wget \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    locales \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the locale to UTF-8
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

RUN apt update -qq \
    && apt install --no-install-recommends software-properties-common dirmngr \
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    && sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/"

# Install R
RUN apt-get update && apt-get install --no-install-recommends -y r-base

# Install RStudio Server
RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.09.0-375-amd64.deb \
    && apt-get install -y gdebi-core \
    && gdebi rstudio-server-2024.09.0-375-amd64.deb \
    && rm rstudio-server-2024.09.0-375-amd64.deb

# Install renv and tidyverse
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" \
    && R -e "install.packages('tidyverse', repos='https://cloud.r-project.org')" \
    && R -e "renv::init()"

# Create a non-root user for RStudio
RUN useradd -m -s /bin/bash rstudio \
    && echo "rstudio:rstudio" | chpasswd \
    && adduser rstudio sudo

# Expose the RStudio port
EXPOSE 8787

# Start RStudio Server
CMD ["/usr/lib/rstudio-server/bin/rserver"]

