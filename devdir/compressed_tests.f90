module compressed_tests

use compressed_arrays
use compressed_tensors, bad=>main
use compressed_utils, bad=>main
use calcEnergy_mod, only:multipole_energy
use inducePoles,only: induce_dipole, induce_quadrupole
use detrace_apple, bad=>main

use polariz_parameters

use calc_derivs, only:calcDv
use calc_higher_order, only:octu_hexaField


implicit none


contains !//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

subroutine main
call suit
end subroutine

subroutine suit
    
    !call get_traces
    call test_sumfac
    !call test_nextpow(7)
    !call test_nextpow_v_wn(10)

    
    !call test_subdiv_pow_h(5,5) too high rank
    call test_subdiv_pow_h(4,3)
    call test_subdiv_pow_h(3,4)
    
    call test_next_set2pown(4,1)
    call test_sorted
    call test_expand_compress
    call test_brakk
    call test_nextpown
    call test_next_pown
    call print_trace_keys
    
    call h_testing
    call test_hhh(3,4)
    
    call test_inner_symouter
    call test_inner
    call test_symouter
    
    call test_old_field
    call test_potgrad
    call test_mp_pot
    
    call printa(tmm_,0)
    call printa(mm_,0,0)
    call printa(mm_,0,1)
    call printa([1,2,3,4,5,6,77,7777,777,9],0,0)
    !call test_intfac_ff!takes two command line arguments
    
    call test_fac(5)
    call test_choose
    
    call print_long_index_matrix (6)
    call print_square_index_matrix (6)
    
    call test_matr(7)
    call test_apple_g
    
    call test_rrr
    
    call test_polyfinder
    call test_polydet
    call test_detracers
    call test_detracer_linearity
    call test_polynextpow_n
    
    print*
    print*, '------------------------------------------------------------'
    print*, 'ABOVE: all_tests -------------------------------------------'
    print*, '------------------------------------------------------------'

end subroutine
    

!subroutine test_system_polarize
    
    

subroutine test_next_lex_and_can
    !this routine tests the routines that produces the next full or compressed tensor index set, not the powers. 
    integer set1(4),set2(4), i,n, pown1(3),pown2(3)
    n=4
    set1 = [1,1,1,1]
    set2 = [1,1,1,1]
    do i=1,3**4
        if(i>1)then
            set1 = next_lex(set1,1)
            set2 = next_can(set2,1)
            
        endif
        pown1 = set2pown(set1)
        pown2 = set2pown(set2)
        print*, "pown1",pown1
        print*, "set1: "//str(set1)//" has pow "//str(pown1)//";  set2: "//str(set2)//" has pow: "//str(pown2)//" which is again the set "//str(pown2set(pown1))
    enddo
end

subroutine test_polyfinder
    integer nn(3), i, n, it
    it = 0
    print*, "key, pos, finder, polyf, it, polyf-it "
    do n = 0, 7
        nn=[n,0,0]
        do i = 1, len_(n)
            if (i>1)call nextpown(nn)
            it = it+1
            print'(a,*(I4))'," ["//str(nn)//"]",pos_(n), finder(nn), polyfind(nn), it, polyfind(nn)-it
        enddo
    enddo
    print*, str(pos_)
end


        

subroutine test_printoa
    integer :: mati(5,4), veci(10)
    real(dp) :: matr(5,4), vecr(10)
    
    
    
    
    call random_number(matr)
    call random_number(vecr)
    
    call printa(nint(10*matr),0 ,0,"hey")
    call printa(10*matr,0,t="hey")
    
    
    call printa(nint(10*vecr),0 ,0,"hey")
    call printa(10*vecr,t="hey")
    
    
end

subroutine test_compress_expand_subdivided
    
    integer, parameter :: nm=1, m=1
    integer p1,p2, pp, i1, i2, i3
    real(dp) :: p11f(3,3,nm),p12f(3,3,3,nm),p21f(3,3,3,nm), p22f(3,3,3,3,nm)
    real(dp) :: p11c(3,3,nm),p12c(3,6,nm),p21c(6,3,nm), p22c(6,6,nm),pp2(10,10,nm), dq(10,nm) , dqs(10,nm)
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,43,4,3,5,23,345,34000])
    call random_number(p11f)
    call random_number(p12f)
    call random_number(p22f)
    
    call symmetrize_p(p11f(:,:,m), p12f(:,:,:,m),p22f(:,:,:,:,m))
    
    do i3=1,3
        do i2 = 1,3
            do i1 = 1,3
                p21f(i2,i3,i1,m) = p12f(i1,i2,i3,m)
            enddo
        enddo
    enddo
    !call printo(p12f(:,:,:,m),order=[2,3,1])
    !call printo(p21f(:,:,:,m),order=[1,2,3])
    
    call polycompress_p(p11f(:,:,m), p12f(:,:,:,m),p22f(:,:,:,:,m),pp2(:,:,m))
    
    !call printa(pp2(:,:,m))
    
    Print*
    Print*, "TEST COMPRESSION: ___________________________________________________"
    
    !p12
    p1=1;p2=2
    pp=p1+p2
    !call compress_subdivided(reshape(p12f(:,:,:,m),[3**pp]),p12c(:,:,m),pp,p1,p2)
    p12c(:,:,m) = compress_subdivided(reshape(p12f(:,:,:,m),[3**pp]),p1,p2)
    
    call printa( pp2(pos_(p1)+1:pos_(p1+1),pos_(p2)+1:pos_(p2+1),m) )
    call printa(p12c(:,:,m))
    print*
    print*, "diff:"
    call printa(pp2(pos_(p1)+1:pos_(p1+1),pos_(p2)+1:pos_(p2+1),m) - p12c(:,:,m))
    
    
    !p21
    p1=2;p2=1
    pp=p1+p2
    !call compress_subdivided(reshape(p21f(:,:,:,m),[3**pp]),p21c(:,:,m),pp,p1,p2)
    p21c(:,:,m) = compress_subdivided(reshape(p21f(:,:,:,m),[3**pp]),p1,p2)
    
    call printa(pp2(pos_(p1)+1:pos_(p1+1),pos_(p2)+1:pos_(p2+1),m))
    call printa(p21c(:,:,m))
    print*
    print*, "diff:"
    call printa( pp2(pos_(p1)+1:pos_(p1+1),pos_(p2)+1:pos_(p2+1),m) - p21c(:,:,m))
    
    !p22
    p1=2;p2=2
    pp=p1+p2
    !call compress_subdivided(reshape(p22f(:,:,:,:,m),[3**pp]),p22c(:,:,m),pp,p1,p2)
    p22c(:,:,m) = compress_subdivided(reshape(p22f(:,:,:,:,m),[3**pp]),p1,p2)
    
    call printa(pp2(pos_(p1)+1:pos_(p1+1),pos_(p2)+1:pos_(p2+1),m))
    call printa(p22c(:,:,m))
    print*
    print*, "diff:"
    call printa( pp2(pos_(p1)+1:pos_(p1+1),pos_(p2)+1:pos_(p2+1),m) - p22c(:,:,m) )
    
    
    Print*
    Print*, "TEST EXPANSION: _______________________________________________________"
    Print*
    
    print*
    print*, "original 12:"
    call printo( p12f(:,:,:,m))
    print*
    print*, "new 12:"
    call printo( reshape(expand_subdivided(p12c(:,:,m),1,2),shape=[3,3,3]) )
    print*
    print*, "diff 12:"
    call printo( p12f(:,:,:,m) - reshape(expand_subdivided(p12c(:,:,m),1,2),shape=[3,3,3]) )
    
    print*
    print*, "ONLY DIFFS:"
    
    print*
    print*, "diff 21:"
    call printo( p21f(:,:,:,m) - reshape(expand_subdivided(p21c(:,:,m),2,1),shape=[3,3,3]) )
    
    print*
    print*, "diff 22:"
    call printo( p22f(:,:,:,:,m) - reshape(expand_subdivided(p22c(:,:,m),2,2),shape=[3,3,3,3]) )
    
    
    
    
end
    

