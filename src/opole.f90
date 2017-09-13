module opole
use printer_mod, only:printer
use data_types, only: dp, pi

implicit none

!call main()

contains !/////////////////



subroutine octupole_tensor(cec,cer2,charges,oct)
    !integer, parameter   :: xyz=3,hho=3
    !real(dp), intent(in) :: cec(xyz,hho),cer2(hho),charges(hho)
    integer, parameter   :: xyz=3
    real(dp), intent(in) :: cec(:,:),cer2(:),charges(:) !xyz,sites;sites;sites
    real(dp), intent(out) :: oct(xyz,xyz,xyz)
    ! internal:
    real(dp) ch05
    integer i
    integer nsites
    nsites = size(charges)
    
    ! _linearly_indipendent_ octupole components added up from each charge site
    oct=0
    do i = 1,nsites!hho 
      ch05 = charges(i)*0.5_dp
      oct(1,1,1) = oct(1,1,1) + ch05*( 5_dp*cec(1,i)**3 - cer2(i)*(3*cec(1,i)) )
      oct(2,2,2) = oct(2,2,2) + ch05*( 5_dp*cec(2,i)**3 - cer2(i)*(3*cec(2,i)) )
      oct(3,3,3) = oct(3,3,3) + ch05*( 5_dp*cec(3,i)**3 - cer2(i)*(3*cec(3,i)) )
      oct(1,1,2) = oct(1,1,2) + ch05*( 5_dp*cec(1,i)**2*cec(2,i) - cer2(i)*(cec(2,i)) )
      oct(1,1,3) = oct(1,1,3) + ch05*( 5_dp*cec(1,i)**2*cec(3,i) - cer2(i)*(cec(3,i)) )
      oct(1,2,2) = oct(1,2,2) + ch05*( 5_dp*cec(1,i)*cec(2,i)**2 - cer2(i)*(cec(1,i)) )
      oct(1,2,3) = oct(1,2,3) + ch05*( 5_dp*cec(1,i)*cec(2,i)*cec(3,i) - 0.0_dp )
    enddo
    
    ! remaining _unique_ components from traceless condition
    oct(1,3,3) = -( oct(1,1,1) + oct(1,2,2) )  
    oct(2,3,3) = -( oct(1,1,2) + oct(2,2,2) )
    oct(2,2,3) = -( oct(1,1,3) + oct(3,3,3) )
    
    ! symmetrize 
    
    ! a,a,b:
    oct(1,2,1) = oct(1,1,2)
    oct(2,1,1) = oct(1,1,2)
    oct(1,3,1) = oct(1,1,3)
    oct(3,1,1) = oct(1,1,3)
    oct(2,1,2) = oct(1,2,2)
    oct(2,2,1) = oct(1,2,2)
    oct(3,1,3) = oct(1,3,3)
    oct(3,3,1) = oct(1,3,3)
    oct(3,2,3) = oct(2,3,3)
    oct(3,3,2) = oct(2,3,3)
    oct(2,3,2) = oct(2,2,3)
    oct(3,2,2) = oct(2,2,3)
    
    ! a,b,c:
    oct(1,3,2) = oct(1,2,3)
    oct(2,1,3) = oct(1,2,3)
    oct(2,3,1) = oct(1,2,3)
    oct(3,1,2) = oct(1,2,3)
    oct(3,2,1) = oct(1,2,3)
    

    
    ! o0(3,3,3) - oct(3,3,3) = ~1e-5 since o0 is not perfectrly traceless. 
    
end subroutine

subroutine octupole_charges(cec,cer2,charges)
    integer, parameter    :: xyz=3,hho=3
    real(dp), intent(in)  :: cec(xyz,hho),cer2(hho)
    real(dp), intent(out) :: charges(hho)
    
    charges = [ 0.45874068338048468_dp, 0.45874068338048468_dp, 3.5561989864075145_dp ] !hho
end subroutine

subroutine get_octupoles(cec,cer2,oct,nM)
    integer, intent(in)   :: nM
    integer, parameter    :: xyz=3,hho=3
    real(dp), intent(in)  :: cec(xyz,hho,nM),cer2(hho,nM)
    real(dp), intent(out) :: oct(xyz,xyz,xyz,nM)
    !internal:
    real(dp) :: one_cec(xyz,hho), one_cer2(hho), one_oct(xyz,xyz,xyz), charges(hho)
    integer m
    
    do m = 1,nM
      one_cec  = cec(:,:,m) !single <- all
      one_cer2 = cer2(:,m)  !single <- all
      
      call octupole_charges(one_cec,one_cer2,charges)
      call octupole_tensor(one_cec,one_cer2,charges,one_oct)
      
      oct(:,:,:,m) = one_oct !all <- single
      
    enddo
    
end subroutine

end module