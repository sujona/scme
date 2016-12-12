# **********************************************************************************************************************************
# settings

# disable the built-in (implicit) rules to avoid trying to compile X.o from X.mod (Modula-2 program)
.SUFFIXES:

B = build
#MODDIR = obj/
SRCDIR = src

vpath %.f90 $(SRCDIR)
vpath %.cpp $(SRCDIR)

FC = gfortran
CC = g++
opti = -Ofast -ftree-vectorize -ftree-loop-if-convert -ftree-loop-distribution -march=native -fopenmp -finline-functions
# -Ofast
FFLAGS = $(opti) -pg -I$(B) -J$(B)
CFLAGS = $(opti) -I$(B) -J$(B) -lstdc++
#-fopenmp
#-floop-unroll-and-jam -ftree-loop-if-convert
vect = -ftree-vectorize -ftree-loop-if-convert -ftree-loop-distribution

OBJ = $(addprefix $(B)/, \
	scme.o calc_derivs.o calc_higher_order.o \
	data_types.o parameters.o max_parameters.o \
	multipole_parameters.o polariz_parameters.o \
	calcEnergy_mod.o calc_lower_order.o \
	inducePoles.o forceCM_mod.o torqueCM_mod.o \
	atomicForces_mod.o molforce.o tang_toennies.o mdutil.o \
	molecProperties.o dispersion_mod.o coreInt_mod.o rho.o ps.o)
#OBJC = $(addprefix $(OBJDIR)/, ps.o)
HEADERS = $(addprefix $(B)/, constants.h ps.h)

#all: $(B)/scme.o
all:
	make -j1 it

it:$(B)/libscme.a

# **********************************************************************************************************************************

# linking
#

# library
$(B)/libscme.a: $(OBJ)
	ar rcs $@ $^

# compiling

#$(B)/.f90.o:
#	$(FC) $(FFLAGS) -c -o $@ $<

#$(B)/.cpp.o: $(HEADERS)
#	$(CC) $(CFLAGS) -c -o $@ $<

$(B)/%.o: %.f90
	$(FC) $(FFLAGS) -c -o $@ $<


$(B)/%.mod: %.f90 
	$(FC) $(FFLAGS) -c $<



$(B)/%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<


#clean:

######################################### Dependencies:
# Single depdenden --- multiple prerequisites:

$(B)/scme.o:		\
$(B)/calc_derivs.mod		\
$(B)/data_types.mod		\
$(B)/max_parameters.mod	\
$(B)/parameters.mod		\
$(B)/polariz_parameters.mod	\
$(B)/molecProperties.mod	\
$(B)/calc_lower_order.mod	\
$(B)/calc_higher_order.mod	\
$(B)/inducePoles.mod		\
$(B)/forceCM_mod.mod		\
$(B)/torqueCM_mod.mod	\
$(B)/atomicForces_mod.mod	\
$(B)/calcEnergy_mod.mod	\
$(B)/coreInt_mod.mod		\
$(B)/dispersion_mod.mod	\
$(B)/multipole_parameters.mod\

$(B)/atomicForces_mod.o:	\
$(B)/data_types.mod		\
$(B)/max_parameters.mod	\
$(B)/molforce.mod		\


$(B)/molforce.o:	\
$(B)/data_types.mod	\
$(B)/mdutil.mod	\

$(B)/coreInt_mod.o:	\
$(B)/data_types.mod		\
$(B)/max_parameters.mod	\
$(B)/parameters.mod 		\
$(B)/rho.mod			\

$(B)/rho.o:		\
$(B)/data_types.mod		\
$(B)/max_parameters.mod	\
$(B)/parameters.mod		\

$(B)/molecProperties.o:	\
$(B)/data_types.mod		\
$(B)/max_parameters.mod 	\
$(B)/tang_toennies.mod	\

$(B)/tang_toennies.o:	\
$(B)/data_types.mod		\
$(B)/parameters.mod		\



# multiple dependents --- few prerequisite:
$(B)/mdutil.o		\
$(B)/polariz_parameters.o	\
$(B)/multipole_parameters.o\
$(B)/max_parameters.o	\
$(B)/parameters.o		\
:$(B)/data_types.mod		\


$(B)/dispersion_mod.o	\
$(B)/torqueCM_mod.o	\
$(B)/forceCM_mod.o		\
$(B)/inducePoles.o		\
$(B)/calcEnergy_mod.o	\
:$(B)/data_types.mod		\
$(B)/max_parameters.mod	\


$(B)/calc_derivs.o		\
$(B)/calc_lower_order.o	\
$(B)/calc_higher_order.o	\
:$(B)/data_types.mod		\
$(B)/max_parameters.mod	\
$(B)/molecProperties.mod	\


# **********************************************************************************************************************************
# module dependencies

#$(OBJDIR)/parameters.o: $(OBJDIR)/data_types.o
#
#$(OBJDIR)/tang_toennies.o: $(OBJDIR)/parameters.o
#
#$(OBJDIR)/rho.o:$(OBJDIR)/parameters.o
#
#$(OBJDIR)/scme.o: $(addprefix $(OBJDIR)/, data_types.o parameters.o max_parameters.o multipole_parameters.o polariz_parameters.o \
#	molecProperties.o calc_higher_order.o calc_lower_order.o calc_derivs.o inducePoles.o forceCM_mod.o \
#	torqueCM_mod.o atomicForces_mod.o calcEnergy_mod.o coreInt_mod.o dispersion_mod.o ps.o)
#
#$(OBJDIR)/molecProperties.o: $(OBJDIR)/data_types.o $(OBJDIR)/max_parameters.o $(OBJDIR)/tang_toennies.o
#
#$(OBJDIR)/calc_higher_order.o: $(OBJDIR)/data_types.o $(OBJDIR)/max_parameters.o $(OBJDIR)/molecProperties.o
#
#$(OBJDIR)/calc_lower_order.o: $(OBJDIR)/data_types.o $(OBJDIR)/max_parameters.o $(OBJDIR)/molecProperties.o
#
#$(OBJDIR)/calc_derivs.o: $(OBJDIR)/data_types.o $(OBJDIR)/max_parameters.o $(OBJDIR)/molecProperties.o
#
#$(OBJDIR)/coreInt_mod.o: $(OBJDIR)/data_types.o $(OBJDIR)/max_parameters.o $(OBJDIR)/parameters.o $(OBJDIR)/rho.o
#
#$(OBJDIR)/atomicForces_mod.o: $(OBJDIR)/data_types.o $(OBJDIR)/max_parameters.o $(OBJDIR)/molforce.o
#
#$(OBJDIR)/molforce.o: $(OBJDIR)/data_types.o $(OBJDIR)/mdutil.o

# **********************************************************************************************************************************
# cleanup

.PHONY: clean
clean:
	rm $(B)/*.o $(B)/*.a $(B)/*.mod


# **********************************************************************************************************************************
