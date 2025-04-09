import { renderHook, act } from '@testing-library/react-hooks';

import { describe, expect, it } from 'vitest';
import { ToDoContextProvider } from '../../contexts/ToDo';
import useToDoContext from '../useToDoContext';

describe('useToDoContext', () => {
  it('Deve retornar o context', () => {
    const wrapper = ({ children }: any) => <ToDoContextProvider>{children}</ToDoContextProvider>;

    const { result } = renderHook(() => useToDoContext(), { wrapper });

    expect(result.current).toHaveProperty('taskListState');
    expect(result.current).toHaveProperty('setTaskListState');
  });

 
});
