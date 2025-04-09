import { ToDoContextProvider } from "../../contexts/ToDo";
import { ToastProvider } from "../../contexts/Toast";
import { Content } from "./components/Content";
import { Header } from "./components/Header";

function ToDo() {
  return (
    <>
      <Header />
      <ToastProvider>
        <ToDoContextProvider>
          <Content />
        </ToDoContextProvider>
      </ToastProvider>
    </>
  );
}

export default ToDo;
