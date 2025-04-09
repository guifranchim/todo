import { render, screen } from "@testing-library/react";
import ToDoContext, { ToDoContextProvider } from "..";
import { describe, expect, it } from "vitest";
import { useContext, useEffect } from "react";

describe("<ToDoContext>", () => {
  describe("ToDoContextProvider", () => {
    it("Deve renderizar os children quando passados como parâmetro", () => {
      render(
        <ToDoContextProvider>
          <h1>Testando o ToDo Context Provider</h1>
        </ToDoContextProvider>
      )
    
      const childElement = screen.getByText(/Testando o ToDo Context Provider/i);
      expect(childElement).not.toBeNull();
    });

    it("Deve iniciar com um estado vazio para a lista de tarefas", () => {
      let testState: any = null;
      render(
        <ToDoContextProvider>
          <TestComponent setTestState={(state: any) => (testState = state)} />
        </ToDoContextProvider>
      );
    
      expect(testState.taskListState).toBeDefined();
      expect(testState.taskListState).toBeInstanceOf(Array);
      expect(testState.taskListState.length).toEqual(0);
    });
    
  });
});


const TestComponent = ({ setTestState }: any) => {
  const { taskListState } = useContext(ToDoContext);
  useEffect(() => {
    setTestState({ taskListState });
  }, [taskListState, setTestState]);
  return null;
};