subroutine test_polarize
    integer, parameter :: nm=3
    real(dp) :: q1c(3,nm),q2c(6,nm), q3c(10,nm), q4c(15,nm)
    real(dp) :: f1c(3,nm),f2c(10,nm)!, f3c(10,nm), f4c(15,nm)
    real(dp) :: p11c(3,3,nm),p12c(3,6,nm), p22c(6,6,nm),pp2(10,10,nm), dq(10,nm) , dqs(10,nm)
    
    real(dp) :: q1f(3,nm),q2f(3,3,nm),dq1f(3,nm),dq2f(3,3,nm), q3f(3,3,3,nm), q4f(3,3,3,3,nm)
    real(dp) :: f1f(3,nm),f2f(3,3,nm)!, f3f(3,3,3,nm), f4f(3,3,3,3,nm)
    real(dp) :: p11f(3,3,nm),p12f(3,3,3,nm), p22f(3,3,3,3,nm),p111f(3,3,3,nm)
    integer m
    real(dp) f12(10,nm)
    !real(dp), dimension(pos_(4+1),2) qn_perm, qn_ind,qn_del,qn_tot, fn
    
    
    
    logical*1 converged
    
    integer nn
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,43,4,3,5,23,345,34000])
    
    !compressed random fileds
    call random_number(f1c)
    call random_number(f2c(:6,:))
    !call random_number(f3c)
    !call random_number(f4c)
    
    
    !full non-symmetrized polarizability
    call random_number(p11f)
    call random_number(p12f)
    call random_number(p22f)
    
    do m = 1,nm
        !create full random fields
        f12(:,m) = [0d0,f1c(:,m),f2c(:6,m)]
        
        f1f(:,m)=f1c(:,m)
        f2f(:,:,m)=reshape(expand(f2c(:6,m),2),[3,3])
        !f3f(:,:,:,m)=reshape(expand(f3c(:,m),3),[3,3,3])
        !f4f(:,:,:,:,m)=reshape(expand(f4c(:,m),4),[3,3,3,3])
        
        ! Create full polarizabilities
        call symmetrize_p(p11f(:,:,m), p12f(:,:,:,m),p22f(:,:,:,:,m))
        
        
        call polycompress_p(p11f(:,:,m), p12f(:,:,:,m),p22f(:,:,:,:,m),pp2(:,:,m))
        
        
        ! Print to see
        !print*, "f2f:";call printo(f2f(:,:,m) )
        !print*, "f3f:";call printo(f3f(:,:,:,m) )
        !print*, "f4f:";call printo(f4f(:,:,:,:,m) )
        !
        !
        !print*, "p11f:";call printo(p11f(:,:,m) )
        !print*, "p12f:";call printo(p12f(:,:,:,m) )
        !print*, "p22f:";call printo(p22f(:,:,:,:,m) )
        
        
        call printa(pp2(:,:,m),t="Polarizability matrix")
    enddo
    
    !make hyperpolarizability and permanent poles zero
    p111f=0
    q1f=0
    q2f=0
    q3f=0
    q4f=0
    
    
    call induce_dipole(dq1f, q1f, f1f, f2f, p11f, p12f, p111f, nm, converged)
    call induce_quadrupole(dq2f, q2f, f1f, f2f, p12f, p22f, nm, converged)
    
    dqs=0
    call system_polarize_stone(pp2,f12,dqs)
    
    
    do m = 1,nm
        
        !print*, "q1f:"; call printo( q1f(:,m) )
        !print*, "dq1f:";call printo(dq1f(:,m) )
        !
        !print*, "q2f:"; call printo( q2f(:,:,m) )
        !print*, "dq2f:";call printo(dq2f(:,:,m) )
        
        dq=0
        call polarize_stone(pp2(:,:,m),[0d0,f1c(:,m),f2c(:6,m)],dq(:,m))
        
        print*, "mol nr. "//str(m)//":"
        print*, "scme dq:", [0d0, dq1f(:,m), compress(reshape(dq2f(:,:,m),[3**2]),2) ]
        print*, "ston dq:", dq(:,m)
        print*, "syss dq:", dqs(:,m)
        
    enddo
    
    
    ! test stone field!!!
    
    !call printa( [0d0, dq1f(:,1), compress(reshape(dq2f,[3**2]),2) ])
    !call printa( dq)
    !call multipole_energy(q1f, q2f, q3f, q4f, f1f, f2f, f3f, f4f, 1, uTot)
    !call multipole_energy(q1f, q2f, q3f, q4f, f1f, f2f, f3f, f4f, 1, uTot)
    
    
end


subroutine test_polarize2
    !compressed
    real(dp) p12c(3,6),p21c(6,3), p22c(6,6)
    real(dp) v2c(6)
    real(dp) alp(pos_(2+1),pos_(2+1))
    real(dp), dimension(pos_(2+1)) :: poly_mp, poly_pot 
    !integer s1,f1,s2,f2
    
    
    !full
    real(dp) q1f(3), q2f(3,3) 
    real(dp) v1f(3), v2f(3,3)
    real(dp) p11f(3,3), p12f(3,3,3),p22f(3,3,3,3)
    
    real(dp) q1c_f(3), q2c_f(6)
    
    
    ! CREATE POLARIZABILITIES
    call random_number(p11f)
    call random_number(p12f)
    call random_number(p22f)

    
    call symmetrize_p(p11f,p12f,p22f)
    print*, "nonsymmetry of polarizations:", test_polz_symmetry(p11f,p12f,p22f)
    
    call compress_p(p22f,p12f, p22c,p12c,p21c)
    call polycompress_p(p11f, p12f,p22f,alp)
    
    
    ! CREATE POTENTIAL
    call random_number(v1f)
    call random_number(v2f)
    v2f = (v2f + transpose(v2f) )/2d0
    v2c = compress(reshape(v2f,[3**2]),2)
    poly_pot = [0d0,v1f,v2c]
    
    
    
    !POLARIZE FULL
    call polarize_full(p11f, p12f,p22f,v1f,v2f, q1f,q2f)
    
    q2c_f=compress(reshape(q2f,[3**2]),2)
    
    
    !POLARIZE COMRESSED
    poly_mp = matmul(alp,poly_pot*gg_(1:10))
    
    
    !PRINT induced poles:
    print*, "induced poles by FULL tensors:"
    call printa([0d0,q1f,q2c_f])
    
    
    print*, "induced poles by COMPRESSED tensors:"
    call printa(poly_mp)
    
    
end

subroutine polycompress_p(p11f,p12f,p22f,alp)
    real(dp), intent(in) :: p22f(3,3,3,3), p12f(3,3,3),p11f(3,3)
    real(dp), intent(out) ::  alp(10,10)!
    real(dp) p22c(6,6), p12c(3,6), p21c(6,3)
    !real(dp) :: 
    
    integer i1,i2,i3,i4,  j1,j2
    integer k1a,k1b,k2a,k2b
    !integer s1,f1,s2,f2
    
    !p12c=10
    !do i1=1,3
    !    j2=0
    !    do i2=1,3
    !        do i3=i2,3
    !            j2=j2+1
    !            p12c(i1,j2) = p12f(i1,i3,i2)
    !        enddo
    !    enddo
    !enddo
    
    p12c = compress_subdivided(reshape(p12f,[3**3]),1,2)
    
    p21c=transpose(p12c)

    
    !j1=0
    !do i1=1,3
    !    do i2=i1,3
    !        j1=j1+1
    !        j2=0
    !        do i3=1,3
    !            do i4=i3,3
    !                j2=j2+1
    !                p22c(j1,j2) = p22f(i1,i2,i3,i4)
    !            enddo
    !        enddo
    !    enddo
    !enddo
    p22c = compress_subdivided(reshape(p22f,[3**4]),2,2)
    
    
    alp(:,1)=0
    alp(1,:)=0
    
    k1a = pos_(1)+1
    k1b = pos_(1+1)
    k2a = pos_(2)+1
    k2b = pos_(2+1)
    
    alp(k1a:k1b,k1a:k1b)=p11f
    alp(k1a:k1b,k2a:k2b)=p12c
    alp(k2a:k2b,k1a:k1b)=p21c
    alp(k2a:k2b,k2a:k2b)=p22c
    
    !s1 = pos_(1)+1
    !f1 = pos_(1+1)
    !s2 = pos_(2)+1
    !f2 = pos_(2+1)
    !
    !alp=0
    !alp(s1:f1,s1:f1)=p11f
    !alp(s1:f1,s2:f2)=p12c
    !alp(s2:f2,s1:f1)=p21c
    !alp(s2:f2,s2:f2)=p22c
    
    
    
    
end



subroutine polarize_full(p11f, p12f,p22f,v1f,v2f, q1f,q2f)
    real(dp), intent(in) :: p11f(3,3), p12f(3,3,3),p22f(3,3,3,3)
    real(dp), intent(in) :: v1f(3), v2f(3,3)
    real(dp) :: q11f(3),q12f(3),q21f(3,3),q22f(3,3)
    real(dp), intent(out) ::  q1f(3),q2f(3,3)
    integer i1,i2,i3,i4
    
    q11f = 0
    q12f = 0
    q21f = 0
    q22f = 0
    do i1=1,3
        do i2=1,3
            q11f(i1) = q11f(i1) + p11f(i1,i2)*v1f(i2)
            do i3=1,3
                q12f(i1) = q12f(i1) + p12f(i1,i2,i3)*v2f(i2,i3)
                q21f(i2,i3) = q21f(i2,i3) + p12f(i1,i2,i3)*v1f(i1)
                do i4=1,3
                    q22f(i1,i2) = q22f(i1,i2) + p22f(i1,i2,i3,i4)*v2f(i3,i4)
                enddo
            enddo
        enddo
    enddo
    
    q1f=q11f+q12f
    q2f=q21f+q22f
end


subroutine symmetrize_p(p11f, p12f,p22f)
    real(dp), intent(inout) :: p11f(3,3), p12f(3,3,3),p22f(3,3,3,3)
    real(dp)                :: p11f_d(3,3), p12f_d(3,3,3),p22f_d(3,3,3,3)
    integer i1,i2,i3,i4
    p11f_d=p11f; p12f_d=p12f; p22f_d=p22f
    
    do i1=1,3 !symmetrize a,A,B
        do i2=1,3
            p11f(i1,i2) = ( p11f_d(i1,i2) + p11f_d(i2,i1) )/2d0
            do i3=1,3
                p12f(i1,i2,i3) = (p12f_d(i1,i2,i3)+p12f_d(i1,i3,i2))/2d0
                do i4=1,3
                    p22f(i1,i2,i3,i4) = ( p22f_d(i4,i3,i2,i1) + p22f_d(i3,i4,i2,i1) + p22f_d(i4,i3,i1,i2) + p22f_d(i3,i4,i1,i2)   +   p22f_d(i2,i1,i4,i3) + p22f_d(i2,i1,i3,i4) + p22f_d(i1,i2,i4,i3) + p22f_d(i1,i2,i3,i4) )/8d0
                enddo
            enddo
        enddo
    enddo
end


