subroutine get_cc_index_set(index_custom, NN_TABLE, ii, PINPT, ci_atom, cj_atom)
   use parameters, only : incar, hopping
   implicit none
   type(incar)   :: PINPT
   type(hopping) :: NN_TABLE
   integer*4        nn_class
   integer*4        i, lia, lja, lp, nn, ii
   integer*4        index_custom
   real*8           rij(3), dij, d0
   character*8      ci_atom, cj_atom
!  character*8      ci_orb, cj_orb
   character*16     cij_pair
   character*2      param_class
   character*20     c_dummy
   character*20     cc_custom
   logical          flag_scale

   rij(1:3)   = NN_TABLE%Rij(1:3,ii)
   dij        = NN_TABLE%Dij(    ii)
   nn_class   = NN_TABLE%n_class(ii)
   param_class= NN_TABLE%p_class(ii)

   ! initialize
   index_custom = 0  !initialize to zero

   flag_scale = .false.

   ! SET UP 'USER' DEFINED HOPPING RULE
   ! NOTE: In THIS example, hopping between A-A sublattice with x-direction characterized by hopping distance
   ! at around 11.6 ang is characterized by 'ccx_2_BiBi' since nn_class=2 is predefined in the INCAR-TB 
   ! with Bi--Bi : 12.0 R0 12.0 where '--' gives us '2'.
   ! Following do loop will find the parameter named 'ccx_2_BiBi' in the 'param_name' and will asign its
   ! number as the 'parameter_index' 
   if    ( (dij .gt. 11.5) .and. (dij .lt. 11.7) .and. (ci_atom .eq. cj_atom) ) then  ! AA-x hoping
     call get_param_name_index(PINPT, param_class, 'x', nn_class, ci_atom, cj_atom, flag_scale, index_custom)

   elseif( (dij .gt. 10.8) .and. (dij .lt. 11.1) .and. (ci_atom .eq. cj_atom) ) then  ! AA-y hoping
     call get_param_name_index(PINPT, param_class, 'y', nn_class, ci_atom, cj_atom, flag_scale, index_custom)

   ! Pmgx
   elseif( (dij .gt.  8.5) .and. (dij .lt.  8.7) .and. (ci_atom .eq. cj_atom) ) then  ! AB-a hoping
     call get_param_name_index(PINPT, param_class, 'a', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   elseif( (dij .gt.  7.3) .and. (dij .lt.  7.5) .and. (ci_atom .eq. cj_atom) ) then  ! AB-b hoping
     call get_param_name_index(PINPT, param_class, 'b', nn_class, ci_atom, cj_atom, flag_scale, index_custom)

   ! Pmgy
   elseif( (dij .gt.  9.3) .and. (dij .lt.  9.6) .and. (ci_atom .eq. cj_atom) ) then  ! AB-c hoping
     call get_param_name_index(PINPT, param_class, 'c', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   elseif( (dij .gt.  6.5) .and. (dij .lt.  6.9) .and. (ci_atom .eq. cj_atom) ) then  ! AB-d hoping
     call get_param_name_index(PINPT, param_class, 'd', nn_class, ci_atom, cj_atom, flag_scale, index_custom)

   ! Pmgx/Pmgy interface
   elseif( (dij .gt.  9.6) .and. (dij .lt.  9.8) .and. (ci_atom .ne. cj_atom) ) then  ! AA-l hoping
     call get_param_name_index(PINPT, param_class, 'l', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   elseif( (dij .gt. 13.4) .and. (dij .lt. 13.6) .and. (ci_atom .ne. cj_atom) ) then  ! AB-r hoping
     call get_param_name_index(PINPT, param_class, 'r', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   elseif( (dij .gt. 11.8) .and. (dij .lt. 12.1) .and. (ci_atom .ne. cj_atom) ) then  ! AA-t hoping
     call get_param_name_index(PINPT, param_class, 't', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   elseif( (dij .gt. 10.1) .and. (dij .lt. 10.4) .and. (ci_atom .ne. cj_atom) ) then  ! AB-b hoping
     call get_param_name_index(PINPT, param_class, 'b', nn_class, ci_atom, cj_atom, flag_scale, index_custom)

   endif

   ! setup for kane-mele 
   if    ( (dij .gt. 1.3d0) .and. (dij .lt. 1.6d0) ) then
     call get_param_name_index(PINPT, param_class, 'n', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   elseif( (dij .gt. 2.3d0) .and. (dij .lt. 2.6d0) ) then
     call get_param_name_index(PINPT, param_class, 'm', nn_class, ci_atom, cj_atom, flag_scale, index_custom)
   endif


return
endsubroutine
subroutine get_soc_cc_param_index(index_custom_soc, NN_TABLE, ii, PINPT, ci_atom, cj_atom, soc_type)
   use parameters, only: incar, hopping
   implicit none
   type(incar)   :: PINPT
   type(hopping) :: NN_TABLE
   integer*4      index_custom_soc
   integer*4      i, ii
   integer*4      nn_class
   integer*4      lio, ljo
   integer*4      lia, lja
   integer*4      ls
   character*8    ci_orb, cj_orb
   character*8    ci_atom, cj_atom
   character*20   lsoc_name
   character*2    param_class
   character*20   soc_type

    ci_orb     = NN_TABLE%ci_orb( ii)
    cj_orb     = NN_TABLE%cj_orb( ii)
    nn_class   = NN_TABLE%n_class(ii)
    param_class= NN_TABLE%p_class(ii)
    lio = len_trim(ci_orb)
    ljo = len_trim(cj_orb)
    lia = len_trim(ci_atom)
    lja = len_trim(cj_atom)
    ls  = len_trim(soc_type)

    index_custom_soc = 0 !initialize

    if(nn_class .lt. 10) then
      write(lsoc_name,'(4A,I1,3A)')soc_type(1:ls),'_',param_class(1:1),'_',nn_class,'_',ci_atom(1:lia),cj_atom(1:lja)
      call get_param_index(PINPT, lsoc_name, index_custom_soc)
      if(index_custom_soc .eq. 0) then
        write(lsoc_name,'(4A,I1,3A)')soc_type(1:ls),'_',param_class(1:1),'_',nn_class,'_',cj_atom(1:lja),ci_atom(1:lia)
        call get_param_index(PINPT, lsoc_name, index_custom_soc)
      endif
    elseif(nn_class .ge. 10) then    
      write(lsoc_name,'(4A,I2,3A)')soc_type(1:ls),'_',param_class(1:1),'_',nn_class,'_',ci_atom(1:lia),cj_atom(1:lja)
      call get_param_index(PINPT, lsoc_name, index_custom_soc)
      if(index_custom_soc .eq. 0) then
        write(lsoc_name,'(4A,I2,3A)')soc_type(1:ls),'_',param_class(1:1),'_',nn_class,'_',cj_atom(1:lja),ci_atom(1:lia)
        call get_param_index(PINPT, lsoc_name, index_custom_soc)
      endif
    endif

    !!! need to be improved AAAA !!!


return
endsubroutine
function tij_cc(NN_TABLE,ii,PINPT,tol)
  use parameters, only : pi, pi2, rt2, rt3, pzi, pzi2, zi, hopping, incar
  implicit none
  type (hopping)  :: NN_TABLE
  type (incar  )  :: PINPT
  integer*4 i,ii, iscale_mode
  integer*4       cc_index
  real*8          rij(3),dij, d0
  real*8          tij_cc, tol

  character*8  ci_orb,cj_orb
  character*20 site_index

! real*8, external:: f_s
! real*8, external:: e_onsite_cc

  ! NN_TABLE%cc_set_index(0:3,nn)
  !    0        1       2           3  
  ! e_onsite   tij  lambda_soc lambda_rashba 

  rij(1:3)   = NN_TABLE%Rij(1:3,ii)
  dij        = NN_TABLE%Dij(    ii)
  ci_orb     = NN_TABLE%ci_orb( ii)
  cj_orb     = NN_TABLE%cj_orb( ii)
  site_index = NN_TABLE%site_cindex( NN_TABLE%i_atom(ii) )
 
  tij_cc     = 0d0 !default if not provided
  d0         = NN_TABLE%Dij0(ii)

  if( NN_TABLE%n_class(ii) .eq. 0 ) then
    
    !set onsite energy
    cc_index = NN_TABLE%cc_index_set(0,ii)
    if( cc_index .gt. 0 ) then 
      call get_param(PINPT, cc_index, tij_cc)
      if(PINPT%flag_efield) then
        tij_cc = tij_cc - dot_product(PINPT%efield(1:3), NN_TABLE%i_coord(1:3,ii) - PINPT%efield_origin_cart(1:3))
      endif
    endif
  elseif( NN_TABLE%n_class(ii) .gt. 0 ) then

    !set intersite hopping tij_cc
    cc_index = NN_TABLE%cc_index_set(1,ii)
    if( cc_index .gt. 0 ) call get_param(PINPT, cc_index, tij_cc)

  endif

return
endfunction