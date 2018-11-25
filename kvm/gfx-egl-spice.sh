#!/bin/bash

echo "Using GFX Card:"
echo "Offscreen EGL"

QEMU_OPTS+=(
	-vga none
	-device bochs-display
	-spice port=$GFX_SPICEPORT,password,agent-mouse=on
	-device virtio-serial-pci 
	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 
	-chardev spicevmc,id=spicechannel0,debug=0,name=vdagent
#USB
-device ich9-usb-ehci1,id=susb 
-device ich9-usb-uhci1,masterbus=susb.0,firstport=0,multifunction=on 
-device ich9-usb-uhci2,masterbus=susb.0,firstport=2 
-device ich9-usb-uhci3,masterbus=susb.0,firstport=4 
# WEBDAV
-device virtserialport,chardev=charchannel1,id=channel1,name=org.spice-space.webdav.0 
-chardev spiceport,name=org.spice-space.webdav.0,id=charchannel1
# STREAM
-device virtserialport,chardev=charchannel2,id=channel2,name=org.spice-space.stream.0 \
-chardev spiceport,name=org.spice-space.stream.0,id=charchannel2
)

QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "spice", "password": "secret" } }'
)
