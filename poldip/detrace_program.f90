!!!!#define call test(A)

program slkdjf
use detrace_mod !, only:test
!integer, parameter :: dp = kind(0d0)
integer i


#ifdef RUN_TEST
call test()
#endif


#ifdef HEXAD 
integer, parameter :: le=15
real(dp) tricorn(le)
do i = 1,le
  read(*,*) tricorn(i)
enddo
call detrace_hexadeca(tricorn,.false.)
do i = 1,le
  print*, tricorn(i)
enddo
#endif

#ifdef OCTA 
integer, parameter :: le=10
real(dp) tricorn(le)
do i = 1,le
  read(*,*) tricorn(i)
enddo
call detrace_octa(tricorn,.false.)
do i = 1,le
  print*, tricorn(i)
enddo
#endif

#ifdef GENERAL
integer, parameter :: maxl=16
real(dp) tricorn(maxl)
integer le, vari
do i = 1,maxl
  read(*,*,iostat=vari) tricorn(i)
  if(vari<0)then
    le = i-1
    exit
  endif
enddo
call detrace(tricorn(1:le))
do i = 1,le
  print*, tricorn(i)
enddo
#endif

#ifdef STUPID
print*, size([1.0,2.0]), size([1.0]) !, size(5.0)
#endif
end program