subroutine compress_p(p22f,p12f, p22c,p12c,p21c)
    real(dp), intent(in) :: p22f(3,3,3,3), p12f(3,3,3)
    real(dp), intent(out) :: p22c(6,6), p12c(3,6), p21c(6,3)
    !real(dp) :: 
    
    integer i1,i2,i3,i4,  j1,j2
    
    p12c=10
    do i1=1,3
        j2=0
        do i2=1,3
            do i3=i2,3
                j2=j2+1
                p12c(i1,j2) = p12f(i1,i3,i2)
            enddo
        enddo
    enddo
    
    p21c=transpose(p12c)

    
    j1=0
    do i1=1,3
        do i2=i1,3
            j1=j1+1
            j2=0
            do i3=1,3
                do i4=i3,3
                    j2=j2+1
                    p22c(j1,j2) = p22f(i1,i2,i3,i4)
                enddo
            enddo
        enddo
    enddo
    
end

function test_polz_symmetry(p11,p12,p22) result(su)
    integer i1,i2,i3,i4
    real(dp), dimension(3,3) :: p11b,p11
    real(dp), dimension(3,3,3) :: p12,p12b
    real(dp), dimension(3,3,3,3) :: p22,p22b1, p22b2, p22b3, p22b4, p22b5, p22b6, p22b7, p22b8
    real(dp) su
    ! test if htey have the right symmetry
    do i1=1,3
        do i2=1,3
            p11b(i1,i2) = p11(i1,i2) - p11(i2,i1) 
            do i3=1,3
                p12b(i1,i2,i3) = p12(i1,i2,i3) - p12(i1,i3,i2) 
                do i4=1,3
                    p22b1(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i2,i1,i3,i4)
                    p22b2(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i1,i2,i4,i3)
                    p22b3(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i2,i1,i4,i3)
                    p22b4(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i3,i4,i1,i2)
                    p22b5(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i3,i4,i2,i1)
                    p22b6(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i4,i3,i1,i2)
                    p22b7(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i4,i3,i2,i1)
                    p22b8(i1,i2,i3,i4) = p22(i1,i2,i3,i4) - p22(i1,i2,i3,i4)
                enddo
            enddo
        enddo
    enddo
    
    su = 0
    do i1=1,3
        do i2=1,3
            su = su + p11b(i1,i2)**2
            do i3=1,3
                su = su + p12b(i1,i2,i3)**2
                do i4=1,3
                    su = su + p22b1(i1,i2,i3,i4)**2 
                    su = su + p22b2(i1,i2,i3,i4)**2 
                    su = su + p22b3(i1,i2,i3,i4)**2 
                    su = su + p22b4(i1,i2,i3,i4)**2 
                    su = su + p22b5(i1,i2,i3,i4)**2 
                    su = su + p22b6(i1,i2,i3,i4)**2 
                    su = su + p22b7(i1,i2,i3,i4)**2 
                    su = su + p22b8(i1,i2,i3,i4)**2 
                enddo
            enddo
        enddo
    enddo
end




    
    


subroutine test_stone_field
    real(dp) :: q1c(3),q2c(6), q3c(10), q4c(15)
    real(dp) :: q1cc(3),q2cc(6), q3cc(10), q4cc(15)
    real(dp) :: f1c(3),f2c(6), f3c(10), f4c(15),ff4c(pos_(4+1)), ff4b(pos_(4+1),2)
    
    real(dp) :: q1f(3,1),q2f(3,3,1),dq1f(3,1),dq2f(3,3,1), q3f(3,3,3,1), q4f(3,3,3,3,1)
    real(dp) :: f1f(3,1),f2f(3,3,1), f3f(3,3,3,1), f4f(3,3,3,3,1)
    
    integer, parameter :: nx=4,kx=4,nkx=nx+kx
    integer k1,k2,n1,n2, p1,p2
    real(dp) :: sss(2*nkx), rr(3),r2
    real(dp), dimension(pos_(2*nkx+1)) :: rrr,df
    
    call random_number(q1c)
    call random_number(q2c)
    call random_number(q3c)
    call random_number(q4c)
    call random_number(rr)
    
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,43,4,3,5,23,345,34000])
        
    q1f(:,1)=q1c
    q2f=reshape(expand(q2c,2),shape(q2f))
    q3f=reshape(expand(q3c,3),shape(q3f))
    q4f=reshape(expand(q4c,4),shape(q4f))
    
    
    call printa(q2c,t="q2c")
    call printa(q3c,t="q3c")
    call printa(q4c,t="q4c")
        
    !print*, "q2f:";call printo(q2f(:,:,1)     )
    !print*, "q3f:";call printo(q3f(:,:,:,1)   )
    !print*, "q4f:";call printo(q4f(:,:,:,:,1) )
    
    
    r2=sum(rr**2)
    call vector_powers(nkx,rr,rrr)!(k,r,rr) 
    !call dfdu_erf(1.6_dp,r2,nkx,sss)!(a,u,nmax,ders) 
    call dfdu(r2,nkx,sss) 
    call lin_polydf(nkx,rrr,sss,df)!(nmax,rrr,sss,df)    
    
    
    q1cc=0;q2cc=0;q3cc=0;q4cc=0;
    
    print*, "full"
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3c,q4c],df,ff4c,1,nx,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    print*
    print*, "q1=0"
    ff4c=0
    call add_stone_field([0d0,q1cc,q2c,q3c,q4c],df,ff4c,1,nx,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3c,q4c],df,ff4c,2,nx,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    print*
    print*, "q1,q2=0"
    ff4c=0
    call add_stone_field([0d0,q1cc,q2cc,q3c,q4c],df,ff4c,1,nx,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3c,q4c],df,ff4c,3,nx,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    print*
    print*, "q3,q4=0"
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3cc,q4cc],df,ff4c,1,nx,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3c,q4c],df,ff4c,1,2,1,kx)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    
    print*
    print*, "q3,q4=0, -> f1,f2"
    k1=1
    k2=2
    p1=pos_(0)+1
    p2=pos_(k2+1)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3cc,q4cc],df,ff4c,1,nx,1,2)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3c,q4c],df,ff4c,1,2,1,2)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    
    print*, "q3,q4=0, f1,f2"
    k1=1
    k2=2
    p1=pos_(0)+1
    p2=pos_(k2+1)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3cc,q4cc],df,ff4c,1,nx,k1,k2)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    print*, "q3,q4=0, f1,f2,f3"
    k1=1
    k2=3
    p1=pos_(0)+1
    p2=pos_(k2+1)
    
    ff4c=0
    call add_stone_field([0d0,q1c,q2c,q3c,q4c],df,ff4c,1,2,k1,k2)!(narr,dfarr,nn1,nn2,mm1,mm2)
    call printa(ff4c)
    
    
    
    !call calcDv(rCM, dpole, qpole, opole, hpole, nM, NC, a, a2, d1v, d2v, d3v, d4v, d5v, rMax2, fsf, iSlab,FULL)
    !call calcDv(rCM, q1f, q2f, q3f, q4f, 1, 1, a, a2, d1v, d2v, d3v, d4v, d5v, rMax2, fsf, iSlab,FULL)
    
    
   print*, 'ABOVE: test stone field -----------------------------------------------'
end


subroutine test_old_field
    integer, parameter :: nm = 2
    real(dp) dpole(3,nm), qpole(3,3,nm), opole(3,3,3,nm), hpole(3,3,3,3,nm) 
    real(dp) d1v(3,nm), d2v(3,3,nm), d3v(3,3,3,nm), d4v(3,3,3,3,nm), d5v(3,3,3,3,3,nm)
    real(dp) a(3), a2(3), rCM(3,nm), fsf(3,nm), rMax2, rMax
    
    real(dp) eT(3,nm), dEdr(3,3,nm), uH
    integer NC
    logical*1 iSlab
    logical FULL
    
    integer,parameter :: nx=4,kx=5
    real(dp) dipo(3), quad(6), octa(10), hexa(15)
    real(dp) qn(pos_(nx+1),nm),fk(pos_(kx+1),nm)
    
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    rMax = 100.1d0
    rMax2 = rMax**2
    rCM(:,1) = [0d0,0d0,0d0]
    !rCM(:,2) = [3.4231, 2.74389, 1.54739]
    rCM(:,2) = [1.4231, 1.24389, 1.54739]
    nc = 1
    a=40d0
    a2=a**2
    Full = .true. 
    iSlab = .false. 
    
    
    dpole=0
    qpole=0
    opole=0
    hpole=0
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34543])
    
    dipo = [2.345d0, -0.453245d0,0.6564256d0]
    
    dpole(:,1) = dipo
    
    call random_number(quad)
    quad=detracer(quad,2)
    qpole(:,:,1) = reshape(expand(quad,2),shape=[3,3])

    call random_number(octa)
    octa=detracer(octa,3)
    opole(:,:,:,1) = reshape(expand(octa,3),shape=[3,3,3])
    
    call random_number(hexa)
    hexa=detracer(hexa,4)
    hpole(:,:,:,:,1) = reshape(expand(hexa,4),shape=[3,3,3,3])
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    dipo=0;dpole=0
    quad=0;qpole=0
    !octa=0;opole=0
    !hexa=0;hpole=0
    
    
    qn(:,2)=0
    qn(:,1)=[0d0,dpole(:,1),quad,octa,hexa]
    
    call calcDv(rCM, dpole, qpole, opole, hpole, nM, NC, a, a2, d1v, d2v, d3v, d4v, d5v, rMax2, fsf, iSlab,FULL)
    
    print'(a,*(g30.15))','d-1',d1v(:,2)
    print'(a,*(g30.15))','d-2',compress( reshape(      d2v(:,:,2),shape=[3**2]),2)
    !print'(a,*(g30.15))','d-3',opdetr(compress( reshape(    d3v(:,:,:,2),shape=[3**3]),3),3)
    !print'(a,*(g30.15))','d-4',opdetr(compress( reshape(  d4v(:,:,:,:,2),shape=[3**4]),4),4)
    !print'(a,*(g30.15))','d-5',opdetr(compress( reshape(d5v(:,:,:,:,:,2),shape=[3**5]),5),5)
    
    
    print*,
    
    fk=0
    call system_stone_field(0,1d0,1,4,1,3,rCM,qn,fk)!(ni,nx,ki,kx,nM,rCM,qn,fk)
    !print'(a,*(g30.15))','fk1',fk(:,1)
    print'(a,*(g30.15))','fk2',fk(2:4,2)
    print'(a,*(g30.15))','fk2',fk(5:10,2)
    
    print*,
    
    
    call octu_hexaField(rCM, opole, hpole, nM, NC, a, a2, uH, eT, dEdr, rMax2, iSlab,full)
    print'(a,*(g30.15))','d-1',eT(:,2)
    print'(a,*(g30.15))','d-2',compress( reshape(      transpose(dedr(:,:,2)),shape=[3**2]),2)
    
    
    



    
    !print*,'d1v'
    !print'(1(g15.3))',d2v(:,:,2) !opdetr(compress( reshape(d1v(:,:,1),shape=[3**2]),2),2) !d2v(:,:,1) !
   
   print*, 'ABOVE: ---------------------test old field --------------------------'
     
