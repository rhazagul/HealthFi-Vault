import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Home from './pages/Home';
import Landing from './pages/Landing';
import Dashboard from './pages/Dashboard';
import CreateVault from './pages/CreateVault';
import Login from './pages/Login';
import Signup from './pages/Signup';
import Settings from './pages/Settings';
import Navbar from './components/Navbar';
import Particles from './components/Particles';

function RequireAuth({ children }){
  const user = JSON.parse(localStorage.getItem('hf_user') || 'null');
  return user ? children : <Navigate to="/login" replace />;
}

export default function App(){
  return (
    <Router>
      <div className="app-bg">
        <Particles />
        <Navbar />
        <Routes>
          <Route path='/' element={<Landing />} />
          <Route path='/home' element={<Home />} />
          <Route path='/login' element={<Login />} />
          <Route path='/signup' element={<Signup />} />
          <Route path='/dashboard' element={
            <RequireAuth><Dashboard /></RequireAuth>
          } />
          <Route path='/create-vault' element={
            <RequireAuth><CreateVault /></RequireAuth>
          } />
          <Route path='/settings' element={
            <RequireAuth><Settings /></RequireAuth>
          } />
        </Routes>
      </div>
    </Router>
  );
}
