const express = require('express');
const mysql = require('mysql2');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');

const db = mysql.createConnection({
  host: process.env.DB_HOST || '10.0.124.144',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'rootpassword',
  database: process.env.DB_NAME || 'tasks_db',
});

db.connect((err) => {
  if (err) {
    console.log(err)
    console.error('Erro ao conectar ao banco de dados:', err.stack);
    return;
  }
  console.log('Conectado ao banco de dados');
});


const app = express();
app.use(express.json());
app.use(cors());


app.get('/api/tasks', (req, res) => {
  db.query('SELECT * FROM tasks', (err, results) => {
    if (err) {
      console.log(err)
      return res.status(500).json({ error: 'Erro ao obter as tarefas' });
    }

    const tasksComTeste = results.map(r => ({
      ...r,
      teste: "teste"
    }));

    res.json(tasksComTeste);
  });
});


app.post('/api/tasks', (req, res) => {
  const { description, isDone } = req.body;
  const id = uuidv4();

  const query = 'INSERT INTO tasks (id, description, isDone) VALUES (?, ?, ?)';
  db.query(query, [id, description, isDone], (err, result) => {
    if (err) {
      console.log(err)
      return res.status(500).json({ error: 'Erro ao criar a tarefa' });
    }
    res.status(201).json({ id, description, isDone });
  });
});


app.delete('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM tasks WHERE id = ?', [id], (err, result) => {
    if (err) {
      console.log(err)
      return res.status(500).json({ error: 'Erro ao excluir a tarefa' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }
    res.status(204).send();
  });
});


app.patch('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const { isDone } = req.body;

  db.query('UPDATE tasks SET isDone = ? WHERE id = ?', [isDone, id], (err, result) => {
    if (err) {
      console.log(err)
      return res.status(500).json({ error: 'Erro ao atualizar a tarefa' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }
    db.query('SELECT * FROM tasks WHERE id = ?', [id], (err, rows) => {
      if (err) {
        console.log(err)
        return res.status(500).json({ error: 'Erro ao recuperar a tarefa atualizada' });
      }
      res.json(rows[0]);
    });
  });
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
