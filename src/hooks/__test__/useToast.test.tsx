import { renderHook, act } from '@testing-library/react-hooks';

import { describe, expect, it } from 'vitest';
import { ToastProvider } from '../../contexts/Toast';
import { useToast } from '../useToast';

describe('useToast', () => {
  it('Deve retornar o context', () => {
    const wrapper = ({ children }: any) => <ToastProvider>{children}</ToastProvider>;

    const { result } = renderHook(() => useToast(), { wrapper });

    expect(result.current).toHaveProperty('showToast');
    expect(result.current).toHaveProperty('isHidden');
  });


});