end




subroutine test_intfac_ff
    integer a, b
    character(3) ach, bch
    call get_command_argument(1, ach)
    call get_command_argument(2, bch)
    
    read(ach,*) a
    read(bch,*) b
    
    !print*,'intfac', intfac(a,b)
    print*,'intff ', intff(a,b)
    
    print*, "above, TEST_INTFAC_FF ------------------------------------------------------------------"
    
end

subroutine test_polyinner
    integer, parameter :: mmax=7, nmax=7
    real(dp) qq(pos_(nmax+1)), ff(pos_(nmax+mmax+1)), phi(pos_(mmax+1))
    integer i , imax
    real(dp) scal
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34000])
    
    call  random_number(qq)
    call  random_number(ff)
    call  random_number(phi)
    
    
    print'(a,*(f10.5))','   qq', qq
    print*
    print'(a,*(f10.5))','   ff', ff
    print*
    
    phi = polyinner1(qq,ff,0,nmax,0,mmax)
    print'(a,*(f10.5))','   phi', phi
    phi=0
    
    phi = polyinner2(qq,ff,0,nmax,0,mmax)
    print'(a,*(f10.5))','   phi', phi
    
    
    phi=0
    phi = polyinner_matrix(qq,ff,0,nmax,0,mmax)
    print'(a,*(f10.5))','   phi', phi
    
    
    imax = 100000
    scal = 1d0/imax
    phi=0
    do i = 1,imax
        call  random_number(qq)
        call  random_number(ff)
        !phi =  phi + polyinner1(qq,ff,0,nmax,0,mmax)*scal
        !phi =  phi + polyinner_matrix(qq,ff,0,nmax,0,mmax)*scal
        phi =  phi + polyinner2(qq,ff,0,nmax,0,mmax)*scal
    enddo
    print*
    print'(a,*(f10.5))','10 phi', phi
        
    
    
    
    
end

subroutine test_polynextpow_n
    integer nn(3), i, a,b,c
    nn=0
    a=0;b=0;c=0
    do i = 1, pos_(11)
        if(i>1)then 
            call polynextpown(nn)
            call polynextpow(a,b,c)
        endif
        print*, str(i)//":"//str(nn)//','//str([a,b,c])//'     '//str(polyfind(nn))//','//str(polyfinder(a,b,c))
        
    enddo
end

subroutine test_detracer_linearity
    !This routine tests the linearity of the polytensor detracer. 
    integer, parameter :: nmax =7
    real(dp), dimension(pos_(nmax+1)) :: pt_new,pt_sum,pt_old, det_sum, sum_det
    integer i
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34000])
    pt_old=0
    pt_sum = 0
    sum_det=0
    do i = 1,1000
        call  random_number(pt_new)
        pt_sum = pt_sum + pt_new
        sum_det = sum_det + polydet(pt_new,nmax)
        !print*, "changing? sums: new, old, diff, accum new", sum(pt_new), sum(pt_old),sum(pt_new-pt_old), sum(pt_sum)
        pt_old=pt_new
        
    enddo
    det_sum=polydet(pt_sum,nmax)
    print*
    print*, "_____________Linearity: "//str(i-1)//" loops__________________ " 
    print'(a,*(e20.7))', "Diff", det_sum-sum_det
    
    print*, 'ABOVE: test_detracer_linearity -------------------------------------------'
end

! UTILS ____________________________________________________________________________________________________________________________
subroutine test_sumfac
    integer i
    
    do i = 1,10
        print*, sumfac(i) , i, 1
    enddo
    print*, 'ABOVE: test_sumfac -------------------------------------------'
endsubroutine

subroutine test_choose
    integer, parameter :: k = 10
    integer i,j, mat(0:k,0:k)
    print*,'choose(6,2)', choose(6,2)
    print*,'choose(5,2)', choose(5,2)
    print*,'choose(6,3)', choose(6,3)
    print*,'choose(2,4)', choose(4,2)
    print*,'choose(4,0)', choose(4,0)
    print*,'choose(0,4)', choose(0,4)
    print*,'choose(0,2)', choose(0,2)
    
    do i = 0, k
    do j = 0, k
        mat(i,j) = choose(i,j)
    enddo
    enddo
    call printa(mat,3)
    print*, 'ABOVE: test_choose -------------------------------------------'
end

subroutine test_apple_g
    print*, "xxyy", apple_g([2,2,0])
    print*, "xy", apple_g([1,1,0])
    
    print*, "xxyz", apple_g([2,1,1])
    print*, apple_g([1,1,0])
    print*, apple_g([1,0,1])
    print*, apple_g([0,1,1])
    
    print*, "xxxy", apple_g([3,1,0])
    print*, 'ABOVE: test_apple_g -------------------------------------------'
end subroutine

