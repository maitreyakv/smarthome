TEMP_DIR := $(shell mktemp -d)

all: raspberry-pi.img

emulate: raspberry-pi.img
	# Emulation modifies the image file, so we make a temporary copy to use 
	# for the emulation, so we don't modify the created image.
	cp raspberry-pi.img ${TEMP_DIR}/raspberry-pi.img
	docker run \
		--rm -it --privileged \
		-v ${TEMP_DIR}/raspberry-pi.img:/usr/rpi/rpi.img \
		-w /usr/rpi \
		ryankurte/docker-rpi-emu:latest ./run.sh rpi.img "/bin/su -l pi"
	rm -rf ${TEMP_DIR}

raspberry-pi.img: rasbian.pkr.hcl
	docker run \
		--rm -it --privileged \
		-v ${PWD}:/build \
		-v /dev:/dev \
		mkaczanowski/packer-builder-arm:1.0.9 build rasbian.pkr.hcl

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
