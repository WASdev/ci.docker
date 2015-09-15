.PHONY: all test clean

test:
	cd websphere-liberty/test && buildAll.sh input.txt
