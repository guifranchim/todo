import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { ToastProvider } from "..";
import { useToast } from "../../../hooks/useToast";
import { useEffect } from "react";

describe("<ToastContext>", () => {
  describe("ToastProvider", () => {
    it("Deve renderizar um children quando passado por parâmetro", () => {
      render(<ToastProvider>
        <h1>Testando o toast Provider</h1>
      </ToastProvider>)

      const childElement = screen.getByText(/Testando o toast Provider/i);
      expect(childElement).not.toBeNull();

    })

    it("Deve exibir um toast quando a função 'showToast' for chamada", async () => {
      const TestComponent = () => {
        const { showToast } = useToast();

        useEffect(() => {
          showToast({
            message: 'Testando a exibição do toast',
            type: 'success'
          })
        }, [])

        return null
      }

      render(<ToastProvider>
        <TestComponent />
      </ToastProvider>)

      const toastElement = await screen
        .findByText(/Testando a exibição do toast/i);

      expect(toastElement).not.toBeNull();
    })
  })
})