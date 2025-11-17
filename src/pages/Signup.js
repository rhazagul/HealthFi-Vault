import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Signup(){
  const [fullName, setFullName] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const navigate = useNavigate();

  const handleSubmit = (e)=>{
    e.preventDefault();
    if(!fullName||!username||!email||!password) return alert('Please fill all fields');
    if(password !== confirm) return alert('Passwords do not match');
    const user = { fullName, username, email };
    localStorage.setItem('hf_user', JSON.stringify({...user, username}));
    // store credentials (mock)
    localStorage.setItem('hf_credentials_' + username, JSON.stringify({ username, password }));
    alert('Account created');
    navigate('/dashboard');
  }

  return (
    <div className="container">
      <div className="glass" style={{padding:20, maxWidth:600, margin:'0 auto'}}>
        <h2 className="title">Sign Up</h2>
        <p className="subtitle">Create your HealthFi account.</p>
        <form onSubmit={handleSubmit} style={{display:'grid', gap:10}}>
          <input className="form-input" placeholder="Full name" value={fullName} onChange={e=>setFullName(e.target.value)} />
          <input className="form-input" placeholder="Username" value={username} onChange={e=>setUsername(e.target.value)} />
          <input className="form-input" placeholder="Email address" value={email} onChange={e=>setEmail(e.target.value)} />
          <input className="form-input" placeholder="Password" type="password" value={password} onChange={e=>setPassword(e.target.value)} />
          <input className="form-input" placeholder="Confirm password" type="password" value={confirm} onChange={e=>setConfirm(e.target.value)} />
          <div style={{display:'flex', gap:8}}>
            <button type="submit" className="button btn-primary">Sign Up</button>
            <button type="button" className="button btn-ghost" onClick={()=>{window.location='/login'}}>Have an account?</button>
          </div>
        </form>
      </div>
    </div>
  );
}
