#!/bin/bash

echo "Using GFX Card:"
echo "QXL"
QEMU_OPTS+=(
	-vga qxl
	-device qxl
	-global qxl-vga.vgamem_mb=32
	-global qxl-vga.vram_size_mb=96
	-spice port=$GFX_SPICEPORT,password,agent-mouse=on
	-device virtio-serial 
	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 
	-chardev spicevmc,id=spicechannel0,debug=0,name=vdagent
	# WEBDAV
	#-device virtserialport,chardev=charchannel1,id=channel1,name=org.spice-space.webdav.0 
	#-chardev spiceport,name=org.spice-space.webdav.0,id=charchannel1
	# STREAM
	-device virtserialport,chardev=charchannel2,id=channel2,name=org.spice-space.stream.0 \
	-chardev spiceport,name=org.spice-space.stream.0,id=charchannel2
)

QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "spice", "password": "secret" } }'
)
