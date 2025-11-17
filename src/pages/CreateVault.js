import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const goals = ['Annual Checkup','Dental Cleaning','Chronic Disease Screening','Wellness Program'];

export default function CreateVault(){
  const [goal, setGoal] = useState(goals[0]);
  const [amount, setAmount] = useState('');
  const [token, setToken] = useState('USDT');
  const navigate = useNavigate();

  const handleCreate = ()=>{
    if(!amount) return alert('Enter amount');
    const vaults = JSON.parse(localStorage.getItem('hf_vaults') || '[]');
    const id = vaults.length ? Math.max(...vaults.map(v=>v.id))+1 : 1;
    const newV = { id, title: goal + ' Vault', token, deposit: Number(amount), yield: 0, verified:false };
    vaults.push(newV);
    localStorage.setItem('hf_vaults', JSON.stringify(vaults));
    alert('Vault created');
    navigate('/dashboard');
  }

  return (
    <div className="container">
      <div className="glass" style={{padding:20}}>
        <h2 className="title">Create Vault</h2>
        <p className="subtitle">Pick a health goal and fund your vault.</p>
        <div style={{display:'grid', gap:10}}>
          <label>Health Goal</label>
          <select className="form-input" value={goal} onChange={e=>setGoal(e.target.value)}>{goals.map(g=> <option key={g}>{g}</option>)}</select>
          <label>Token</label>
          <select className="form-input" value={token} onChange={e=>setToken(e.target.value)}><option>USDT</option><option>DAI</option></select>
          <label>Amount</label>
          <input className="form-input" type="number" value={amount} onChange={e=>setAmount(e.target.value)} />
          <div style={{display:'flex', gap:8, marginTop:8}}>
            <button className="button btn-primary" onClick={handleCreate}>Create Vault</button>
            <button className="button btn-ghost" onClick={()=>navigate('/dashboard')}>Cancel</button>
          </div>
        </div>
      </div>
    </div>
  );
}
