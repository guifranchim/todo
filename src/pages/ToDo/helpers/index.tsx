import { v4 as uuidv4 } from "uuid";
import { Task } from "../../../models/Task";

export function createNewTask(description: string) {
    return {
        id: uuidv4(),
        description,
        isDone: false,
    };
}

export function removeTask(taskList: Task[], id: string) {
    return taskList.filter((task) => task.id !== id);
}

export function toggleTaskStatus(taskList: Task[], id: string) {
    return taskList.map((task) => {
        if (task.id === id) {
            return {
                ...task,
                isDone: !task.isDone,
            };
        }
        return task;
    });
}
