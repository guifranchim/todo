import { createContext, useState } from "react";
import { Task } from "../../models/Task";

type ToDoContextProviderProps = {
    children: React.ReactNode
}

export type ToDoContextProps = {
    taskListState: Task[],
    setTaskListState: React.Dispatch<React.SetStateAction<Task[]>>;
}

const DEFAULT_VALUES = {
    taskListState: [],
    setTaskListState: () => [{}]
}

const ToDoContext = createContext<ToDoContextProps>(DEFAULT_VALUES);

const ToDoContextProvider = ({ children }: ToDoContextProviderProps) => {
    const [taskListState, setTaskListState] = useState<Task[]>([]);

    return (
        <ToDoContext.Provider value={{
            taskListState,
            setTaskListState
        }}>
            {children}
        </ToDoContext.Provider>
    );
}

export { ToDoContextProvider };

export default ToDoContext;