all:
	cd wxc
	make
	cd ..
	cd wx
	make
	cd ..

test:
	cd Samples
	make
	cd ..

clean:
	cd wx
	make clean
	cd ..
	cd wxc
	make clean
	cd ..
	cd Samples
	make clean
	cd ..

