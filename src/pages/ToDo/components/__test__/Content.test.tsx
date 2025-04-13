import { render, screen } from "@testing-library/react";
import { beforeAll, describe, expect, it } from "vitest";


import userEvent from '@testing-library/user-event';
import { ToastProvider } from "../../../../contexts/Toast";
import { ToDoContextProvider } from "../../../../contexts/ToDo";
import { Content } from "../Content";


describe("<Content>", () => {

  it("Deve renderizar o componente corretamente", () => {
    render(
      <ToastProvider>
        <ToDoContextProvider>
          <Content />
        </ToDoContextProvider>
      </ToastProvider>
    );
    
    const inputElement = screen.getByPlaceholderText(/Adicione uma nova tarefa/i);
    const buttonElement = screen.getByText(/Criar/i);
    
    expect(inputElement).to.exist;
    expect(buttonElement).to.exist;
  });

  it("Deve desabilitar o botão se a descrição estiver vazia", () => {
    render(
      <ToastProvider>
        <ToDoContextProvider>
          <Content />
        </ToDoContextProvider>
      </ToastProvider>
    );
    
    const buttons = screen.getAllByRole('button', { name: /Criar/i });
    const button = buttons[0]; 
    
    expect(button).to.have.property('disabled', true);
  });

  it("Deve habilitar o botão se a descrição não estiver vazia", () => {
    render(
      <ToastProvider>
        <ToDoContextProvider>
          <Content />
        </ToDoContextProvider>
      </ToastProvider>
    )
    
    const inputElement = screen.getByPlaceholderText(/Adicione uma nova tarefa/i);
    const buttonElement = screen.getByRole('button', { name: /Criar/i });

    
    userEvent.type(inputElement, 'New task');

    expect(buttonElement).to.have.property('disabled', false);
  });
});