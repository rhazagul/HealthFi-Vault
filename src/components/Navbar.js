import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

export default function Navbar(){
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem('hf_user') || 'null');
  const handleLogout = ()=>{ localStorage.removeItem('hf_user'); navigate('/login'); };
  return (
    <div className="navbar glass">
      <div className="brand">
        <div className="logo">HF</div>
        <div>
          <div style={{fontWeight:700}}>HealthFi Vault</div>
        </div>
      </div>
      <div style={{display:'flex', alignItems:'center', gap:12}}>
        <div className="nav-links" style={{marginRight:12}}>
                            <Link to="/dashboard" style={{marginLeft:12}}>Dashboard</Link>
          <Link to="/create-vault" style={{marginLeft:12}}>Create Vault</Link>
          <Link to="/settings" style={{marginLeft:12}}>Settings</Link>
        </div>
        {user ? (
          <div style={{display:'flex', alignItems:'center', gap:8}}>
            <div style={{fontSize:12, color:'#cfe6ff'}}>{user.username}</div>
            <button className="button btn-ghost" onClick={handleLogout}>Logout</button>
          </div>
        ) : (
          <div style={{display:'flex', gap:8}}>
            <Link to="/login"><button className="button btn-ghost">Login</button></Link>
            <Link to="/signup"><button className="button btn-primary">Sign Up</button></Link>
          </div>
        )}
      </div>
    </div>
  );
}