subroutine test_next_set2pown(rank,tric) !result(ns)
    integer, intent(in) :: rank, tric
    integer trilen, key(rank), nn(3), upper
    !integer :: ns(3, ((rank+1)*(rank+2))/2)
    integer i, j
    print '('//str(4)//'I2)', next_can([3,3,1,1],0)
    print '('//str(4)//'I2)', next_can([3,3,1,1],1)
    
    print '('//str(4)//'I2)', next_can([1,1,3,3],0)
    print '('//str(4)//'I2)', next_can([1,1,3,3],1)
    
    print '('//str( ((rank+1)*(rank+2))/2 )//'I6)', set2pown([1,1,2,3])
    
    trilen = ((rank+1)*(rank+2))/2 ! length of tricorn vector given full tensor rank
    
    key = 1
       
    print*, 'n(1:'//str(rank)//') array:'
    nn = set2pown(key)
    i = 1
    call pprint
    
    if(tric==1)upper=trilen
    if(tric==0)upper=3**rank
    
    do i = 2,upper!3**rank!trilen
       key = next(key,tric)
       
       nn = set2pown(key)
       call pprint
    enddo
    
    
    
    print*, 'ABOVE: test_next_set2pown -------------------------------------------'
    contains !// ////////////////////////
      
      
      
      subroutine pprint
         print*, "key=",(str(key(j))//" ",j=1,rank ),"  nn=",(str(nn(j))//" ",j=1,3 ),&
                 "  row:"//str(i), "  found row:"//str(finder(nn)), "  g:"//str(apple_g(nn))
      end subroutine
      
end

subroutine test_sorted()
    integer, allocatable :: key(:)!, key2(:)
    integer rank
    key = [4,5,2,1,3,1,7,1,3,2,6,1]
    rank = size(key)
    print '('//str(rank)//'I2)', sorted(key)
    print*, 'ABOVE: test_sorted -------------------------------------------'
end subroutine

subroutine test_expand_compress
    integer rank
    real(dp) :: tricorn(10), full(3,3,3)!, linfu(3**3)
    real(dp) :: tricorn4(15), full4(3,3,3,3)!, linfull4(3**4)!, linfu(3**3)
    
    rank = 3
    tricorn = [1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0]
    full = reshape(expand(tricorn,rank),shape(full),order=[3,1,2])
    call printo(full,[2,1,3])
    
    
    
    print '('//str( triclen(rank) )//'f7.3)', compress(reshape(full,[3**rank]),rank)
    
    rank=4
    tricorn4 = [1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0,11d0,12d0,13d0,14d0,15d0]
    full4 = reshape(expand(tricorn4,rank),shape(full4),order=[3,1,2,4])
    call printo(full4,[1,2,3,4])
    !linfull4 = reshape(full,[3**3])
    print '('//str( triclen(rank) )//'f7.3)', compress(reshape(full4,[3**4]),rank)
    
    
    print*, 'ABOVE: test_expand_compress -------------------------------------------'
end subroutine

subroutine test_fac(k)
    integer k, i
    do i = 1, k
        print*, fac(i)
    enddo
    
    print*, 'ABOVE: test_fac -------------------------------------------'
end

subroutine test_brakk
    integer n, l
    do n = 1, 10!20
        do l = 1, n/2
            print*, n,l, brakk(n,l), brakk_naive(n,l)
        enddo
    enddo
   print*, 'ABOVE: test_brakk -------------------------------------------'
end subroutine

function brakk_naive(n,l) result(res)
    integer,intent(in) :: n, l
    integer n_2l, a,b,  i
    integer*8 p1,p2
    integer res
    n_2l = n-2*l
    b = max(l,n_2l)
    a = min(l,n_2l)
    
    p1=1
    p2=1
    
    do i = b+1,n
     p1 = p1*i
    enddo
    
    do i = 2, a
     p2 = p2*i
    enddo
    
    res = int(p1/p2)/2**l
end function



subroutine test_nextpown!_apple
    integer n(3), k
    integer ind
    
    k = 4
    n(1) = k
    n(2) = 0
    n(3) = 0
    
    do ind = 1,sumfac(k+1)
        if(ind>1)call nextpown(n)
        print'(3I2,2I5)',n,ind, apple_g(n)
        enddo
        
   print*, 'ABOVE: test_nextpown -------------------------------------------'
end

subroutine test_next_pown!_nl!_apple
    integer n(3), k
    integer ind
    
    k = 4
    n(1) = k
    n(2) = 0
    n(3) = 0
    
    do ind = 1,sumfac(k+1)
        if(ind>1)call nextpown(n)
        print'(3I2,2I5)',n,ind, apple_g(n)
        enddo
        
    print*, 'ABOVE: test_next_pown -------------------------------------------'
end


subroutine test_subdiv_pow_h(ii,kii)
    integer ii, kii
    integer i, j, it
    integer n1(3), n2(3), nn(3)
    integer sfii, sfkii
    
    n1=0
    n1(1)=ii
    
    
    nn=0
    nn(1)=ii+kii
    
    
    sfii = sumfac(ii+1)
    sfkii = sumfac(kii+1)
    
    it = 0
    do i = 1, sfii
        if (i>1)call nextpown(n1)
        
        n2=0
        n2(1)=kii
        
        do j = 1, sfkii
            if (j>1)call nextpown(n2)
            it = it+1
            nn = n1+n2
            !*
            write(*,'(I6)', advance="no") hh(n1,n2) - hhh(i,j,ii,kii)
            enddo
        print*,""
    enddo
    !**    
    Print*, "ABOVE: test_subdiv_pow_h------------------------------------------------------------"
end

!*
            !print '(3(I3,2I2),7I4)', a1,b1,c1, a2,b2,c2, aa,bb,cc, &
            !      finder([aa,bb,cc]),&
            !      matr(i,j), &
            !      i + j + (vv(i)-1)*(vv(j)-1) - 1, &
            !      i + j + vv1(i)*vv1(j) - 1, &
            !      hh(a1,b1,c1, a2,b2,c2), &
            !      i, j !, it
            
            !write(*,'(I3)', advance="no") hh(a1,b1,c1, a2,b2,c2)
            !write(*,'(*(I3))') hh(a1,b1,c1, a2,b2,c2), &
            !                 ( apple_g([a1,b1,c1])*apple_g([a2,b2,c2])*choose(ii+kii,ii) )/apple_g([aa,bb,cc]), &
            !                 ( gg(pos_(ii)+i)*gg(pos_(kii)+j)*choose(ii+kii,ii) ) / gg(pos_(ii+kii) + matr(i,j)), & 
            !                 00,&
            !                 apple_g([a1,b1,c1]), apple_g([a2,b2,c2]), choose(ii+kii,ii), apple_g([aa,bb,cc]), &
            !                 00, &
            !                 gg(pos_(ii)+i), gg(pos_(kii)+j), choose(ii+kii,ii), gg(pos_(ii+kii) + matr(i,j)), & 
            !                 00
            
            !write(*,'(I6)', advance="no") ( apple_g([a1,b1,c1])*apple_g([a2,b2,c2])*choose(ii+kii,ii) )/apple_g([aa,bb,cc])
            !write(*,'(I6)', advance="no") ( gg(pos_(ii)+i)*gg(pos_(kii)+j)*choose(ii+kii,ii) ) / gg(pos_(ii+kii) + matr(i,j))
            
            
            !write(*,'(I6)', advance="no") ( gg(pos_(ii)+i)*gg(pos_(kii)+j)*choose(ii+kii,ii) ) / gg(pos_(ii+kii) + matr(i,j)) &
            !                              - ( apple_g([a1,b1,c1])*apple_g([a2,b2,c2])*choose(ii+kii,ii) )/apple_g([aa,bb,cc])
            
            !write(*,'(I6)', advance="no") hh(a1,b1,c1, a2,b2,c2) - hhh(i,j,ii,kii)
            !write(*,'(I6)', advance="no") hh(n1(1),n1(2),n1(3), n2(1),n2(2),n2(3)) - hhh(i,j,ii,kii)

!**
    !do here!
    !print'(*(I3))', vv(1:sumfac(ii+kii+1))
    !print'(*(I3))', vv1(1:sumfac(ii+kii+1))
    !print*, sumfac(ii+kii+1)


! TENSORS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
subroutine test_detracers
    !integer, parameter :: n = 5
    real(dp), dimension(len_(10)) ::  compvec, randv, newvec1
    real(dp) test
    integer n, nend
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34000])
    
    do n = 1,10
        nend = len_(n)
        call random_number(randv(1:nend))
        
        newvec1(1:nend) = detracer(randv(1:nend),n)
        
        
        compvec(1:nend) = opdetr(randv(1:nend),n)
        
        print*
        print*, "RANK="//str(n)
        print'(a,*(f8.3))', 'randv', randv(1:nend)
        print'(a,*(f8.3))', 'newvec ', newvec1(1:nend)
        print'(a,*(f8.3))', 'compvec', compvec(1:nend)
        print'(a,*(f8.3))', 'frac   ', newvec1(1:nend)/compvec(1:nend)
        test = sum((newvec1(1:nend)-compvec(1:nend))**2)
        if( test < 1e-10)print*, "OOOOOK "//str(n)//":" , test
        print*, "ABOVE: test_detracer ---------------------------------------"
    enddo

end

subroutine test_polydet
    integer, parameter :: nmax = 5
    real(dp) ::  compvec(pos_(nmax+1)), AA(pos_(nmax+1)),oldvec(pos_(nmax+1)), newvec(pos_(nmax+1))
    integer n1, n2, n, i
    
    n = 0; AA(pos_(n)+1:pos_(n+1)) = [ 1d0]/10d0
    n = 1; AA(pos_(n)+1:pos_(n+1)) = [ 1d0,2d0,3d0]/10d0
    n = 2; AA(pos_(n)+1:pos_(n+1)) = [ 1d0,2d0,3d0,4d0,5d0,6d0]/10d0
    n = 3; AA(pos_(n)+1:pos_(n+1)) = [ 1d0,2d0,3d0,4d0,5d0,6d0,7d0,8d0,9d0,10d0]/10d0
    n = 4; AA(pos_(n)+1:pos_(n+1)) = [ 1d0,2d0,3d0,4d0,5d0,6d0,7d0,8d0,9d0,10d0,11d0,12d0,13d0,14d0,15d0]/10d0
    n = 5; AA(pos_(n)+1:pos_(n+1)) = [ 1d0,2d0,3d0,4d0,5d0,6d0,7d0,8d0,9d0,10d0,11d0,12d0,13d0,14d0,15d0,16d0,&
                                        17d0,18d0,19d0,20d0,21d0]/10d0
    
    oldvec=AA
    
    do n = 0, nmax
        n1 = pos_(n)+1
        n2 = pos_(n+1)
        compvec(n1:n2) = opdetr(AA(n1:n2),n)
    enddo
    
    newvec = polydet(AA,nmax)
    
    
    print*, "   old,    AA,    comp"
    do i = 1, pos_(nmax+1)
        print'(*(f10.4))', oldvec(i), AA(i), compvec(i), newvec(i)
    enddo
    print*, "ABOVE: test_polydet ---------------------------------------"
    
    

end


subroutine h_testing
    integer i, k , n(3)
    k=5
    n = 0
    n(1) = k
    do i = 1, sumfac(k+1)
        if(i>1) call nextpown(n)
        print'(3I3,a,3I4,a,I4)',n,",  ", fac(n(1)), fac(n(2)), fac(n(3)),",  ", fac(n(1))*fac(n(2))*fac(n(3))
    enddo
    
    print*, "ABOVE: h_testing ----------------------------------------------------------------------"
end

subroutine test_hhh(k1, k2)
    integer i1, i2, k1,k2
    integer gp1, gp2, gp12, h, ch
    gp1 = pos_(k1)
    gp2 = pos_(k2)
    gp12 = pos_(k1+k2)
    ch = choose(k1+k2,k1)
    do i1 = 1, sumfac(k1+1)
      do i2 = 1, sumfac(k2+1)
        h = ( gg_(gp1+i1)*gg_(gp2+i2)*ch ) / gg_(gp12 + mm_(i1,i2))
        write(*,'((I4))', advance="no") h-hhh(i1,i2,k1,k2)
        enddo
      print*,""
      enddo
    print*, "above, TEST_HHH ------------------------------------------------------------------"
end


