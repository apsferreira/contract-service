import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { Templates } from './pages/Templates';
import { Contracts } from './pages/Contracts';
import { Analytics } from './pages/Analytics';

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/analytics" element={<Analytics />} />
          <Route path="/templates" element={<Templates />} />
          <Route path="/contracts" element={<Contracts />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;