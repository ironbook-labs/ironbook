export default function Docs() {
  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-900 dark:bg-black dark:text-zinc-100">
      <div className="mx-auto flex max-w-7xl">
        {/* Sidebar */}
        <aside className="sticky top-0 hidden h-screen w-64 shrink-0 border-r border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-black lg:block">
          <h2 className="mb-6 text-lg font-semibold">Contents</h2>

          <nav className="space-y-3 text-sm">
            <a
              href="#about"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              About
            </a>

            <a
              href="#development"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Development
            </a>

            <a
              href="#philosophy"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Philosophy
            </a>

            <a
              href="#project-structure"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Project Structure
            </a>

            <a
              href="#directory-structure"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Directory Structure
            </a>

            <a
              href="#setup"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Setup
            </a>

            <a
              href="#todo"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Todo
            </a>

            <a
              href="#users"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Users
            </a>

            <a
              href="#features"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Features
            </a>

            <a
              href="#complaints"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Complaints
            </a>

            <a
              href="#self-deployment"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Self Deployment
            </a>

            <a
              href="/docs/architecture"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Architecture docs
            </a>

            <a
              href="/docs/security"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Security docs
            </a>

            <a
              href="/docs/privacy"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Privacy Policy
            </a>
          </nav>
        </aside>

        {/* Mobile navigation (collapsible; desktop uses the sidebar above) */}
        <details className="border-b border-zinc-200 bg-white p-4 dark:border-zinc-800 dark:bg-black lg:hidden">
          <summary className="cursor-pointer text-sm font-semibold">
            Contents
          </summary>
          <nav className="mt-4 space-y-3 text-sm">
            <a
              href="#about"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              About
            </a>
            <a
              href="#development"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Development
            </a>
            <a
              href="#philosophy"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Philosophy
            </a>
            <a
              href="#project-structure"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Project Structure
            </a>
            <a
              href="#directory-structure"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Directory Structure
            </a>
            <a
              href="#setup"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Setup
            </a>
            <a
              href="#todo"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Todo
            </a>
            <a
              href="#users"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Users
            </a>
            <a
              href="#features"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Features
            </a>
            <a
              href="#complaints"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Complaints
            </a>
            <a
              href="#self-deployment"
              className="ml-3 block text-zinc-500 transition hover:text-black dark:text-zinc-500 dark:hover:text-white"
            >
              Self Deployment
            </a>
            <a
              href="/docs/architecture"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Architecture docs
            </a>
            <a
              href="/docs/security"
              className="block text-zinc-600 transition hover:text-black dark:text-zinc-400 dark:hover:text-white"
            >
              Security docs
            </a>
          </nav>
        </details>

        {/* Main */}
        <main className="min-w-0 flex-1 px-6 py-16 sm:px-12 lg:px-20">
          <div className="mx-auto max-w-5xl space-y-24">
            {/* Hero */}
            <section className="space-y-6">
              <div className="inline-flex items-center rounded-full border border-zinc-300 bg-white px-3 py-1 text-xs font-medium dark:border-zinc-700 dark:bg-zinc-900">
                Documentation
              </div>

              <div className="space-y-3">
                <h1 className="text-4xl sm:text-5xl font-black tracking-tight">
                  Project Iron Book
                </h1>

                <h2 className="text-xl text-zinc-600 dark:text-zinc-400">
                  A Digital Financial Ledger
                </h2>
              </div>

              <p className="max-w-3xl text-lg leading-8 text-zinc-700 dark:text-zinc-300">
                This repo (if I finish it) is my biggest achievement till now
                because of its 3 main features.
              </p>

              <div className="grid gap-4 md:grid-cols-3">
                <div className="rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                  <h3 className="mb-2 font-semibold">Polyglot Monorepo</h3>

                  <p className="text-sm leading-6 text-zinc-600 dark:text-zinc-400">
                    7 different parts integrated into one reproducible system.
                  </p>
                </div>

                <div className="rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                  <h3 className="mb-2 font-semibold">Environment Agnostic</h3>

                  <p className="text-sm leading-6 text-zinc-600 dark:text-zinc-400">
                    Multiple tech stacks working together with minimal
                    redundancy.
                  </p>
                </div>

                <div className="rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                  <h3 className="mb-2 font-semibold">Simple Onboarding</h3>

                  <p className="text-sm leading-6 text-zinc-600 dark:text-zinc-400">
                    Developers can start contributing in only 3 steps.
                  </p>
                </div>
              </div>
            </section>

            {/* About */}
            <section id="about" className="space-y-6 scroll-mt-24">
              <h2 className="text-3xl font-bold">About</h2>

              <div className="rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <ul className="list-disc space-y-4 pl-6 leading-7 text-zinc-700 dark:text-zinc-300">
                  <li>
                    It has 7 different parts to it, all integrated and managed
                    into one polyglot monorepo.
                  </li>

                  <li>
                    All parts use different tech stacks and are designed to work
                    together with no redundancies while remaining environment
                    agnostic.
                  </li>

                  <li>
                    Developer onboarding does not exceed more than 3 steps.
                  </li>
                </ul>
              </div>
            </section>

            {/* Development */}
            <section id="development" className="space-y-12 scroll-mt-24">
              <div className="space-y-3">
                <h2 className="text-3xl font-bold">Development</h2>

                <p className="text-zinc-700 dark:text-zinc-300">
                  This section is targeted towards developers who are or will be
                  contributing to this project. (Development on Windows is not
                  supported, because of enshittification)
                </p>
              </div>

              {/* Philosophy */}
              <div
                id="philosophy"
                className="space-y-4 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
              >
                <h3 className="text-2xl font-semibold">Philosophy</h3>

                <p className="leading-8 text-zinc-700 dark:text-zinc-300">
                  Every single thing needs to be reproducible on any machine. No
                  more than 3 steps to start working on the project, among
                  which, 2 of them are only the prerequisites.
                </p>
              </div>

              {/* Project Structure */}
              <div
                id="project-structure"
                className="space-y-4 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
              >
                <div className="space-y-2">
                  <h3 className="text-2xl font-semibold">Project Structure</h3>

                  <p className="text-zinc-700 dark:text-zinc-300">
                    This project is divided into multiple parts as follows.
                  </p>
                </div>

                <div className="overflow-x-auto">
                  <table className="min-w-full border-collapse text-left text-sm">
                    <thead>
                      <tr className="border-b border-zinc-200 dark:border-zinc-700">
                        <th className="px-4 py-3 font-semibold">Sub-Part</th>
                        <th className="px-4 py-3 font-semibold">Tech</th>
                        <th className="px-4 py-3 font-semibold">
                          Development Status
                        </th>
                        <th className="px-4 py-3 font-semibold">Extra Notes</th>
                      </tr>
                    </thead>

                    <tbody className="text-zinc-700 dark:text-zinc-300">
                      {[
                        ["API", "Rust", "Live"],
                        ["Web App", "Python", "Live"],
                        ["Android App", "Kotlin", "Live"],
                        ["Linux/Windows App", "C#", "Live"],
                        ["Database", "PostgreSQL", "Live"],
                        ["Cache", "Redis", "Planned"],
                        ["Project Website", "NextJS", "Live"],
                      ].map(([part, tech, status]) => (
                        <tr
                          key={part}
                          className="border-b border-zinc-100 dark:border-zinc-800"
                        >
                          <td className="px-4 py-3">{part}</td>
                          <td className="px-4 py-3">{tech}</td>
                          <td className="px-4 py-3">{status}</td>
                          <td className="px-4 py-3">-</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Setup */}
              <div
                id="setup"
                className="space-y-4 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
              >
                <h3 className="text-2xl font-semibold">Setup</h3>

                <ol className="list-decimal space-y-4 pl-6 leading-7 text-zinc-700 dark:text-zinc-300">
                  <li>
                    Install{" "}
                    <a
                      href="https://nixos.org/download/"
                      className="font-medium text-blue-600 hover:underline"
                    >
                      Nix
                    </a>
                  </li>

                  <li>Clone the repository</li>

                  <li>
                    Run{" "}
                    <code className="rounded bg-zinc-200 px-2 py-1 text-sm dark:bg-zinc-800">
                      ./scripts/ironbook.sh setup
                    </code>
                  </li>
                </ol>
                <p>
                  Note: For Windows setup, install{" "}
                  <a
                    href="https://learn.microsoft.com/en-us/windows/wsl/install"
                    className="font-medium text-blue-600 hover:underline"
                  >
                    WSL
                  </a>{" "}
                  then follow the instructions for Linux
                </p>
              </div>
            </section>

            {/* Users */}
            <section id="users" className="space-y-12 scroll-mt-24">
              <div className="space-y-2">
                <h2 className="text-3xl font-bold">Users</h2>

                <p className="text-zinc-700 dark:text-zinc-300">
                  This section is targeted towards the users of this project.
                </p>
              </div>

              {/* Features */}
              <div
                id="features"
                className="space-y-4 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
              >
                <h3 className="text-2xl font-semibold">Features</h3>

                <ul className="list-disc pl-6 text-zinc-700 dark:text-zinc-300">
                  <li>None</li>
                </ul>
              </div>

              {/* Complaints */}
              <div
                id="complaints"
                className="space-y-4 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
              >
                <h3 className="text-2xl font-semibold">Complaints</h3>

                <p className="text-zinc-700 dark:text-zinc-300">
                  Open an issue on{" "}
                  <a
                    href="https://github.com/ironbook-labs/ironbook"
                    className="font-medium text-blue-600 hover:underline"
                  >
                    GitHub
                  </a>
                  .
                </p>
              </div>

              {/* Self Deployment */}
              <div
                id="self-deployment"
                className="space-y-4 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
              >
                <h3 className="text-2xl font-semibold">Self Deployment</h3>

                <ul className="list-disc pl-6 text-zinc-700 dark:text-zinc-300">
                  <li>
                    <a
                      href="/docs/home"
                      className="font-medium text-blue-600 hover:underline"
                    >
                      Home / Docs Site
                    </a>
                  </li>
                </ul>
              </div>
            </section>
          </div>
        </main>
      </div>
    </div>
  );
}
