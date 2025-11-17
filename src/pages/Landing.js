import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Landing(){
  return (
    <div className="container">
      <motion.div initial={{opacity:0, y:-8}} animate={{opacity:1, y:0}} className="glass" style={{padding:28}}>
        <h1 className="title">Empowering Health Through Decentralized Finance</h1>
        <p className="subtitle">HealthFi Vault helps you save, earn yield, and unlock funds when you meet verified health milestones.</p>
        <div style={{display:'flex', gap:12}}>
          <Link to="/signup"><button className="button btn-primary">Get Started</button></Link>
          <Link to="/dashboard"><button className="button btn-ghost">Explore Vaults</button></Link>
        </div>
        <div className="grid-cards" style={{marginTop:20}}>
          <div className="goal glass"><div className="glow"></div><h3>Select Health Goal</h3><p style={{color:'#bcd7ef'}}>Choose a preventive objective and start saving.</p></div>
          <div className="goal glass"><div className="glow"></div><h3>Deposit & Earn</h3><p style={{color:'#bcd7ef'}}>Your funds grow using optimized DeFi strategies.</p></div>
          <div className="goal glass"><div className="glow"></div><h3>Verify Milestone</h3><p style={{color:'#bcd7ef'}}>Complete care at verified clinics to unlock funds.</p></div>
          <div className="goal glass"><div className="glow"></div><h3>Unlock Rewards</h3><p style={{color:'#bcd7ef'}}>Access funds, bonus yields, or health loans.</p></div>
        </div>
      </motion.div>
    </div>
  );
}
