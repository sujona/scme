! Copyright (c)  2015-2016  SCMEdev.
! Licenced under the LGPLv3 license. See LICENSE for details.


!> Module for calculating energy and forces of water moecules using the SCME
!! potential that is based on multipole moments, where ach molecule is
!! represented as a multipole expansion up to hexadecapole moment.
!!
!! The SCME potential is described in:
!!
!!      K. T. Wikfeldt, E. R. Batista, F. D. Vila and H. Jonsson
!!      Phys. Chem. Chem. Phys., 2013, 15, 16542
!!
!! Please cite this work if you use the SCME potential in you research.

!should be on top of scme_calculate
  !> The main routine for the SCME potential. Calculates the total energy and
  !! forces on a set of water molecules.
  !!
  !! @param[in] n_atoms : The number of atoms. The number of atoms is assumed
  !!                      to be 3 times the number of water molecules.
  !! @param[in] coords  : The coordinates of the water molecules.
  !!                  coords(l+6*(i-1)) stores the l-th coordinate of the first
  !!                      hydrogen in the i-th molecule
  !!                  coords(l+3+6*(i-1)) stores the l-th coordinate of the second
  !!                      hydrogen in the i-th molecule
  !!                  coords(l+3*(i-1+nHydrogens)) stores the l-th coordinate of the
  !!                      oxygen in the i-th molecule. (nHydrogens is
  !!                      the total number of hydrogen atoms).
  !! @param[in] lattice : The x,y,z dimensions of the rectangular box.
  !! @param[out] fa     : The forces. The array must have space for n_atoms forces.
  !! @param[out] u_tot  : The total energy calculated with the SCME potential.

module scme

  use data_types
  use max_parameters
  use parameters, only: num_cells
  use multipole_parameters, only: d0, q0, o0, h0
  use polariz_parameters, only: dd0, dq0, hp0, qq0
  use molecProperties, only: recoverMolecules, calcCentersOfMass,&
       findPpalAxes, rotatePoles, rotatePolariz, setUnpolPoles, addFields, addDfields
  use calc_lower_order, only: calcEdip_quad
  use calc_higher_order, only: calcEhigh
  use calc_derivs, only: calcDv
  use inducePoles, only: induceDipole, induceQpole
  use forceCM_mod, only: forceCM
  use torqueCM_mod, only: torqueCM
  use atomicForces_mod, only: atomicForces
  use calcEnergy_mod, only: calcEnergy
  use coreInt_mod, only: coreInt
  use dispersion_mod, only: dispersion
  
 ! the new PS surfaces: 
  use ps_dms, only: vibdms
  use ps_pot, only: vibpes
  use constants, only:A_a0, ea0_Deb, eA_Deb
  use printer_mod!, only: printer

  implicit none
  private
  public scme_calculate

