
import { v4 as uuidv4 } from "uuid";
import { describe, expect, it } from "vitest";
import { createNewTask, removeTask, toggleTaskStatus } from "..";

describe("createNewTask", () => {
  it("Deve criar uma nova tarefa com a descrição fornecida, um ID unico e uma propriedade isDone falsa.", () => {
    const newTask = createNewTask('Test task');

    expect(typeof newTask.id).toBe('string'); 
    expect(newTask.description).toBe('Test task');
    expect(newTask.isDone).toBe(false);
  });
});

describe("removeTask", () => {
  it("Deve  remover uma tarefa da lista dado o seu ID.", () => {
    const tasks = [
      { id: '1', description: 'Task 1', isDone: false },
      { id: '2', description: 'Task 2', isDone: false },
    ];

    const updatedTasks = removeTask(tasks, '1');

    expect(updatedTasks).toEqual([{ id: '2', description: 'Task 2', isDone: false }]);
  });
});

describe("toggleTaskStatus", () => {
  it("Deve remover uma tarefa da lista dado o seu ID.", () => {
    const tasks = [
      { id: '1', description: 'Task 1', isDone: false },
      { id: '2', description: 'Task 2', isDone: false },
    ];

    const updatedTasks = toggleTaskStatus(tasks, '1');

    expect(updatedTasks).toEqual([
      { id: '1', description: 'Task 1', isDone: true },
      { id: '2', description: 'Task 2', isDone: false },
    ]);
  });
});
