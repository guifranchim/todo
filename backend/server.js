const express = require('express');
const mysql = require('mysql2');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');

const log = (severity, message, context = {}) => {
  const logEntry = {
    severity: severity, 
    message: message,
    context: context,
    timestamp: new Date().toISOString(),
  };
  
  console.log(JSON.stringify(logEntry));
};

const dbConfig = {
  host: process.env.DB_HOST || 'db-service',
  user: process.env.DB_USER || 'mysql',
  password: process.env.DB_PASSWORD || 'mysql',
  database: process.env.DB_DATABASE || 'tasks_db',
};

const db = mysql.createConnection(dbConfig);

const createTableQuery = `
  CREATE TABLE IF NOT EXISTS tasks (
    id VARCHAR(36) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    isDone BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
`;

log('INFO', 'Iniciando conexão com o banco de dados', { dbConfig });

db.connect((err) => {
  if (err) {
    log('ERROR', 'Erro ao conectar ao banco de dados', { error: err.stack });
    return;
  }
  log('INFO', 'Conectado ao banco de dados com sucesso.');
  
  db.query(createTableQuery, (err, results) => {
    if (err) {
      log('ERROR', 'Erro ao criar a tabela "tasks"', { error: err.stack });
      return;
    }
    log('INFO', 'Tabela "tasks" verificada/criada com sucesso.');
  });
});

const app = express();
app.use(express.json());
app.use(cors());


app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    log('INFO', `Requisição HTTP concluída`, {
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      durationMs: duration,
      ip: req.ip,
    });
  });
  next();
});

app.get('/api/tasks', (req, res) => {
  db.query('SELECT * FROM tasks', (err, results) => {
    if (err) {
      log('ERROR', 'Erro ao obter as tarefas do banco de dados', { error: err });
      return res.status(500).json({ error: 'Erro ao obter as tarefas' });
    }
    res.json(results);
  });
});

app.post('/api/tasks', (req, res) => {
  const { description, isDone } = req.body;
  if (typeof description !== 'string' || description.trim() === '') {
    log('WARNING', 'Tentativa de criar tarefa com descrição inválida', { body: req.body });
    return res.status(400).json({ error: 'A descrição é obrigatória e não pode ser vazia.' });
  }
  
  const id = uuidv4();
  const query = 'INSERT INTO tasks (id, description, isDone) VALUES (?, ?, ?)';
  
  db.query(query, [id, description, isDone], (err, result) => {
    if (err) {
      log('ERROR', 'Erro ao inserir tarefa no banco de dados', { error: err, queryContext: { id, description } });
      return res.status(500).json({ error: 'Erro ao criar a tarefa' });
    }
    log('INFO', 'Nova tarefa criada com sucesso', { taskId: id });
    res.status(201).json({ id, description, isDone });
  });
});

app.delete('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM tasks WHERE id = ?', [id], (err, result) => {
    if (err) {
      log('ERROR', 'Erro ao excluir tarefa do banco de dados', { error: err, taskId: id });
      return res.status(500).json({ error: 'Erro ao excluir a tarefa' });
    }
    if (result.affectedRows === 0) {
      log('WARNING', 'Tentativa de excluir tarefa não encontrada', { taskId: id });
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }
    log('INFO', 'Tarefa excluída com sucesso', { taskId: id });
    res.status(204).send();
  });
});

app.patch('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const { isDone } = req.body;

  if (typeof isDone !== 'boolean') {
    log('WARNING', 'Tentativa de atualizar tarefa com status inválido', { body: req.body, taskId: id });
    return res.status(400).json({ error: 'O campo isDone é obrigatório e deve ser um booleano.' });
  }

  db.query('UPDATE tasks SET isDone = ? WHERE id = ?', [isDone, id], (err, result) => {
    if (err) {
      log('ERROR', 'Erro ao atualizar tarefa no banco de dados', { error: err, taskId: id });
      return res.status(500).json({ error: 'Erro ao atualizar a tarefa' });
    }
    if (result.affectedRows === 0) {
      log('WARNING', 'Tentativa de atualizar tarefa não encontrada', { taskId: id });
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }
    db.query('SELECT * FROM tasks WHERE id = ?', [id], (err, rows) => {
      if (err) {
        log('ERROR', 'Erro ao recuperar tarefa atualizada', { error: err, taskId: id });
        return res.status(500).json({ error: 'Erro ao recuperar a tarefa atualizada' });
      }
      log('INFO', 'Tarefa atualizada com sucesso', { taskId: id, isDone: isDone });
      res.json(rows[0]);
    });
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  log('INFO', `Servidor iniciado e escutando na porta ${PORT}`);
});