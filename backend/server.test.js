const request = require('supertest');
const app = require('../src/api/server'); // Supondo que seu código do servidor esteja no src/api/server.js
const mysql = require('mysql2');
const { v4: uuidv4 } = require('uuid');

jest.mock('mysql2', () => ({
  createConnection: jest.fn().mockReturnValue({
    query: jest.fn(),
    connect: jest.fn(),
  }),
}));

let db;

beforeAll(() => {
  db = mysql.createConnection();
});

afterEach(() => {
  jest.clearAllMocks();
});

describe('API Tasks Endpoints', () => {
  it('should fetch all tasks (GET /api/tasks)', async () => {
    const mockTasks = [
      { id: uuidv4(), description: 'Test task 1', isDone: false },
      { id: uuidv4(), description: 'Test task 2', isDone: true },
    ];

    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, mockTasks);
    });

    const response = await request(app).get('/api/tasks');
    expect(response.status).toBe(200);
    expect(response.body).toEqual(mockTasks);
  });

  it('should create a new task (POST /api/tasks)', async () => {
    const newTask = { description: 'New Task', isDone: false };
    const mockResponse = { id: uuidv4(), ...newTask };

    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, { insertId: 1 });
    });

    const response = await request(app).post('/api/tasks').send(newTask);
    expect(response.status).toBe(201);
    expect(response.body).toMatchObject(mockResponse);
  });

  it('should delete a task (DELETE /api/tasks/:id)', async () => {
    const taskId = uuidv4();
    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, { affectedRows: 1 });
    });

    const response = await request(app).delete(`/api/tasks/${taskId}`);
    expect(response.status).toBe(204);
  });

  it('should return 404 if task to delete does not exist (DELETE /api/tasks/:id)', async () => {
    const taskId = uuidv4();
    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, { affectedRows: 0 });
    });

    const response = await request(app).delete(`/api/tasks/${taskId}`);
    expect(response.status).toBe(404);
    expect(response.body.error).toBe('Tarefa não encontrada');
  });

  it('should update a task (PATCH /api/tasks/:id)', async () => {
    const taskId = uuidv4();
    const updateData = { isDone: true };
    const mockUpdatedTask = { id: taskId, description: 'Test task', isDone: true };

    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, { affectedRows: 1 });
    });

    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, [mockUpdatedTask]);
    });

    const response = await request(app).patch(`/api/tasks/${taskId}`).send(updateData);
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject(mockUpdatedTask);
  });

  it('should return 404 if task to update does not exist (PATCH /api/tasks/:id)', async () => {
    const taskId = uuidv4();
    const updateData = { isDone: true };

    db.query.mockImplementationOnce((query, params, callback) => {
      callback(null, { affectedRows: 0 });
    });

    const response = await request(app).patch(`/api/tasks/${taskId}`).send(updateData);
    expect(response.status).toBe(404);
    expect(response.body.error).toBe('Tarefa não encontrada');
  });
});
