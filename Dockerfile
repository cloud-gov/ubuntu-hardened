# Ubuntu-hardened base docker image
ARG base_image=ubuntu:22.04

FROM ${base_image}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && apt upgrade -qq -y

# Copy local project directories to container image
COPY . /opt/concourse-ci/task

# Set current working directory for executed scripts
WORKDIR /opt/concourse-ci/task

# Use a custom build script instead of messy chained together RUN
# or multiple RUN statements that add bloat to the image
RUN --mount=type=secret,id=TOKEN /opt/concourse-ci/task/scripts/build.sh

# Run tests on the Docker build
RUN /opt/concourse-ci/task/scripts/test.sh
