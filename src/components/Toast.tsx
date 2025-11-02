import { useCallback, useState } from 'react';
import { CheckCircleIcon, ExclamationTriangleIcon, XCircleIcon } from '@heroicons/react/24/solid';

export type ToastMessage = {
  id: number;
  type: 'success' | 'info' | 'error';
  title: string;
};

type ToastHostProps = {
  queue: ToastMessage[];
  onDismiss: (id: number) => void;
};

const iconForType = (type: ToastMessage['type']) => {
  switch (type) {
    case 'success':
      return <CheckCircleIcon className="h-5 w-5 text-green-500" />;
    case 'error':
      return <XCircleIcon className="h-5 w-5 text-red-500" />;
    default:
      return <ExclamationTriangleIcon className="h-5 w-5 text-yellow-500" />;
  }
};

export const useToastQueue = () => {
  const [queue, setQueue] = useState<ToastMessage[]>([]);
  const push = useCallback((toast: Omit<ToastMessage, 'id'>) => {
    setQueue((prev) => [...prev, { ...toast, id: Date.now() + Math.random() }]);
  }, []);
  const shift = useCallback((id?: number) => {
    setQueue((prev) => (id ? prev.filter((toast) => toast.id !== id) : prev.slice(1)));
  }, []);

  return { queue, push, shift };
};

const ToastHost = ({ queue, onDismiss }: ToastHostProps) => {
  return (
    <div className="pointer-events-none fixed inset-x-0 bottom-6 flex flex-col items-center gap-2">
      {queue.map((toast) => (
        <div
          key={toast.id}
          className="pointer-events-auto flex items-center gap-3 rounded-full bg-white/95 px-4 py-2 shadow-lg"
        >
          {iconForType(toast.type)}
          <span className="text-sm font-medium text-leaf-700">{toast.title}</span>
          <button
            onClick={() => onDismiss(toast.id)}
            className="text-xs font-semibold uppercase text-leaf-500 hover:text-leaf-700"
          >
            Dismiss
          </button>
        </div>
      ))}
    </div>
  );
};

export default ToastHost;
