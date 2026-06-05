const express = require('express');
const cors = require('cors');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
const PORT = 8081;

app.use(cors());
app.use(express.json());

const db = new Database(path.join(__dirname, 'scolarite.db'));

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user'
  );

  CREATE TABLE IF NOT EXISTS classes (
    codClass INTEGER PRIMARY KEY AUTOINCREMENT,
    nomClass TEXT NOT NULL,
    nbreEtud INTEGER
  );

  CREATE TABLE IF NOT EXISTS etudiants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codClass INTEGER,
    nom TEXT,
    prenom TEXT,
    datNais TEXT,
    FOREIGN KEY (codClass) REFERENCES classes(codClass)
  );

  CREATE TABLE IF NOT EXISTS formations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titre TEXT NOT NULL,
    description TEXT,
    duree INTEGER
  );
`);

// Seed admin user
const existing = db.prepare('SELECT * FROM users WHERE email = ?').get('admin@gmail.com');
if (!existing) {
  db.prepare('INSERT INTO users (email, password, role) VALUES (?, ?, ?)').run('admin@gmail.com', 'admin', 'admin');
  console.log('Admin user seeded.');
}

// Seed some classes
const classCount = db.prepare('SELECT COUNT(*) as count FROM classes').get();
if (classCount.count === 0) {
  db.prepare('INSERT INTO classes (nomClass, nbreEtud) VALUES (?, ?)').run('IngTA2-A', 30);
  db.prepare('INSERT INTO classes (nomClass, nbreEtud) VALUES (?, ?)').run('IngTA2-B', 26);
  db.prepare('INSERT INTO classes (nomClass, nbreEtud) VALUES (?, ?)').run('IngTA2-C', 28);
  console.log('Classes seeded.');
}

// ─── MIDDLEWARE: simple role check ──────────────────────────────────────────
function requireAdmin(req, res, next) {
  const role = req.headers['x-role'];
  if (role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required.' });
  }
  next();
}

// ─── USER ROUTES ─────────────────────────────────────────────────────────────

app.post('/register', (req, res) => {
  const { email, password, role } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required.' });
  try {
    const result = db.prepare('INSERT INTO users (email, password, role) VALUES (?, ?, ?)').run(email, password, role || 'user');
    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(result.lastInsertRowid);
    return res.status(200).json(user);
  } catch (e) {
    return res.status(409).json({ error: 'Email already exists.' });
  }
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = db.prepare('SELECT * FROM users WHERE email = ? AND password = ?').get(email, password);
  if (user) return res.status(200).json(user);
  return res.status(401).json({ error: 'Invalid credentials.' });
});

app.get('/users', (req, res) => {
  const users = db.prepare('SELECT id, email, role FROM users').all();
  return res.status(200).json(users);
});

// ─── CLASSES ROUTES ──────────────────────────────────────────────────────────

app.get('/classes', (req, res) => {
  const classes = db.prepare('SELECT * FROM classes').all();
  return res.status(200).json(classes);
});

app.post('/classes', requireAdmin, (req, res) => {
  const { nomClass, nbreEtud } = req.body;
  const result = db.prepare('INSERT INTO classes (nomClass, nbreEtud) VALUES (?, ?)').run(nomClass, nbreEtud);
  const cls = db.prepare('SELECT * FROM classes WHERE codClass = ?').get(result.lastInsertRowid);
  return res.status(200).json(cls);
});

app.put('/classes/:id', requireAdmin, (req, res) => {
  const { nomClass, nbreEtud } = req.body;
  db.prepare('UPDATE classes SET nomClass = ?, nbreEtud = ? WHERE codClass = ?').run(nomClass, nbreEtud, req.params.id);
  const cls = db.prepare('SELECT * FROM classes WHERE codClass = ?').get(req.params.id);
  return res.status(200).json(cls);
});

app.delete('/classes/:id', requireAdmin, (req, res) => {
  db.prepare('DELETE FROM classes WHERE codClass = ?').run(req.params.id);
  return res.status(200).json({ message: 'Class deleted.' });
});

// ─── ETUDIANTS ROUTES ────────────────────────────────────────────────────────

app.get('/etudiants', (req, res) => {
  const { codClass } = req.query;
  let students;
  if (codClass && codClass !== '0') {
    students = db.prepare('SELECT * FROM etudiants WHERE codClass = ?').all(codClass);
  } else {
    students = db.prepare('SELECT * FROM etudiants').all();
  }
  return res.status(200).json(students);
});

app.post('/etudiants', requireAdmin, (req, res) => {
  const { codClass, nom, prenom, datNais } = req.body;
  const result = db.prepare('INSERT INTO etudiants (codClass, nom, prenom, datNais) VALUES (?, ?, ?, ?)').run(codClass, nom, prenom, datNais);
  const etud = db.prepare('SELECT * FROM etudiants WHERE id = ?').get(result.lastInsertRowid);
  return res.status(200).json(etud);
});

app.put('/etudiants/:id', requireAdmin, (req, res) => {
  const { nom, prenom, datNais } = req.body;
  db.prepare('UPDATE etudiants SET nom = ?, prenom = ?, datNais = ? WHERE id = ?').run(nom, prenom, datNais, req.params.id);
  const etud = db.prepare('SELECT * FROM etudiants WHERE id = ?').get(req.params.id);
  return res.status(200).json(etud);
});

app.delete('/etudiants/:id', requireAdmin, (req, res) => {
  db.prepare('DELETE FROM etudiants WHERE id = ?').run(req.params.id);
  return res.status(200).json({ message: 'Student deleted.' });
});

// ─── FORMATIONS ROUTES ───────────────────────────────────────────────────────

app.get('/formations', (req, res) => {
  const formations = db.prepare('SELECT * FROM formations').all();
  return res.status(200).json(formations);
});

app.post('/formations', requireAdmin, (req, res) => {
  const { titre, description, duree } = req.body;
  const result = db.prepare('INSERT INTO formations (titre, description, duree) VALUES (?, ?, ?)').run(titre, description, duree);
  const formation = db.prepare('SELECT * FROM formations WHERE id = ?').get(result.lastInsertRowid);
  return res.status(200).json(formation);
});

app.put('/formations/:id', requireAdmin, (req, res) => {
  const { titre, description, duree } = req.body;
  db.prepare('UPDATE formations SET titre = ?, description = ?, duree = ? WHERE id = ?').run(titre, description, duree, req.params.id);
  const formation = db.prepare('SELECT * FROM formations WHERE id = ?').get(req.params.id);
  return res.status(200).json(formation);
});

app.delete('/formations/:id', requireAdmin, (req, res) => {
  db.prepare('DELETE FROM formations WHERE id = ?').run(req.params.id);
  return res.status(200).json({ message: 'Formation deleted.' });
});

// ─── START ───────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});