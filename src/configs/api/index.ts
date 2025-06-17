import axios, { AxiosRequestConfig } from "axios";

export const api = axios.create({
  baseURL: "/todo/api",
});

export const apiRequest = async <T>(config: AxiosRequestConfig): Promise<T> => {
  try {
    const response = await api(config);
    return response.data;
  } catch (error) {
    console.error(error);
    throw error;
  }
};
