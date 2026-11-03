export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center bg-slate-50 p-6 text-center">
      <h1 className="text-4xl font-bold text-blue-700">Pro Pacers</h1>
      <p className="mt-3 text-slate-600">
        Attendance, payments and progress for every young athlete.
      </p>
      <button className="mt-8 rounded-lg bg-blue-600 px-6 py-3 font-semibold text-white">
        Login with mobile number
      </button>
    </main>
  );
}