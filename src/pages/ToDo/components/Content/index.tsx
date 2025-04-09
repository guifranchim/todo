import { ChangeEvent, useCallback, useEffect, useMemo, useState } from "react";

import Plus from "../../../../assets/plus.svg";
import useToDoContext from "../../../../hooks/useToDoContext";
import { useToast } from "../../../../hooks/useToast";
import {
  changeIsDone,
  createTask,
  deleteTask,
  getTasks,
} from "../../../../services/task";
import { createNewTask, removeTask, toggleTaskStatus } from "../../helpers";
import { MemoizedTodoList } from "../TodoList";
import styles from "./index.module.css";

export const Content = () => {
  const [description, setDescription] = useState<string>("");

  const { taskListState, setTaskListState } = useToDoContext();
  const { showToast } = useToast();

  const tasksDone = useMemo(
    () => taskListState.filter((task) => task.isDone !== false),
    [taskListState]
  );

  const disabledButton = useMemo(
    () => !description.length,
    [description.length]
  );

  const addTaskOnList = useCallback(() => {
    const newTask = createNewTask(description);

    createTask(newTask)
      .then((response) =>
        setTaskListState((currentValue) => [...currentValue, response])
      )
      .finally(() => {
        setDescription("");
        showToast({
          message: "Tarefa adicionada com sucesso",
          type: "success",
        });
      });
  }, [description, setTaskListState, showToast]);

  const removeTaskOnList = useCallback(
    (id: string) => {
      deleteTask(id).then(() =>
        setTaskListState((currentValue) => removeTask(currentValue, id))
      );
    },
    [setTaskListState]
  );

  const changeStatusCheckbox = useCallback(
    (id: string) => {
      const task = taskListState.find((task) => task.id === id);

      if (task) {
        changeIsDone(id, { isDone: !task.isDone });
        setTaskListState(toggleTaskStatus(taskListState, id));
      }
    },
    [setTaskListState, taskListState]
  );

  useEffect(() => {
    getTasks().then((response) => setTaskListState(response));
  }, [setTaskListState]);

  return (
    <section data-testid="content" className={styles.section_container}>
      <main>
        <article className={styles.input_container}>
          <input
            className={styles.input}
            type="text"
            value={description}
            placeholder="Adicione uma nova tarefa"
            onChange={(event: ChangeEvent<HTMLInputElement>) =>
              setDescription(event.target.value)
            }
          />
          <button
            className={styles.button}
            disabled={disabledButton}
            onClick={addTaskOnList}
          >
            Criar
            <img src={Plus} alt="Ícone de mais" />
          </button>
        </article>

        <article className={styles.content_header}>
          <article className={styles.tasks_container}>
            <p className={styles.tasks_created}>Tarefas Criadas</p>
            <span className={styles.span_value}>
              {taskListState.length}
            </span>
          </article>
          <article className={styles.tasks_container}>
            <p className={styles.tasks_done}>Concluídas</p>
            <span className={styles.span_value}>
              {" "}
              {tasksDone.length} de {taskListState.length}{" "}
            </span>
          </article>
        </article>

        <MemoizedTodoList
          onDelete={removeTaskOnList}
          onChangeCheckbox={changeStatusCheckbox}
        />
      </main>
    </section>
  );
};
