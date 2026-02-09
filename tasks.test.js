// tasks.test.js
const { listNotes, addNote, editNote, deleteNote } = require('./tasks');

beforeEach(() => {
  // Reset the in-memory notes array and id counter
  const tasks = require('./tasks');
  tasks.__reset && tasks.__reset(); // optional if you add a reset function
});

test('addNote adds a note', () => {
  const note = addNote('Test', 'Content');
  expect(note.title).toBe('Test');
  expect(note.content).toBe('Content');
  const notes = listNotes();
  expect(notes.length).toBe(1);
});

test('editNote edits a note', () => {
  const note = addNote('Test', 'Content');
  const edited = editNote(note.id, 'New Title', 'New Content');
  expect(edited.title).toBe('New Title');
  expect(edited.content).toBe('New Content');
});

test('deleteNote deletes a note', () => {
  const note = addNote('Test', 'Content');
  deleteNote(note.id);
  const notes = listNotes();
  expect(notes.length).toBe(0);
});

test('listNotes returns all notes', () => {
  addNote('A', 'B');
  addNote('C', 'D');
  const notes = listNotes();
  expect(notes.length).toBe(2);
});
