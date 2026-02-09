const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const cors = require('cors');
const { listNotes, addNote, editNote, deleteNote } = require('./tasks');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/notes', (req, res) => {
  res.json(listNotes());
});

app.post('/api/notes', (req, res) => {
  const { title, content } = req.body;
  if (!title || !content) return res.status(400).json({ error: 'Title and content required' });
  const note = addNote(title, content);
  res.status(201).json(note);
});

app.put('/api/notes/:id', (req, res) => {
  const { id } = req.params;
  const { title, content } = req.body;
  try {
    const note = editNote(id, title, content);
    res.json(note);
  } catch (e) {
    res.status(404).json({ error: e.message });
  }
});

app.delete('/api/notes/:id', (req, res) => {
  const { id } = req.params;
  try {
    deleteNote(id);
    res.json({ success: true });
  } catch (e) {
    res.status(404).json({ error: e.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
