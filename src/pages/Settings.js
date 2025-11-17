import React, { useState, useEffect } from 'react';

export default function Settings(){
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('hf_user')||'null'));

  const [name, setName] = useState(user?.fullName || '');
  const [username, setUsername] = useState(user?.username || '');
  const [email, setEmail] = useState(user?.email || '');
  const [oldPwd, setOldPwd] = useState('');
  const [newPwd, setNewPwd] = useState('');
  const [confirmPwd, setConfirmPwd] = useState('');

  useEffect(()=>{ setUser(JSON.parse(localStorage.getItem('hf_user')||'null')); },[]);

  const saveProfile = ()=>{
    const updated = {...user, fullName: name, username, email};
    localStorage.setItem('hf_user', JSON.stringify(updated));
    alert('Profile updated (mock)');
    setUser(updated);
  }

  const changePassword = ()=>{
    if(newPwd !== confirmPwd) return alert('Passwords do not match');
    const cred = JSON.parse(localStorage.getItem('hf_credentials_' + user.username) || 'null');
    if(!cred || cred.password !== oldPwd) return alert('Old password incorrect (mock)');
    localStorage.setItem('hf_credentials_' + user.username, JSON.stringify({ username: user.username, password: newPwd }));
    alert('Password changed (mock)');
    setOldPwd(''); setNewPwd(''); setConfirmPwd('');
  }

  const deleteAccount = ()=>{
    if(!confirm('Delete account? This is a mock action.')) return;
    localStorage.removeItem('hf_user');
    localStorage.removeItem('hf_credentials_' + user.username);
    alert('Account deleted (mock)');
    window.location = '/signup';
  }

  return (
    <div className="container">
      <div className="glass" style={{padding:20}}>
        <h2 className="title">Settings</h2>
        <p className="subtitle">Manage your profile and security (mock).</p>
        <div style={{display:'grid', gap:10}}>
          <label>Full name</label>
          <input className="form-input" value={name} onChange={e=>setName(e.target.value)} />
          <label>Username</label>
          <input className="form-input" value={username} onChange={e=>setUsername(e.target.value)} />
          <label>Email</label>
          <input className="form-input" value={email} onChange={e=>setEmail(e.target.value)} />
          <div style={{display:'flex', gap:8, marginTop:8}}>
            <button className="button btn-primary" onClick={saveProfile}>Save Profile</button>
            <button className="button btn-ghost" onClick={()=>{ setName(user.fullName); setUsername(user.username); setEmail(user.email); }}>Reset</button>
          </div>
          <hr style={{border:'none', height:1, background:'rgba(255,255,255,0.03)', margin:'12px 0'}} />
          <h3 style={{margin:0}}>Change Password</h3>
          <input type="password" className="form-input" placeholder="Old password" value={oldPwd} onChange={e=>setOldPwd(e.target.value)} />
          <input type="password" className="form-input" placeholder="New password" value={newPwd} onChange={e=>setNewPwd(e.target.value)} />
          <input type="password" className="form-input" placeholder="Confirm new password" value={confirmPwd} onChange={e=>setConfirmPwd(e.target.value)} />
          <div style={{display:'flex', gap:8}}>
            <button className="button btn-primary" onClick={changePassword}>Change Password</button>
            <button className="button btn-ghost" onClick={()=>{ setOldPwd(''); setNewPwd(''); setConfirmPwd(''); }}>Clear</button>
          </div>
          <hr style={{border:'none', height:1, background:'rgba(255,255,255,0.03)', margin:'12px 0'}} />
          <h3 style={{margin:0}}>Danger Zone</h3>
          <button className="button" style={{background:'linear-gradient(90deg,#ff4d6d,#7c3aed)', color:'#fff'}} onClick={deleteAccount}>Delete Account</button>
        </div>
      </div>
    </div>
  );
}
