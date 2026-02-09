let notes = [];
let nextId = 1;

function listNotes() {
  return notes;
}

function addNote(title, content) {
  const note = {
    id: String(nextId++),
    title,
    content
  };
  notes.push(note);
  return note;
}

function editNote(id, title, content) {
  const note = notes.find(n => n.id === id);
  if (!note) {
    throw new Error('Note not found');
  }
  note.title = title;
  note.content = content;
  return note;
}

function deleteNote(id) {
  const index = notes.findIndex(n => n.id === id);
  if (index === -1) {
    throw new Error('Note not found');
  }
  notes.splice(index, 1);
}
function __reset() {
  notes = [];
  nextId = 1;
}
module.exports = {
  listNotes,
  addNote,
  editNote,
  deleteNote,
  __reset  // for testing only
};