subroutine test_inner_symouter
    real(dp) :: v1(3), v2(6), v3(10), v4(15), v5(21)
    real(dp) :: f1(3), f2(3,3), f3(3,3,3), f4(3,3,3,3), f5(3,3,3,3,3), of1(3), of2(3,3), of3(3,3,3), of4(3,3,3,3)
    integer i,j,k, l, m
    
    !v1 = [ 1d0, 2d0, 3d0]
    !v2 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0]
    !v3 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0]
    !v4 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0, 11d0, 12d0, 13d0, 14d0, 15d0]
    !v5 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0, 11d0, 12d0, 13d0, 14d0, 15d0, 16d0 ,17d0 ,18d0 ,19d0 ,20d0 ,21d0 ]
    call random_number(v1)
    call random_number(v2)
    call random_number(v3)
    call random_number(v4)
    call random_number(v5)
    
    
    f1 = v1
    f2 = reshape(expand(v2,2),shape(f2))
    f3 = reshape(expand(v3,3),shape(f3))
    f4 = reshape(expand(v4,4),shape(f4))
    f5 = reshape(expand(v5,5),shape(f5))
    
    !call printer(f2,'f2',2)
    !call printer(f3,'f3',2)
    
    of1=0
    of2=0
    of3=0
    do i = 1,3
      do j = 1,3
        do k = 1,3
          
          of1(i) = of1(i) + f2(k,j)*f3(k,j,i)
          
          do l = 1, 3
            of2(j,i) = of2(j,i) + f2(l,k)*f4(l,k,j,i)
            do m = 1, 3
              of3(k,j,i) = of3(k,j,i) + f2(m,l)*f5(m,l,k,j,i)
            enddo
          enddo
        enddo
      enddo
    enddo
    
    
    
    !of1=0
    of2=0
    !of3=0
    of4=0
    do i = 1,3
      do j = 1,3
        do k = 1,3
          
          !of3(i,j,k) = of3(i,j,k) + f1(i)*f2(k,j) + f1(j)*f2(k,i) + f1(k)*f2(i,j)
          
          do l = 1, 3
            !of4(l,k,j,i) = of4(l,k,j,i) + f2(l,k)*f2(j,i)*6 !+ f2(l,j)*f2(k,i) + f2(l,i)*f2(k,j) 
            of4(l,k,j,i) = of4(l,k,j,i) + of1(l)*of3(k,j,i) + of1(k)*of3(l,j,i) + of1(j)*of3(l,k,i) + of1(i)*of3(k,l,j) 
          !  do m = 1, 3
          !    of3(k,j,i) = of3(k,j,i) + f2(m,l)*f5(m,l,k,j,i)
          !  enddo
          enddo
        enddo
      enddo
    enddo
    
    !call printer(of4,
    
    print*,""
    print'(*(f10.4))', compress(reshape(of4,[3**4]),4)
    print'(*(f10.4))', symouter(1,3,inner(3,2,v3,v2),inner(5,2,v5,v2))
    !print*,""
    !print'(*(f10.4))', compress(reshape(of4,[3**4]),4)
    !print'(*(f10.4))', symouter(1,3,v1,v3)
    
    print*, "above, INNER+OUTER ------------------------------------------------------------------"

    
end

subroutine test_inner
    real(dp) :: v1(3), v2(6), v3(10), v4(15), v5(21)
    real(dp) :: f1(3), f2(3,3), f3(3,3,3), f4(3,3,3,3), f5(3,3,3,3,3), of1(3), of2(3,3), of3(3,3,3)
    integer i,j,k, l, m
    
    v1 = [ 1d0, 2d0, 3d0]
    v2 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0]
    v3 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0]
    v4 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0, 11d0, 12d0, 13d0, 14d0, 15d0]
    v5 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0, 11d0, 12d0, 13d0, 14d0, 15d0, 16d0 ,17d0 ,18d0 ,19d0 ,20d0 ,21d0 ]
    
    
    f1 = v1
    f2 = reshape(expand(v2,2),shape(f2))
    f3 = reshape(expand(v3,3),shape(f3))
    f4 = reshape(expand(v4,4),shape(f4))
    f5 = reshape(expand(v5,5),shape(f5))
    
    !call printer(f2,'f2',2)
    !call printer(f3,'f3',2)
    
    of1=0
    of2=0
    of3=0
    do i = 1,3
      do j = 1,3
        do k = 1,3
          
          of1(i) = of1(i) + f2(k,j)*f3(k,j,i)
          
          do l = 1, 3
            of2(j,i) = of2(j,i) + f2(l,k)*f4(l,k,j,i)
            do m = 1, 3
              of3(k,j,i) = of3(k,j,i) + f2(m,l)*f5(m,l,k,j,i)
            enddo
          enddo
        enddo
      enddo
    enddo
    
    
    
    print*,"loop-comparison 3,2-rank"
    print'(*(f10.4))', of1
    print'(*(f10.4))', inner(3,2,v3,v2)
    
    print*,"loop-comparison 4,2-rank"
    print'(*(f10.4))', compress(reshape(of2,[3**2]),2)
    print'(*(f10.4))', inner(4,2,v4,v2)
    
    print*,"loop-comparison 5,2-rank"
    print'(*(f10.4))', compress(reshape(of3,[3**3]),3)
    print'(*(f10.4))', inner(5,2,v5,v2)
    
    
    print*,"scalar=3 5,0-rank"
    print'(*(f10.4))', v5
    print'(*(f10.4))', inner(5,0,v5,[1d0])
    
    print*,"scalar=3 2,0-rank"
    print'(*(f10.4))', v2
    print'(*(f10.4))', inner(2,0,v2,[1d0])
    
    print*," 2,2-rank"
    print'(*(f10.4))', v2
    print'(*(f10.4))', inner(2,2,v2,v2)
    
    print*," 1,1-rank"
    print'(*(f10.4))', v1
    print'(*(f10.4))', inner(1,1,v1,v1)
    
    print*, "ABOVE: test_inner ------------------------------------------------------------------"

end

subroutine test_symouter
    real(dp) :: v1(3), v2(6), v3(10), v4(15), v5(21)
    real(dp) :: f1(3), f2(3,3), f3(3,3,3), f4(3,3,3,3), f5(3,3,3,3,3), of1(3), of2(3,3), of3(3,3,3), of4(3,3,3,3)
    integer i,j,k, l
    
    v1 = [ 1d0, 2d0, 3d0]
    v2 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0]
    v3 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0]
    v4 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0, 11d0, 12d0, 13d0, 14d0, 15d0]
    v5 = [ 1d0, 2d0, 3d0, 4d0, 5d0, 6d0, 7d0, 8d0, 9d0, 10d0, 11d0, 12d0, 13d0, 14d0, 15d0, 16d0 ,17d0 ,18d0 ,19d0 ,20d0 ,21d0 ]
    
    
    f1 = v1
    f2 = reshape(expand(v2,2),shape(f2))
    f3 = reshape(expand(v3,3),shape(f3))
    f4 = reshape(expand(v4,4),shape(f4))
    f5 = reshape(expand(v5,5),shape(f5))
    
    !call printer(f2,'f2',2)
    !call printer(f3,'f3',2)
    
    of1=0
    of2=0
    of3=0
    of4=0
    
    do i = 1,3
      do j = 1,3
        do k = 1,3
          
          of3(i,j,k) = of3(i,j,k) + f1(i)*f2(k,j) + f1(j)*f2(k,i) + f1(k)*f2(i,j)
          
          do l = 1, 3
            !of4(l,k,j,i) = of4(l,k,j,i) + f2(l,k)*f2(j,i)*6 !+ f2(l,j)*f2(k,i) + f2(l,i)*f2(k,j) 
            of4(l,k,j,i) = of4(l,k,j,i) + f1(l)*f3(k,j,i) + f1(k)*f3(l,j,i) + f1(j)*f3(l,k,i) + f1(i)*f3(k,l,j) 
          !  do m = 1, 3
          !    of3(k,j,i) = of3(k,j,i) + f2(m,l)*f5(m,l,k,j,i)
          !  enddo
          enddo
        enddo
      enddo
    enddo
    
    !call printer(of4,
    
    
    print*,"3-rank comparison with loops:"
    print'(*(f10.4))', compress(reshape(of3,[3**3]),3)
    print'(*(f10.4))', symouter(1,2,v1,v2)
    print*,"4-rank comparison with loops:"
    print'(*(f10.4))', compress(reshape(of4,[3**4]),4)
    print'(*(f10.4))', symouter(1,3,v1,v3)
    
    print*, "different order:"
    print'(*(f10.4))', symouter(1,3,v1,v3)
    print'(*(f10.4))', symouter(3,1,v3,v1)
    
    print*, "scalar=3 in pos 2:"
    print'(*(f10.4))', v3
    print'(*(f10.4))', symouter(3,0,v3,[3d0])
    
    print*, "scalar=3 in pos 2:"
    print'(*(f10.4))', v1
    print'(*(f10.4))', symouter(1,0,v1,[3d0])
    
    print*, "scalar=3 in pos1:"
    print'(*(f10.4))', v3
    print'(*(f10.4))', symouter(0,3,[3d0],v3)
    
    print*, "scalar=3 in pos1:"
    print'(*(f10.4))', v1
    print'(*(f10.4))', symouter(0,1,[3d0],v1)
    
    print*, "ABOVE: test_symouter ------------------------------------------------------------------"
    
end


subroutine test_potgrad
    integer, parameter :: kmax=5, nmax = 3
    integer i
    real(dp) rr(3) 
    real(dp) :: rrr(pos_(kmax+1)), quad(6), octa(10), rnorm, rsqe
    real(dp) :: rinvv(2*(kmax+nmax)+1) !, rinvv1(2*(kmax+nmax)+1), rinvv2(2*(kmax+nmax)+1)
    real(dp) :: dd(3), dr, d2v(3,3)
    integer be, ga
    
    rr = [3.4231, 2.74389, 1.54739]
    
    dd = [2.345d0, -0.453245d0,0.6564256d0]
    call  vector_powers(kmax,rr,rrr)
    !print*, rrr(0), rrr(1)
    !print'(a,*(e10.3))',"rrr:",rrr
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34543])
    
    call random_number(quad)
    call random_number(octa)
    
    print'(a,*(g10.3))','quad:',quad
    print'(a,*(g10.3))','octa:',octa
    
    
    rsqe  = sum(rr**2)!dsqrt(rsq)
    rnorm = dsqrt(rsqe)
    rinvv(1) = 1d0/rnorm
    rinvv(2) = 1d0/rsqe
    
    do i = 3, 2*(kmax+nmax)+1
      rinvv(i) = rinvv(i-2)*rinvv(2)
    enddo
    
    dr = rnorm
    
    ! first dipole potential gradient
    print'(a,*(g30.15))', "d-1 exp", dd/dr**3 - (3*sum(rr*dd)/dr**5) * rr
    print'(a,*(g30.15))', 'd-1 new', potgrad(dd,1,1,rinvv,rrr)
    
    
    ! second dipole potential gradient
    d2v=0
    do be = 1, 3
      do ga = 1, 3 
        d2v(be,ga) =  - 3d0/dr**5 * ( dd(be)*rr(ga)  + dd(ga)*rr(be) + sum(dd*rr)*del(be,ga) ) & ! 
                      + & 
                      3d0*5d0*sum(dd*rr)*rr(be)*rr(ga) / dr**7
        enddo
        enddo
    
    print'(a,*(g30.15))', "d-2 exp", compress(reshape(d2v, shape=[3**2]),2)
    print'(a,*(g30.15))', 'd-2 new', opdetr(potgrad(dd,1,2,rinvv,rrr),2)
    
    
    
    print*, 'ABOVE: TEST POTGRAD-----------------------------------------------'
