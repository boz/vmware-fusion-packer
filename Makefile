CHANNEL  := alpha
VERSION  := 1000.0.0
URL_BASE := http://$(CHANNEL).release.core-os.net/amd64-usr/$(VERSION)

IMAGE_DIR  := img
IMAGE_NAME := coreos_production_vagrant_vmware_fusion
VMX_PATH   := $(IMAGE_DIR)/$(IMAGE_NAME).vmx
BOX_PATH   := $(IMAGE_DIR)/$(IMAGE_NAME).box
BOX_URL    := $(URL_BASE)/$(IMAGE_NAME).box

PBOX_PATH  := builds/vmware-vmx/vmware-fusion-packer.box

KEY_PATH   := $(IMAGE_DIR)/vagrant
KEY_URL    := https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant

$(BOX_PATH):
	mkdir -p $(IMAGE_DIR)
	wget -NP $(IMAGE_DIR) $(BOX_URL)

$(VMX_PATH): $(BOX_PATH)
	tar -zxvf $(BOX_PATH) -C $(IMAGE_DIR)

$(KEY_PATH):
	wget -NP $(IMAGE_DIR) $(KEY_URL)

$(PBOX_PATH): $(VMX_PATH) $(KEY_PATH) packer.json
	PACKER_LOG=true packer build packer.json

clean:
	rm -rf $(IMAGE_DIR)

packer: $(PBOX_PATH)

vagrant: $(BOX_PATH) Vagrantfile
	BOX_URL=file://$(BOX_PATH) vagrant up --provider vmware_fusion

.PHONY: clean packer vagrant
