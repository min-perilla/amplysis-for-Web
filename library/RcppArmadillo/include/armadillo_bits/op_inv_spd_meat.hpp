// SPDX-License-Identifier: Apache-2.0
// 
// Copyright 2008-2016 Conrad Sanderson (http://conradsanderson.id.au)
// Copyright 2008-2016 National ICT Australia (NICTA)
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ------------------------------------------------------------------------


//! \addtogroup op_inv_spd
//! @{



template<typename T1>
inline
void
op_inv_spd_default::apply(Mat<typename T1::elem_type>& out, const Op<T1,op_inv_spd_default>& X)
  {
  arma_debug_sigprint();
  
  const bool status = op_inv_spd_default::apply_direct(out, X.m);
  
  if(status == false)
    {
    out.soft_reset();
    arma_stop_runtime_error("inv_sympd(): matrix is singular or not positive definite");
    }
  }



template<typename T1>
inline
bool
op_inv_spd_default::apply_direct(Mat<typename T1::elem_type>& out, const Base<typename T1::elem_type,T1>& expr)
  {
  arma_debug_sigprint();
  
  return op_inv_spd_full::apply_direct<T1,false>(out, expr, uword(0));
  }



//



template<typename T1>
inline
void
op_inv_spd_full::apply(Mat<typename T1::elem_type>& out, const Op<T1,op_inv_spd_full>& X)
  {
  arma_debug_sigprint();
  
  const uword flags = X.aux_uword_a;
  
  const bool status = op_inv_spd_full::apply_direct(out, X.m, flags);
  
  if(status == false)
    {
    out.soft_reset();
    arma_stop_runtime_error("inv_sympd(): matrix is singular or not positive definite");
    }
  }



template<typename T1, const bool has_user_flags>
inline
bool
op_inv_spd_full::apply_direct(Mat<typename T1::elem_type>& out, const Base<typename T1::elem_type,T1>& expr, const uword flags)
  {
  arma_debug_sigprint();
  
  typedef typename T1::elem_type eT;
  typedef typename T1::pod_type   T;
  
  if(has_user_flags == true )  { arma_debug_print("op_inv_spd_full: has_user_flags = true");  }
  if(has_user_flags == false)  { arma_debug_print("op_inv_spd_full: has_user_flags = false"); }
  
  const bool fast         = has_user_flags && bool(flags & inv_opts::flag_fast        );
  const bool allow_approx = has_user_flags && bool(flags & inv_opts::flag_allow_approx);
  const bool no_ugly      = has_user_flags && bool(flags & inv_opts::flag_no_ugly     );
  
  if(has_user_flags)
    {
    arma_debug_print("op_inv_spd_full: enabled flags:");
    
    if(fast        )  { arma_debug_print("fast");         }
    if(allow_approx)  { arma_debug_print("allow_approx"); }
    if(no_ugly     )  { arma_debug_print("no_ugly");      }
    
    arma_conform_check( (fast    && allow_approx), "inv_sympd(): options 'fast' and 'allow_approx' are mutually exclusive"    );
    arma_conform_check( (fast    && no_ugly     ), "inv_sympd(): options 'fast' and 'no_ugly' are mutually exclusive"         );
    arma_conform_check( (no_ugly && allow_approx), "inv_sympd(): options 'no_ugly' and 'allow_approx' are mutually exclusive" );
    }
  
  if(no_ugly)
    {
    op_inv_spd_state<T> inv_state;
    
    const bool status = op_inv_spd_rcond::apply_direct(out, inv_state, expr);
    
    // workaround for bug in gcc 4.8
    const uword local_size  = inv_state.size;
    const T     local_rcond = inv_state.rcond;
    
    if((status == false) || (local_rcond < ((std::max)(local_size, uword(1)) * std::numeric_limits<T>::epsilon())) || arma_isnan(local_rcond))  { return false; }
    
    return true;
    }
  
  if(allow_approx)
    {
    op_inv_spd_state<T> inv_state;
    
    Mat<eT> tmp;
    
    const bool status = op_inv_spd_rcond::apply_direct(tmp, inv_state, expr);
    
    // workaround for bug in gcc 4.8
    const uword local_size  = inv_state.size;
    const T     local_rcond = inv_state.rcond;
    
    if((status == false) || (local_rcond < ((std::max)(local_size, uword(1)) * std::numeric_limits<T>::epsilon())) || arma_isnan(local_rcond))
      {
      const Mat<eT> A = expr.get_ref();
      
      if(inv_state.is_diag)  { return op_pinv::apply_diag(out, A, T(0)); }
      
      return op_pinv::apply_sym(out, A, T(0), uword(0));
      }
    
    out.steal_mem(tmp);
    
    return true;
    }
  
  out = expr.get_ref();
  
  arma_conform_check( (out.is_square() == false), "inv_sympd(): given matrix must be square sized", [&](){ out.soft_reset(); } );
  
  if((arma_config::check_conform) && (arma_config::warn_level > 0))
    {
    if(auxlib::rudimentary_sym_check(out) == false)
      {
      if(is_cx<eT>::no )  { arma_warn(1, "inv_sympd(): given matrix is not symmetric"); }
      if(is_cx<eT>::yes)  { arma_warn(1, "inv_sympd(): given matrix is not hermitian"); }
      }
    else
    if((is_cx<eT>::yes) && (sym_helper::check_diag_imag(out) == false))
      {
      arma_warn(1, "inv_sympd(): imaginary components on diagonal are non-zero");
      }
    }
  
  const uword N = out.n_rows;
  
  if(N == 0)  { return true; }
  
  if(is_cx<eT>::no)
    {
    if(N == 1)
      {
      const T a = access::tmp_real(out[0]);
      
      out[0] = eT(T(1) / a);
      
      return (a > T(0));
      }
    else
    if(N == 2)
      {
      const bool status = op_inv_spd_full::apply_tiny_2x2(out);
      
      if(status)  { return true; }
      }
    
    // fallthrough if optimisation failed
    }
  
  if(is_op_diagmat<T1>::value || out.is_diagmat())
    {
    arma_debug_print("op_inv_spd_full: diag optimisation");
    
    eT* colmem = out.memptr();
    
    for(uword i=0; i<N; ++i)
      {
            eT& out_ii      = colmem[i];
      const  T  out_ii_real = access::tmp_real(out_ii);
      
      if(out_ii_real <= T(0))  { return false; }
      
      out_ii = eT(T(1) / out_ii_real);
      
      colmem += N;
      }
    
    return true;
    }
  
  bool sympd_state_junk = false;
  
  return auxlib::inv_sympd(out, sympd_state_junk);
  }



