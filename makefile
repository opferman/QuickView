
all:
   cd cmd
   nmake 
   cd ..
   cd gui
   nmake 
   cd ..

clean:
   cd cmd
   nmake clean
   cd ..
   cd gui
   nmake clean
   cd ..