end



subroutine test_df
    integer, parameter :: kmax=4, nmax=4, grad=1, nkgmax = kmax+nmax+grad, kgmax=kmax+grad
    
    real(dp), dimension(pos_(kgmax+1)) :: phi_app, phi_lin, phi_mat
    real(dp), dimension(pos_(nkgmax+1)) :: df_lin, df_app, rrr 
    
    real(dp) qq(pos_(nmax+1))
    real(dp) rinvv(2*nkgmax+1)
    real(dp) sss(0:nkgmax) 
    
    real(dp) rr(3), rnorm, r2 !make a vector with poers of r
    
    real(dp) a_mat(0:kmax,0:nmax), aa
    real(dp), dimension(pos_(kgmax+1),pos_(nmax+1)) :: df_matrix
    
    
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34000])
    
    call  random_number(qq) !random multipoles
    
    rr = [3.4231, 2.74389, 1.54739]
    
    call  vector_powers(nkgmax,rr,rrr)
    !print'(a,*(g30.17))','rrr', rrr
    
    aa = 1.6d0
    r2=sum(rr**2)
    
    call dfdu_erf(aa,r2,nkgmax,sss)
    call lin_polydf(nkgmax,rrr,sss,df_lin)
    
    
    call inv_odd_powers(nkgmax,rr,rinvv,rnorm)
    call apple1_df(nkgmax,rrr,rinvv,df_app)
    
    a_mat = aa
    call create_df_matrix(kmax,grad,nmax,rrr,r2,a_mat,df_matrix) !mmax,grad,nmax,rrr,a_mat,df_matrix)
    !call printer(df_matrix,'s',1)
    
    
    
    !print*;print'(a,*(g30.17))','df_app', df_app
    !print*;print'(a,*(g30.17))','df_lin', df_lin
    !print*;print'(a,*(g30.17))','diff  ', df_lin - df_app
    
    phi_app = polyinner1(qq,df_app,0,nmax,0,kgmax)
    phi_lin = polyinner1(qq,df_lin,0,nmax,0,kgmax)
    phi_mat = matmul(df_matrix,qq*gg_(1:pos_(4+1)))
    
    print*;print'(a,*(g30.17))','phi_app', phi_app
    print*;print'(a,*(g30.17))','phi_lin', phi_lin
    print*;print'(a,*(g30.17))','phi_mat', phi_mat
    
    print*;print'(a,*(g30.17))','phi_app-phi_lin', phi_app-phi_lin
    print*;print'(a,*(g30.17))','phi_lin-phi_mat', phi_lin-phi_mat
                                          
    !(narr,dfarr,nn1,nn2,mm1,mm2)
    
    
    
end


