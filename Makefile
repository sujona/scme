
bd:=build
srcdirs:=src devdir
ext:=f90

err:= -Wall -fcheck=all -g -fbacktrace -ffpe-trap=zero,overflow,underflow -fmax-errors=3
fflags:= $(opti) -pg -I$(bd) -J$(bd) -cpp  -ffree-line-length-0 $(err)
#-D'DEBUG_PRINTING'
fc:=gfortran


#Settings above. Furst run './prescan src devdir' to create the dependency file 'prerequisites.makefile'
#####################################################################
#####################################################################
vpath %.f90 $(srcdirs) 

srcs:= $(notdir $(wildcard $(srcdirs:=/*.$(ext))))

objects:= $(addprefix $(bd)/, $(srcs:%.$(ext)=%.o))

#####################################################################

all:
	make -j4 target


target: $(objects)
	@echo "objects are in $(bd) !!!"

$(bd)/%.o: %.f90
	@mkdir -p $(bd)
	$(fc) $(fflags) -o $@ -c $<

clean:
	rm -rf $(bd)

#####################################################################

include prerequisites.makefile




