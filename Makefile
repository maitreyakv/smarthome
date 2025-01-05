include .env

TEMP_DIR := $(shell mktemp -d)
ALL_SHELL_FILES := $(shell find . -type f -name "*.sh") 

# ===================================================================================================== #
#                                                 BUILDING                                              #
# ===================================================================================================== #

all: lint raspberry-pi.img

raspberry-pi.img: rasbian.pkr.hcl setup.sh
	docker run \
		--rm -it --privileged \
		-v ${PWD}:/build \
		-v /dev:/dev \
		--env-file .env \
		mkaczanowski/packer-builder-arm:1.0.9 build rasbian.pkr.hcl

# ===================================================================================================== #
#                                                 DEPLOYING                                             #
# ===================================================================================================== #

deploy: deployment.yaml
	kubectl apply -f deployment.yaml

install: raspberry-pi.img
	@lsblk -d; \
	echo "Which device would you like to flash to?"; \
	echo -n "device: "; \
	read device; \
	device="/dev/$${device}"; \
	echo -n "So flashing to $${device}? Press enter to confirm or Ctrl-C to stop:"; \
	read _; \
	rpi-imager --cli --debug ./raspberry-pi.img "$${device}"; \
	eject "$${device}"; \
	echo "Ejected $${device}"

# ===================================================================================================== #
#                                                 CONNECTING                                            #
# ===================================================================================================== #

ssh-rpi:
	@if [ -z "${RPI_IP}" ]; then echo "Please set RPI_IP in .env!"; exit 1; fi
	ssh "pi@${RPI_IP}"

configure-kubectl:
	@if [ -z "${RPI_IP}" ]; then echo "Please set RPI_IP in .env!"; exit 1; fi
	mkdir ~/.kube
	ssh "pi@${RPI_IP}" "sudo cat /etc/rancher/k3s/k3s.yaml" \
		| sed -r "s/127.0.0.1/${RPI_IP}/" \
		> ~/.kube/config

# ===================================================================================================== #
#                                                 TESTING                                               #
# ===================================================================================================== #

emulate: raspberry-pi.img
	# Emulation modifies the image file, so we make a temporary copy to use 
	# for the emulation, so we don't modify the created image.
	cp raspberry-pi.img ${TEMP_DIR}/raspberry-pi.img
	docker run \
		--rm -it --privileged \
		-v ${TEMP_DIR}/raspberry-pi.img:/usr/rpi/rpi.img \
		-w /usr/rpi \
		ryankurte/docker-rpi-emu:latest ./run.sh rpi.img /bin/bash
	rm -rf ${TEMP_DIR}

lint:
	shellcheck -a --color ${ALL_SHELL_FILES}
	shfmt -d -i 2 ${ALL_SHELL_FILES}

check-deps:
	docker --version
	kubectl version --client
	rpi-imager --version
	shellcheck --version 
	shfmt --version

# ===================================================================================================== #
#                                                 CLEANING                                              #
# ===================================================================================================== #

clean: clean-cache clean-img

clean-cache:
	# Because we build using Docker in priviliged mode, the .packer_cache cannot 
	# be deleted unless we're root. We can use another container to remove the 
	# directory, instead of needing to manually invoke root permissions.
	docker run \
		--rm -it \
		-v ${PWD}:/build \
		--entrypoint=/bin/rm \
		alpine:latest -rf /build/.packer_cache

clean-img:
	rm -f raspberry-pi.img 
