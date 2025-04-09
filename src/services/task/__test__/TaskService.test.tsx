import { beforeAll, describe, expect, it } from "vitest";
import MockAdapter from 'axios-mock-adapter';
import { api } from "../../../configs/api";
import { Task } from "../../../models/Task";
import { changeIsDone, createTask, deleteTask, getTasks } from "..";


const mock = new MockAdapter(api);

describe("<Task Services>", () => {

  beforeAll(() => {
    mock.reset();
  })



  it("GetTasks deve retornar uma lista de tarefas", async () => {
    const tasks: Task[] = [
      { id: '01', description: 'Teste 01', isDone: false },
      { id: '02', description: 'Teste 02', isDone: true },
      { id: '03', description: 'Teste 03', isDone: false }
    ]

    mock.onGet("/tasks").reply(200, tasks);

    const response = await getTasks();

    expect(response).toEqual(tasks);
  })

  it("CreateTask deve retornar uma nova tarefa", async () => {
    const tasks: Task =
      { id: '01', description: 'Teste 01', isDone: false }

    mock.onPost("/tasks").reply(201, tasks);

    const response = await createTask(tasks);

    expect(response).toEqual(tasks);
    expect(response.id).toEqual("01")
    expect(response.description).toEqual("Teste 01");
  })

  it("DeleteTask deve deletar uma tarefa", async () => {
    mock.onDelete("/tasks/1").reply(200);

    await expect(deleteTask("1")).resolves.toBeUndefined();
  })

  it("ChangeIsDone deve retornar uma task alterada", async () => {
    const task: Task =
      { id: '01', description: 'Teste 01', isDone: true }

    mock.onPatch("/tasks/1").reply(200, task);

    const response = await changeIsDone("1", { isDone: true });

    expect(response).toEqual(task);
  })


})