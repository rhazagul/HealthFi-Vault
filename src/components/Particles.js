import React, { useEffect, useState } from 'react';

export default function Particles(){
  const [particles, setParticles] = useState([]);

  useEffect(()=>{
    const temp = [];
    for(let i=0;i<35;i++){
      temp.push({id:i, x: Math.random()*window.innerWidth, y: Math.random()*window.innerHeight, size: 2+Math.random()*6, vx:0, vy:0});
    }
    setParticles(temp);

    const handleMove = (e)=>{
      setParticles(prev => prev.map(p=>{
        const dx = e.clientX - p.x; const dy = e.clientY - p.y; const dist = Math.sqrt(dx*dx+dy*dy);
        const force = Math.min(0.25, 120/(dist+10));
        return {...p, vx: p.vx + dx*force*0.002, vy: p.vy + dy*force*0.002};
      }));
    }

    window.addEventListener('mousemove', handleMove);
    const t = setInterval(()=>{
      setParticles(prev=> prev.map(p=>{
        let x = p.x + p.vx; let y = p.y + p.vy; let vx = p.vx*0.86; let vy = p.vy*0.86;
        if(x< -20) x = window.innerWidth; if(x>window.innerWidth+20) x=0;
        if(y< -20) y = window.innerHeight; if(y>window.innerHeight+20) y=0;
        return {...p, x, y, vx, vy};
      }));
    },16);

    return ()=>{ window.removeEventListener('mousemove', handleMove); clearInterval(t); }
  },[]);

  return (
    <>
      {particles.map(p=> (<div key={p.id} className="particle" style={{left: p.x+'px', top: p.y+'px', width: p.size+'px', height: p.size+'px'}}></div>))}
    </>
  )
}
