import { AxiosRequestConfig } from "axios";
import { apiRequest } from "../../configs/api";
import { Task } from "../../models/Task";

export const getTasks = async (): Promise<Task[]> => {
  const config: AxiosRequestConfig = {
    method: "GET",
    url: "/tasks",
  };
  return await apiRequest<Task[]>(config);
};

export const createTask = async (data: Task): Promise<Task> => {
  const config: AxiosRequestConfig = {
    method: "POST",
    url: "/tasks",
    data,
  };
  return await apiRequest<Task>(config);
};

export const deleteTask = async (id: string): Promise<void> => {
  const config: AxiosRequestConfig = {
    method: "DELETE",
    url: `/tasks/${id}`,
  };
  return await apiRequest<void>(config);
};

export const changeIsDone = async (
  id: string,
  data: {
    isDone: boolean;
  }
): Promise<Task> => {
  const config: AxiosRequestConfig = {
    method: "PATCH",
    url: `/tasks/${id}`,
    data,
  };
  return await apiRequest<Task>(config);
};