template<typename eT>
inline
bool
op_inv_spd_full::apply_tiny_2x2(Mat<eT>& X)
  {
  arma_debug_sigprint();
  
  typedef typename get_pod_type<eT>::result T;
  
  // NOTE: assuming matrix X is square sized
  // NOTE: assuming matrix X is symmetric
  // NOTE: assuming matrix X is real
  
  constexpr T det_min =        std::numeric_limits<T>::epsilon();
  constexpr T det_max = T(1) / std::numeric_limits<T>::epsilon();
  
  eT* Xm = X.memptr();
  
  T a = access::tmp_real(Xm[0]);
  T c = access::tmp_real(Xm[1]);
  T d = access::tmp_real(Xm[3]);
  
  const T det_val = (a*d - c*c);
  
  // positive definite iff all leading principal minors are positive
  // a       = first  leading principal minor (top-left 1x1 submatrix)
  // det_val = second leading principal minor (top-left 2x2 submatrix)
  
  if(a <= T(0))  { return false; }
  
  // NOTE: since det_min is positive, this also checks whether det_val is positive
  if((det_val < det_min) || (det_val > det_max) || arma_isnan(det_val))  { return false; }
  
  d /= det_val;
  c /= det_val;
  a /= det_val;
  
  Xm[0] =  d;
  Xm[1] = -c;
  Xm[2] = -c;
  Xm[3] =  a;
  
  return true;
  }



//



template<typename T1>
inline
bool
op_inv_spd_rcond::apply_direct(Mat<typename T1::elem_type>& out, op_inv_spd_state<typename T1::pod_type>& out_state, const Base<typename T1::elem_type,T1>& expr)
  {
  arma_debug_sigprint();
  
  typedef typename T1::elem_type eT;
  typedef typename T1::pod_type   T;
  
  out             = expr.get_ref();
  out_state.size  = out.n_rows;
  out_state.rcond = T(0);
  
  arma_conform_check( (out.is_square() == false), "inv_sympd(): given matrix must be square sized", [&](){ out.soft_reset(); } );
  
  if((arma_config::check_conform) && (arma_config::warn_level > 0))
    {
    if(auxlib::rudimentary_sym_check(out) == false)
      {
      if(is_cx<eT>::no )  { arma_warn(1, "inv_sympd(): given matrix is not symmetric"); }
      if(is_cx<eT>::yes)  { arma_warn(1, "inv_sympd(): given matrix is not hermitian"); }
      }
    else
    if((is_cx<eT>::yes) && (sym_helper::check_diag_imag(out) == false))
      {
      arma_warn(1, "inv_sympd(): imaginary components on diagonal are non-zero");
      }
    }
  
  if(is_op_diagmat<T1>::value || out.is_diagmat())
    {
    arma_debug_print("op_inv_spd_rcond: diag optimisation");
    
    out_state.is_diag = true;
    
    eT* colmem = out.memptr();
    
    T max_abs_src_val = T(0);
    T max_abs_inv_val = T(0);
    
    const uword N = out.n_rows;
    
    for(uword i=0; i<N; ++i)
      {
      eT& out_ii = colmem[i];
      
      const eT  src_val = out_ii;
      const eT  inv_val = eT(1) / src_val;
      
      if( (src_val == eT(0)) || (access::tmp_real(src_val) <= T(0)) )  { return false; }
      
      out_ii = inv_val;
      
      const T abs_src_val = std::abs(src_val);
      const T abs_inv_val = std::abs(inv_val);
      
      max_abs_src_val = (abs_src_val > max_abs_src_val) ? abs_src_val : max_abs_src_val;
      max_abs_inv_val = (abs_inv_val > max_abs_inv_val) ? abs_inv_val : max_abs_inv_val;
      
      colmem += N;
      }
    
    out_state.rcond = T(1) / (max_abs_src_val * max_abs_inv_val);
    
    return true;
    }
  
  if(auxlib::crippled_lapack(out))
    {
    arma_debug_print("op_inv_spd_rcond: workaround for crippled lapack");
    
    Mat<eT> tmp = out;
    
    bool sympd_state = false;
    
    auxlib::inv_sympd(out, sympd_state);
    
    if(sympd_state == false)  { out.soft_reset(); out_state.rcond = T(0); return false; }
    
    out_state.rcond = auxlib::rcond(tmp);
    
    if(out_state.rcond == T(0))  { out.soft_reset(); return false; }
    
    return true;
    }
  
  return auxlib::inv_sympd_rcond(out, out_state.rcond);
  }



//! @}
