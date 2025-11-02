import { Dialog, Transition } from '@headlessui/react';
import { Fragment, useEffect, useState } from 'react';
import { ClipboardDocumentIcon, PaperAirplaneIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { PantriItem } from '../types';

type ShareDrawerProps = {
  open: boolean;
  onClose: () => void;
  items: PantriItem[];
  shareText: string;
  autoreset: boolean;
  onToggleAutoreset: (value: boolean) => void;
  onCopy: (message: string) => void;
  onSms: (message: string) => void;
};

const ShareDrawer = ({
  open,
  onClose,
  items,
  shareText,
  autoreset,
  onToggleAutoreset,
  onCopy,
  onSms
}: ShareDrawerProps) => {
  const [message, setMessage] = useState(shareText);

  useEffect(() => {
    setMessage(shareText);
  }, [shareText, items]);

  return (
    <Transition show={open} as={Fragment}>
      <Dialog as="div" className="relative z-40" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-200"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-150"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black/30" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-hidden">
          <div className="absolute inset-0 flex items-end justify-center">
            <Transition.Child
              as={Fragment}
              enter="transform transition ease-in-out duration-300"
              enterFrom="translate-y-full"
              enterTo="translate-y-0"
              leave="transform transition ease-in-out duration-200"
              leaveFrom="translate-y-0"
              leaveTo="translate-y-full"
            >
              <Dialog.Panel className="w-full max-w-2xl rounded-t-3xl bg-white p-6 shadow-2xl">
                <div className="mb-4 flex items-start justify-between">
                  <div>
                    <Dialog.Title className="text-lg font-semibold text-leaf-800">
                      Share {items.length} item{items.length === 1 ? '' : 's'}
                    </Dialog.Title>
                    <p className="text-sm text-leaf-500">
                      Compose a friendly SMS-ready list.
                    </p>
                  </div>
                  <button
                    onClick={onClose}
                    className="rounded-full p-2 text-leaf-500 transition hover:bg-leaf-100"
                  >
                    <XMarkIcon className="h-5 w-5" />
                  </button>
                </div>
                <textarea
                  value={message}
                  onChange={(event) => setMessage(event.target.value)}
                  rows={6}
                  className="w-full rounded-xl border border-leaf-200 px-3 py-2 text-sm focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                />
                <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
                  <label className="flex items-center gap-2 text-sm text-leaf-600">
                    <input
                      type="checkbox"
                      checked={autoreset}
                      onChange={(event) => onToggleAutoreset(event.target.checked)}
                      className="h-4 w-4 rounded border-leaf-300 text-leaf-600 focus:ring-leaf-500"
                    />
                    Auto-reset selection after sharing
                  </label>
                  <div className="flex gap-2">
                    <button
                      onClick={() => onCopy(message)}
                      className="flex items-center gap-2 rounded-full border border-leaf-300 px-4 py-2 text-sm font-semibold text-leaf-700 hover:border-leaf-400"
                    >
                      <ClipboardDocumentIcon className="h-4 w-4" /> Copy
                    </button>
                    <button
                      onClick={() => onSms(message)}
                      className="flex items-center gap-2 rounded-full bg-leaf-600 px-4 py-2 text-sm font-semibold text-white hover:bg-leaf-500"
                    >
                      <PaperAirplaneIcon className="h-4 w-4" /> Open SMS
                    </button>
                  </div>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};

export default ShareDrawer;
