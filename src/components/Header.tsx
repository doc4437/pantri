import { ArrowUpTrayIcon, ArrowDownTrayIcon } from '@heroicons/react/24/outline';

type HeaderProps = {
  onImport: () => void;
  onExport: () => void;
};

const Header = ({ onImport, onExport }: HeaderProps) => {
  return (
    <header className="border-b border-leaf-100 bg-white/80 backdrop-blur">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-4">
        <div>
          <h1 className="text-2xl font-semibold text-leaf-800">Pantri</h1>
          <p className="text-sm text-leaf-600">
            Keep a calm pantry, text your grocery list in seconds.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={onImport}
            className="flex items-center gap-1 rounded-full border border-leaf-200 px-3 py-1.5 text-sm font-medium text-leaf-700 transition hover:border-leaf-400 hover:text-leaf-900 focus:outline-none focus-visible:ring-2 focus-visible:ring-leaf-500 focus-visible:ring-offset-2"
          >
            <ArrowDownTrayIcon className="h-4 w-4" />
            Import
          </button>
          <button
            onClick={onExport}
            className="flex items-center gap-1 rounded-full bg-leaf-700 px-3 py-1.5 text-sm font-semibold text-white shadow-sm transition hover:bg-leaf-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-leaf-500 focus-visible:ring-offset-2"
          >
            <ArrowUpTrayIcon className="h-4 w-4" />
            Export
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
