mahout seqdirectory -i file://$(pwd)/bookreview \
	-o file://$(pwd)/bookreview_seq \
	-c UTF-8 -chunk 64 -xm sequential
