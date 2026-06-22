export default function Home() {
  return (
    <main className="flex min-h-full flex-col items-center justify-center p-8">
      <h1 className="text-3xl font-semibold tracking-tight">UAPKB</h1>
      <p className="mt-4 text-lg text-zinc-600 dark:text-zinc-400">AI-first reference repository</p>
      <button
        type="button"
        className="mt-6 rounded-full bg-green-600 px-5 py-2.5 text-sm font-medium text-white transition hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 focus:ring-offset-white dark:focus:ring-offset-zinc-950"
      >
        Do nothing
      </button>
    </main>
  );
}