subroutine test_mp_pot
    integer, parameter :: nm = 2
    real(dp) dpole(3,nm), qpole(3,3,nm), opole(3,3,3,nm), hpole(3,3,3,3,nm) 
    real(dp) d1v(3,nm), d2v(3,3,nm), d3v(3,3,3,nm), d4v(3,3,3,3,nm), d5v(3,3,3,3,3,nm)
    real(dp) a(3), a2(3), rCM(3,nm), fsf(3,nm), rMax2, rMax
    integer NC
    logical*1 iSlab
    logical FULL
    
    integer, parameter :: kmax=5, nmax = 4
    integer i
    real(dp) rr(3) 
    real(dp), dimension(pos_(kmax+1)) :: rrr
    real(dp) :: rnorm, rsqe
    real(dp) :: rinvv(2*(kmax+nmax)+1) !, rinvv1(2*(kmax+nmax)+1), rinvv2(2*(kmax+nmax)+1)
    real(dp) :: dd(3), dr, cq(6), co(10), ch(15)
    !real(dp) :: quad(6), octa(10),
    
    integer n,k
    integer p1,p2,q1,q2
    real(dp), dimension(pos_(6)) :: phi_old,phi,phi2
    real(dp), dimension(pos_(5)) :: qq
    
    
    ! For apple_potgrad
    integer, parameter :: nkmax = nmax+kmax
    real(dp) rrh(3)
    real(dp), dimension(pos_(nkmax+1)) :: dtrrr,  rrrh, rrrnm, lin_df
    integer pq1,pq2
    
    real(dp) r2
    real(dp) sss(0:nkmax) 
    
    
    print*, size(phi), sumfacfac(6), 3+6+10+21+15, size(qq), sumfacfac(5)
    
    rr = [3.4231, 2.74389, 1.54739]
    
    rrh = rr/sqrt(sum(rr**2)) !apple
    
    
    ! Define Multipoles
    dd = [2.345d0, -0.453245d0,0.6564256d0]
    
    cq = [0.32534, 0.4352345, 1.5324, 1.2543, 1.35435, -1.57964]
    
    co = [0.4352345, 1.5324, 1.2543, 1.35435, -1.57964,0.32534, 0.4352345, 1.5324, 1.2543, 1.35435]
    co = opdetr(co,3)
    
    ch = [2.341,3.52345,3.2465,8.978,6.4356,7.77745,6.43563,7.73094589,3.421,3.4526,2.4564257,9.893543,3.464236,8.979,5.3452]
    ch = opdetr(ch,4)
        
    qq = [0d0,dd,cq,co,ch]
    
    !print*,"q-thigs"
    !n=1
    !q1 = pos_(n)+1
    !q2 = pos_(n+1)
    !print'(*(I3))',n, q1,q2
    !
    !qq(q1:q2) = dd
    !
    !n=2
    !q1 = pos_(n)+1
    !q2 = pos_(n+1)
    !print'(*(I3))',n, q1,q2
    !
    !qq(q1:q2) = cq
    
    
    print*
    print'(*(f10.4))', qq(2:)
    print*, 'size(qq)',size(qq), 1+3+6+10+15
    
    
    
    call  vector_powers(kmax,rr,rrr)
    
    call  vector_powers(nkmax,rrh,rrrh)
    
    call  vector_powers(nkmax,rr,rrrnm)
    
    
    
    rsqe  = sum(rr**2)!dsqrt(rsq)
    rnorm = dsqrt(rsqe)
    rinvv(1) = 1d0/rnorm
    rinvv(2) = 1d0/rsqe
    
    do i = 3, 2*(nkmax)+1
      rinvv(i) = rinvv(i-2)*rinvv(2)
    enddo
    
    dr = rnorm
    
    
    
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    rMax = 100.1d0
    rMax2 = rMax**2
    rCM(:,1) = [0d0,0d0,0d0]
    rCM(:,2) = rr
    nc = 1
    a=40d0
    a2=a**2
    Full = .true. 
    iSlab = .false. 
    
    
    dpole=0
    qpole=0
    opole=0
    hpole=0
    
    
    hpole(:,:,:,:,1) = reshape(expand(ch,4),shape=[3,3,3,3])
    opole(:,:,:,1) = reshape(expand(co,3),shape=[3,3,3])
    qpole(:,:,1) = reshape(expand(cq,2),shape=[3,3])
    dpole(:,1) = dd(:)
    
    call calcDv(rCM, dpole, qpole, opole, hpole, nM, NC, a, a2, d1v, d2v, d3v, d4v, d5v, rMax2, fsf, iSlab,FULL)
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    phi_old(1) = 0
    phi(1) = 0
    
    
    k=1
    p1 = pos_(k)+1
    p2 = pos_(k+1)
    print'(6(I3))',k, p1,p2
    phi_old(p1:p2) = d1v(:,2)
    
    k=2
    p1 = pos_(k)+1
    p2 = pos_(k+1)
    print'(6(I3))',k, p1,p2
    phi_old(p1:p2) = opdetr(compress( reshape(      d2v(:,:,2),shape=[3**2]),2),2)
    
    k=3
    p1 = pos_(k)+1
    p2 = pos_(k+1)
    print'(6(I3))',k, p1,p2
    phi_old(p1:p2) = opdetr(compress( reshape(    d3v(:,:,:,2),shape=[3**3]),3),3)
    
    k=4
    p1 = pos_(k)+1
    p2 = pos_(k+1)
    print'(6(I3))',k, p1,p2
    phi_old(p1:p2) = opdetr(compress( reshape(  d4v(:,:,:,:,2),shape=[3**4]),4),4)
    
    k=5
    p1 = pos_(k)+1
    p2 = pos_(k+1)
    print'(6(I3))',k, p1,p2
    phi_old(p1:p2) = opdetr(compress( reshape(d5v(:,:,:,:,:,2),shape=[3**5]),5),5)
    
    
            
    dtrrr = polydet(rrrh,nkmax) !!!!!! måste ha den låååååånga!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    r2=sum(rr**2)
    call dfdu_erf(1.6d0,r2,nkmax,sss)
    call lin_polydf(nkmax,rrrnm,sss,lin_df)
    
    
    print*
    print*, "df comparison"
    print'(a,*(g30.15))','dtrrr', dtrrr
    print'(a,*(g30.15))','lin_df', lin_df
    
    !stop"just stop it!"
    
    
    phi=0
    phi2=0
    
    !n=1;k=2
    !
    !q1 = pos_(n)+1
    !q2 = pos_(n+1)
    !p1 = pos_(k)+1
    !p2 = pos_(k+1)
    !pq1= pos_(n+k)+1
    !pq2= pos_(n+k+1)
    !
    !print'(6I3)',n,k,q1,q2, p1,p2
    !call printo( opdetr(potgrad(qq(q1:q2),n,k,rinvv,rrr),k) )
    !call printo( apple_potgrad(qq(q1:q2),n,k,rinvv, dtrrr(pq1:pq2) ) )
    !
    !
    !
    !stop"hey"
    
    phi=0
    phi2=0
    do n = 1, 4
        q1 = pos_(n)+1
        q2 = pos_(n+1)
        do k = 1,5
            p1 = pos_(k)+1
            p2 = pos_(k+1)
            pq1= pos_(n+k)+1
            pq2= pos_(n+k+1)
            
            print'(6I3)',n,k,q1,q2, p1,p2
            phi(p1:p2) = phi(p1:p2) + opdetr(potgrad(qq(q1:q2),n,k,rinvv,rrr),k)
            phi2(p1:p2) = phi2(p1:p2) + apple_potgrad(qq(q1:q2),n,k,rinvv, dtrrr(pq1:pq2) )
        enddo
    enddo
    
    
    
    print*
    print'(a,*(g30.15))', 'phi      ',phi(2:)
    print*
    print'(a,*(g30.15))', 'phi appl ',phi2(2:)
    print*
    print'(a,*(g30.15))', 'phi-appl ',phi(2:)-phi2(2:)
    print*
    print'(a,*(g30.15))', 'appl+old ',phi2(2:)+phi_old(2:)
    print*
    print'(a,*(g30.15))', 'phi_old  ',phi_old(2:)
    print*
    print'(a,*(g30.15))', 'phi+old  ',phi_old(2:)+phi(2:)
    
    
    
    
    if(.false.)then
    
    !hexadeca
    print'(a,*(g30.15))', 'd-1 old', d1v(:,2)
    print'(a,*(g30.15))', 'd-1 new', potgrad(ch,4,1,rinvv,rrr)
    
    print'(a,*(g30.15))', 'd-2 old', opdetr(compress( reshape(      d2v(:,:,2),shape=[3**2]),2),2)
    print'(a,*(g30.15))', 'd-2 new', opdetr(potgrad(ch,4,2,rinvv,rrr),2)
    
    print'(a,*(g30.15))', 'd-3 old', opdetr(compress( reshape(    d3v(:,:,:,2),shape=[3**3]),3),3)
    print'(a,*(g30.15))', 'd-3 new', opdetr(potgrad(ch,4,3,rinvv,rrr),3)
    
    print'(a,*(g30.15))', 'd-4 old', opdetr(compress( reshape(  d4v(:,:,:,:,2),shape=[3**4]),4),4)
    print'(a,*(g30.15))', 'd-4 new', opdetr(potgrad(ch,4,4,rinvv,rrr),4)
    
    print'(a,*(g30.15))', 'd-5 old', opdetr(compress( reshape(d5v(:,:,:,:,:,2),shape=[3**5]),5),5)
    print'(a,*(g30.15))', 'd-5 new', opdetr(potgrad(ch,4,5,rinvv,rrr),5)
    
    !octu
    print'(a,*(g30.15))', 'd-1 old', d1v(:,2)
    print'(a,*(g30.15))', 'd-1 new', potgrad(co,3,1,rinvv,rrr)
    
    print'(a,*(g30.15))', 'd-2 old', opdetr(compress( reshape(      d2v(:,:,2),shape=[3**2]),2),2)
    print'(a,*(g30.15))', 'd-2 new', opdetr(potgrad(co,3,2,rinvv,rrr),2)
    
    print'(a,*(g30.15))', 'd-3 old', opdetr(compress( reshape(    d3v(:,:,:,2),shape=[3**3]),3),3)
    print'(a,*(g30.15))', 'd-3 new', opdetr(potgrad(co,3,3,rinvv,rrr),3)
    
    print'(a,*(g30.15))', 'd-4 old', opdetr(compress( reshape(  d4v(:,:,:,:,2),shape=[3**4]),4),4)
    print'(a,*(g30.15))', 'd-4 new', opdetr(potgrad(co,3,4,rinvv,rrr),4)
    
    print'(a,*(g30.15))', 'd-5 old', opdetr(compress( reshape(d5v(:,:,:,:,:,2),shape=[3**5]),5),5)
    print'(a,*(g30.15))', 'd-5 new', opdetr(potgrad(co,3,5,rinvv,rrr),5)
    
    !quadru
    print'(a,*(g30.15))', 'd-2 old', opdetr(compress( reshape(      d2v(:,:,2),shape=[3**2]),2),2)
    print'(a,*(g30.15))', 'd-2 new', opdetr(potgrad(dd,1,2,rinvv,rrr),2)
    
    print'(a,*(g30.15))', 'd-3 old', opdetr(compress( reshape(    d3v(:,:,:,2),shape=[3**3]),3),3)
    print'(a,*(g30.15))', 'd-3 new', opdetr(potgrad(dd,1,3,rinvv,rrr),3)
    
    print'(a,*(g30.15))', 'd-4 old', opdetr(compress( reshape(  d4v(:,:,:,:,2),shape=[3**4]),4),4)
    print'(a,*(g30.15))', 'd-4 new', opdetr(potgrad(dd,1,4,rinvv,rrr),4)
    
    print'(a,*(g30.15))', 'd-5 old', opdetr(compress( reshape(d5v(:,:,:,:,:,2),shape=[3**5]),5),5)
    print'(a,*(g30.15))', 'd-5 new', opdetr(potgrad(dd,1,5,rinvv,rrr),5)
    
    !dip
    print'(a,*(g30.15))', 'd-1 old', d1v(:,2)
    print'(a,*(g30.15))', 'd-1 new', potgrad(cq,2,1,rinvv,rrr)
    
    print'(a,*(g30.15))', 'd-2 old', opdetr(compress( reshape(      d2v(:,:,2),shape=[3**2]),2),2)
    print'(a,*(g30.15))', 'd-2 new', opdetr(potgrad(cq,2,2,rinvv,rrr),2)
    
    print'(a,*(g30.15))', 'd-3 old', opdetr(compress( reshape(    d3v(:,:,:,2),shape=[3**3]),3),3)
    print'(a,*(g30.15))', 'd-3 new', opdetr(potgrad(cq,2,3,rinvv,rrr),3)
    
    print'(a,*(g30.15))', 'd-4 old', opdetr(compress( reshape(  d4v(:,:,:,:,2),shape=[3**4]),4),4)
    print'(a,*(g30.15))', 'd-4 new', opdetr(potgrad(cq,2,4,rinvv,rrr),4)
    
    print'(a,*(g30.15))', 'd-5 old', opdetr(compress( reshape(d5v(:,:,:,:,:,2),shape=[3**5]),5),5)
    print'(a,*(g30.15))', 'd-5 new', opdetr(potgrad(cq,2,5,rinvv,rrr),5)
    
    endif
    

    
   print*, 'ABOVE: test_mp_pot  --------------------------'
     
end


subroutine test_matr(nn)
    integer i, nn, maxi
    if(nn>7)stop"rank cant be larger than 7 in matr intdex matrix"
    maxi = sumfac(nn)
    do i = 1, maxi
      print'(28I3)', mm_(i,1:maxi)
    enddo
   print*, 'ABOVE: test_matr ----------------------------------'
end subroutine

!subroutine test_matri(nn)
!    integer i, nn, maxi
!    if(nn>7)stop"rank cant be larger than 7 in matr intdex matrix"
!    maxi = sumfac(nn)
!    do i = 1, maxi
!      print'(28I3)', matri(i,1:maxi) - matr(i,1:maxi)
!    enddo
!end subroutine

subroutine test_rrr
    integer, parameter :: k=5
    real(dp) :: rrr(pos_(k+1)), rr(3), rrr3(10), rrr2(6), rrr5(len_(5)), rrr32(len_(5))
    real(dp) :: rrr4(len_(4)), rrr31(len_(4)), rrr22(len_(4)), rrr21(len_(3))
    integer i, p1, p2
    call random_seed(put=[2,234,1,5,435,4,5,42,3,43,432,4,3,5,23,345,34543])
    call random_number(rr)
    rr = [1d0,2d0,3d0]
    rr = [0.3810985945,0.5295087287,0.852367145402366]
    print*, size(rrr)
    
    call vector_powers(k,rr,rrr)
    !call rrpow(rr,k,rrr)
    !print'(*(f12.4))', rrr  
    call printer(rrr,'rrr',1)
    
    
    i = 2
    p1 = pos_(i)+1
    p2 = pos_(i+1)
    rrr2=rrr(p1:p2)
    
    i = 3
    p1 = pos_(i)+1
    p2 = pos_(i+1)
    rrr3=rrr(p1:p2)
    
    i = 4
    p1 = pos_(i)+1
    p2 = pos_(i+1)
    rrr4=rrr(p1:p2)
    
    i=5
    p1 = pos_(i)+1
    p2 = pos_(i+1)
    
    rrr5=rrr(p1:p2)
    
    rrr32 = symouter(3,2,rrr3,rrr2)
    rrr22 = symouter(2,2,rrr2,rrr2)
    rrr31 = symouter(3,1,rrr3,rr)
    rrr21 = symouter(2,1,rrr2,rr)
    
    
    call printer(rrr5,"5th",1)
    call printer(rrr32,"symouter(3,2)",1)
    call printer(rrr32/rrr5,"frac32",1)
    call printer(rrr22/rrr4,"frac22",1)
    call printer(rrr31/rrr4,"frac31",1)
    call printer(rrr21/rrr3,"frac21",1)
    
    print*, "above, TEST RRR ------------------------------------------------------------------"

end










end module