contains

  subroutine scme_calculate(n_atoms, coords, lattice, fa, u_tot)

    implicit none
    integer, intent(in) :: n_atoms
    real(dp), intent(in) :: coords(n_atoms*3)
    real(dp), intent(in) :: lattice(3)
    real(dp), intent(out) :: fa(n_atoms*3)
    real(dp), intent(out) :: u_tot
    ! ----------------------------------------

    ! Constants and parameters.
    real(dp), parameter :: pi = 3.14159265358979324_dp
    !real(dp), parameter :: kk1 = ea0_Deb!2.5417709_dp !au2deb
    !real(dp), parameter :: au2deb = kk1 !1.88972612456506198632=A_a0
    !real(dp), parameter :: kk2 = A_a0    !1.88972666351031921149_dp !A2b
    real(dp), parameter :: kk1 = 2.5417709_dp
    real(dp), parameter :: kk2 = 1.88972666351031921149_dp
    real(dp), parameter :: convFactor = 14.39975841_dp / 4.803206799_dp**2 ! e**2[eVÅ]=[eVm / (e*10**10[statcol])**2
    real(dp), parameter :: rMax = 11.0_dp
    real(dp), parameter :: rMax2 = rMax*rMax
    integer, parameter :: NC = num_cells

    ! Parameter flags for controlling behavior.
    logical*1, parameter :: irigidmolecules = .false.
    logical*1, parameter :: debug = .false.
    logical*1, parameter :: iSlab = .false.
    logical*1, parameter :: addCore = .false.
    logical*1, parameter :: useDMS = .true.

    ! Local flag for controlling behavior.
    logical*1, save :: converged

    ! Local variables for energies.
    real(dp), save :: uQ, uH, uES, uDisp, uD, uCore

    ! Local arrays for lattice and half lattice.
    real(dp), save :: a(3)
    real(dp), save :: a2(3)

    ! Center of mass forces and torque.
    real(dp) :: fCM(3,n_atoms/3)
    real(dp) :: fsf(3,n_atoms/3)
    real(dp) :: tau(3,n_atoms/3)

    ! Atomic positions, centers of mass, principal axes.
    real(dp) :: ra(n_atoms*3) 
    real(dp) :: rCM(3,n_atoms/3)
    real(dp) :: x(3,3,n_atoms/3)

    ! Electric fields.
    real(dp) :: eD(3,n_atoms/3)
    real(dp) :: eQ(3,n_atoms/3)
    real(dp) :: eH(3,n_atoms/3)
    real(dp) :: eT(3,n_atoms/3)

    ! Derivatives of E.
    real(dp) :: dEddr(3,3,n_atoms/3)
    real(dp) :: dEqdr(3,3,n_atoms/3)
    real(dp) :: dEhdr(3,3,n_atoms/3)
    real(dp) :: dEtdr(3,3,n_atoms/3)

    ! High order derivatives of the potential.
    real(dp) :: d1v(3,n_atoms/3)
    real(dp) :: d2v(3,3,n_atoms/3)
    real(dp) :: d3v(3,3,3,n_atoms/3)
    real(dp) :: d4v(3,3,3,3,n_atoms/3)
    real(dp) :: d5v(3,3,3,3,3,n_atoms/3)

    ! Work multipoles. They start unpolarized and with the induction
    ! loop we induce dipoles and quadrupoles.
    real(dp) :: dpole0(3,n_atoms/3)
    real(dp) :: qpole0(3,3,n_atoms/3)
    real(dp) :: opole(3,3,3,n_atoms/3)
    real(dp) :: hpole(3,3,3,3,n_atoms/3)
    real(dp) :: dpole(3,n_atoms/3)
    real(dp) :: qpole(3,3,n_atoms/3)

    ! Polarizabilities.
    real(dp) :: dd(3,3,n_atoms/3)
    real(dp) :: dq(3,3,3,n_atoms/3)
    real(dp) :: hp(3,3,3,n_atoms/3)
    real(dp) :: qq(3,3,3,3,n_atoms/3)

    ! Local integers.
    integer, save :: nM, nO, nH, i, p
    integer, save :: indO, indH1, indH2

    ! Local arrays for ??? ML
    real(dp) :: uPES(n_atoms*3)
    real(dp), save :: dipmom(3)
    !real(dp), save :: qdms(3)
    

    ! Input for the potnasa potential.
    real(dp), save :: mol(9)
    real(dp), save :: grad(9)
    real(dp), save :: uPES1
   !new shit: 
    integer jjj
    real(dp) ps_mol(3,3) !fix this  !!!  ! ps(O,H1,H1 ; x,y,z)
    real(dp) ps_mol_dip(3,3)
    real(dp) ps_grad(9)
    real(dp) ps_pes
    
    !real*8, parameter :: A2b     = 1.889725989d0 !Ångström to Bohr
    !real*8, parameter :: b2A     = 0.529177249d0
    !real*8, parameter :: au2deb  = 2.541746230211d0 !a.u. to debye
    !real*8, parameter :: h2eV  = 27.211396132d0 !a.u. to debye
      
    real*8 temp1,temp2,temp3
    
    real(dp) :: qdms(3)
    real(dp) :: dms(3)
    real(dp), save :: dipmom2(3)
    integer iteration
    
    ! ----------------------------
    ! Set initial Intitial values.
    ! ----------------------------
    ! Total energy.
    u_tot = 0.0_dp

    ! Number of oxygen, hydrogen and moecules.
    nO = n_atoms/3
    nH = nO*2
    nM = nO

    ! Size of the simulation cell.
    a(1) = lattice(1)
    a(2) = lattice(2)
    a(3) = lattice(3)
    a2(1) = lattice(1)/2.0_dp
    a2(2) = lattice(2)/2.0_dp
    a2(3) = lattice(3)/2.0_dp

    ! Recover broken molecules due to periodic boundary conditions.
    call recoverMolecules(coords, ra, nH, nO, a, a2)

    ! Calculate the center of mass for each molecule.
    call calcCentersOfMass(ra, nM, rCM)

    ! Find the rotation matrix x that defines the principal axis.
    call findPpalAxes(ra, nM, x)

    ! Rotate the multipoles d0, dq etc, to allign with the molecules using
    ! the rotation matrix x. The result is stored in the dpole0 etc arrays.
    call rotatePoles(d0, q0, o0, h0, dpole0, qpole0, opole, hpole, nM, x)

    ! call Partridge-Schwenke dipole moment surface routine.
!    print*, "DIPOLE"
    if (useDMS) then
       do i = 1,nM
          indH1 = 6*(i-1)
          indO  = 3*(i-1+2*nM)
          indH2 = 3+6*(i-1)

          ! Get x, y, z coordinates for H and O.
          do p=1,3
             ps_mol_dip(1,p) = ra(indO  + p)
             ps_mol_dip(2,p) = ra(indH1 + p)
             ps_mol_dip(3,p) = ra(indH2 + p)
          end do
          
          dms = 0
          call vibdms(ps_mol_dip,dms) 
          
          do p=1,3
             dpole0(p,i) = dms(p)*kk1*kk2!*eA_Deb! dipmom(p)*kk1*kk2!*ea0_Deb*A_a0!     When we fix units this shuld be fixed. 
          end do
       end do
    end if
call printer(dpole0, 'dpole0')
    
    !print*, sqrt(sum(dpole0(:,1)**2))
    !print*, sqrt(sum(dpole0(:,1)**2))
    
    ! NEEDS DOCUMENTATION
    call setUnpolPoles(dpole, qpole, dpole0, qpole0, nM)
    call rotatePolariz(dd0, dq0, qq0, hp0, dd, dq, qq, hp, nM, x)

    call calcEhigh(rCM, opole, hpole, nM, NC, a, a2, uH, eH, dEhdr, rMax2, iSlab)
call printer(eH, 'eH')
call printer(uH, 'uH')
call printer(dEhdr, 'dEhdr')
!call printer(opole, 'opole')
!call printer(hpole, 'hpole')


    ! Here's where the induction loop begins.
    converged = .false.
    iteration = 0
    do while (.not. converged)
    iteration = iteration + 1

       ! NEEDS DOCUMENTATION
       call calcEdip_quad(rCM, dpole, qpole, nM, NC, a, a2, uD, uQ, eD, dEddr, rMax2, iSlab)


       call addFields(eH, eD, eT, nM)
       call addDfields(dEhdr, dEddr, dEtdr, nM)
       

       ! Induce dipoles and quadrupoles.
       converged = .true.

       call induceDipole(dpole, dpole0, eT, dEtdr, dd, dq, hp, nM, converged)
       call induceQpole(qpole, qpole0, eT, dEtdr, dq, qq, nM, converged)
    end do

    ! With the polarized multipoles, calculate the derivarives of the
    ! electrostatic potential, up to 5th order.
    call calcDv(rCM, dpole, qpole, opole, hpole, nM, NC, a, a2, d1v, d2v, d3v, d4v, d5v, rMax2, fsf, iSlab)

    ! Compute the force on the center of mass.
    call forceCM(dpole, qpole, opole, hpole, d2v, d3v, d4v, d5v, nM, fsf, fCM)

    ! Compute the torque on the molecule.
    call torqueCM(dpole, qpole, opole, hpole, d1v, d2v, d3v, d4v, nM, tau)

    ! Find 3 forces, one at oxygen and one at each hydrogen such that
    ! the total force and total torque agree with the ones calculated
    ! for the multipoles.
    ! NOTE: This is where 'fa' is calculated.
    call atomicForces(fCM, tau, ra, rCM, nM, fa)

    ! Calculate the energy of interaction between the multipole moments
    ! and the electric field of the other molecules.
    call calcEnergy(dpole0, qpole0, opole, hpole, d1v, d2v, d3v, d4v, nM, u_tot)

    ! Convert the forces and total energy to correct units.
    do i = 1,(3*n_atoms)
       fa(i) = convFactor * fa(i)
    end do
    u_tot = u_tot * convFactor

    ! Store the energy this far for debug printout.
    uES = u_tot

    ! Calculate dispersion forces ??? ML
    call dispersion(ra, fa, uDisp, nM, a, a2)
    u_tot = u_tot + uDisp

    ! Calculate the core contribution to the energy. (only to the energy ??? ML)
    if (addCore) then
       call coreInt(ra, fa, uCore, nM, a, a2)
       u_tot = u_tot + uCore
    end if
    
    print*, 
    print*, "PES"
    print*, 
    ! Adding intramolecular energy from Partridge-Schwenke PES.
    uPES(:) = 0.0_dp
    if (.not. irigidmolecules) then
       do i=1,nM
          mol(:) = 0.0_dp
          
          indH1 = 6*(i-1)
          indO  = 3*(i-1+2*nM)
          indH2 = 3+6*(i-1)
          ! Get x, y, z coordinates for H and O.
          do p=1,3
             mol(p) = ra(indO  + p)
             mol(p+3) = ra(indH1  + p)
             mol(p+6) = ra(indH2  + p)
          end do
          
          !print*, 'mol1:',mol(1:3)
          !print*, 'mol2:',mol(4:6)
          !print*, 'mol3:',mol(7:9)
          
          ! ORIGINAL
          grad(:) = 0.0_dp
          call potnasa2(mol,grad,uPES1)
          
          !> Debug --------------------------------------
       !   do jjj=1,9,3
       !      print*, 'grad:',grad(jjj),grad(jjj+1),grad(jjj+2)
       !   enddo
       !   print*, 'uPES1', uPES1
          !< --------------------------------------------
          
          ! comment to use the fortran routine
          !uPES(i) = uPES1
          !u_tot = u_tot + uPES1
          
             
          ! NEW

!    real(dp) ps_mol(3,3) !fix this  !!!  ! ps(O,H1,H1 ; x,y,z)
!    real(dp) ps_grad(9)
!    real(dp) ps_pes
!    real(dp) :: dms(3)
    


          do p=1,3
             ps_mol(1,p) = ra(indO  + p)
             ps_mol(2,p) = ra(indH1 + p)
             ps_mol(3,p) = ra(indH2 + p)
             
          end do
          
          ps_grad(:) = 0.0_dp
          call vibpes(ps_mol,ps_pes,ps_grad)!,ps_pes) *A2b
          
          !> Debug --------------------------------------
       !   do jjj=1,9,3
       !      print*, 'ps_grad:',ps_grad(jjj),ps_grad(jjj+1),ps_grad(jjj+2)!*h2eV*A2b
       !   enddo
       !   print*, 'ps_pes:', ps_pes!*h2eV
          !< --------------------------------------------
          
          
          
          ! uncomment to use the fortran routine
          uPES(i) = ps_pes
          u_tot = u_tot + ps_pes
          
          
          
          !print*, 'grad2:',grad(4:6)
          !print*, 'grad3:',grad(7:9)
          !print*, 'uPES1:', uPES1
          
          do p=1,3
             
             ! temporary to test the ps_grad
             !temp1 = fa(indO  + p)
             !temp2 = fa(indH1 + p)
             !temp3 = fa(indH2 + p)
             
             
             !fa(indO  + p) = fa(indO  + p) - grad(p)
             !fa(indH1 + p) = fa(indH1 + p) - grad(p+3)
             !fa(indH2 + p) = fa(indH2 + p) - grad(p+6)
             !print*, 'orig FA', fa(indO  + p)
             !print*, 'orig FA', fa(indH1 + p)
             !print*, 'orig FA', fa(indH2 + p)
             !
             fa(indO  + p) = fa(indO  + p) - ps_grad(p)  !*h2eV*A2b
             fa(indH1 + p) = fa(indH1 + p) - ps_grad(p+3)!*h2eV*A2b
             fa(indH2 + p) = fa(indH2 + p) - ps_grad(p+6)!*h2eV*A2b
             !print*, 'new FA', fa(indO  + p)
             !print*, 'new FA', fa(indH1 + p)
             !print*, 'new FA', fa(indH2 + p)
             
          end do
          
          
       end do
    end if
call printer(u_tot,'u_tot')
call printer(fa,'fa')

!    print*, "fa in the end: "
!    print*, fa


! ML: These print-statements makes up half the CPU usage for a
!     dimer input.
!
!ktw    print '(5f16.10)', uTot, uES, uDisp, uCore, sum(uPES)
!    print '(4f16.10)', uTot, uES, uDisp, sum(uPES)
!    print*, size(ra), "is size ra" !JÖ

    return

  end subroutine scme_calculate

end module scme

