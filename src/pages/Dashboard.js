import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

export default function Dashboard(){
  const [vaults, setVaults] = useState([]);

  useEffect(()=>{
    const data = JSON.parse(localStorage.getItem('hf_vaults') || 'null');
    if(data) setVaults(data);
    else {
      const mock = [
        {id:1, title:'Dental Care Vault', token:'USDT', deposit:0.00, yield:0.00, verified:false},
        {id:2, title:'Annual Checkup Vault', token:'DAI', deposit:0.00, yield:0.00, verified:true},
        {id:3, title:'Wellness Program Vault', token:'USDT', deposit:0.00, yield:0.00, verified:false}
      ];
      localStorage.setItem('hf_vaults', JSON.stringify);
      setVaults;
    }
  },[]);

  const handleVerify = (id)=>{
    const updated = vaults.map(v=> v.id===id? {...v, verified:true} : v);
    setVaults(updated); localStorage.setItem('hf_vaults', JSON.stringify(updated));
    alert('Vault marked as verified ');
  }

  const handleWithdraw = (id)=>{
    alert('Withdraw simulated for vault ' + id);
  }

  return (
    <div className="container">
      <motion.h2 initial={{opacity:0}} animate={{opacity:1}} className="title">Your Vaults</motion.h2>
      <p className="subtitle">Manage your health-tagged savings.</p>
      <div className="grid" style={{marginTop:12}}>
        {vaults.map((v,i)=>(
          <motion.div key={v.id} className="vault glass animated" initial={{opacity:0,y:8}} animate={{opacity:1,y:0}} transition={{delay:i*0.1}}>
            <h3 style={{margin:0}}>{v.title}</h3>
            <div style={{marginTop:8}}><span className="badge">{v.token}</span> <span style={{marginLeft:8}}>Deposit: <strong>${v.deposit}</strong></span></div>
            <div style={{marginTop:8}}>Yield: <strong>${v.yield}</strong></div>
            <div className="actions">
              <button className="button btn-ghost" onClick={()=>alert('View details')}>View</button>
              <button className="button btn-primary" onClick={()=>handleWithdraw(v.id)} disabled={!v.verified}>Withdraw</button>
              {!v.verified && <button className="button" style={{background:'linear-gradient(90deg,#ff4d6d,#7c3aed)', color:'#fff'}} onClick={()=>handleVerify(v.id)}>Verify</button>}
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
