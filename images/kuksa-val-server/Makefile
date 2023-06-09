SHELL := /bin/bash
REG := quay.io
ORG := fedora
NAME := kuksa-val-server
TAG := f38-latest
IMAGE := ${REG}/${ORG}/${NAME}:${TAG}

build:
	@ podman build -t ${IMAGE} .

debug: build
	@ podman run -it  ${IMAGE} /bin/bash
