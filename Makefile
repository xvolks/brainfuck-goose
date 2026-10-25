all: bf.goose
	ret=0; \
	goose build -O2 bf.goose || ret=$$?; \
	if [ $$ret -eq 127 ]; then \
		../../goose build -O2 bf.goose; \
	fi
