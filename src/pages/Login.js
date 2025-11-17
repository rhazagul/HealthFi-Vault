import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login(){
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleLogin = (e)=>{
    e.preventDefault();
    const cred = JSON.parse(localStorage.getItem('hf_credentials_' + username) || 'null');
    if(!cred || cred.password !== password){ return alert('Invalid credentials (mock)'); }
    const user = { username, fullName: username, email: username + '@example.com' };
    localStorage.setItem('hf_user', JSON.stringify(user));
    navigate('/dashboard');
  }

  return (
    <div className="container">
      <div className="glass" style={{padding:20, maxWidth:480, margin:'0 auto'}}>
        <h2 className="title">Login</h2>
        <p className="subtitle">Access your HealthFi account.</p>
        <form onSubmit={handleLogin} style={{display:'grid', gap:10}}>
          <input className="form-input" placeholder="Username" value={username} onChange={e=>setUsername(e.target.value)} />
          <input className="form-input" placeholder="Password" type="password" value={password} onChange={e=>setPassword(e.target.value)} />
          <div style={{display:'flex', gap:8}}>
            <button type="submit" className="button btn-primary">Login</button>
            <button type="button" className="button btn-ghost" onClick={()=>{window.location='/signup'}}>Sign Up</button>
          </div>
        </form>
      </div>
    </div>
  );
}
