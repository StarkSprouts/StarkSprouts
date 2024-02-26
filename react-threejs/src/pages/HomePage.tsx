import { TopBar } from "@/components/TopBar";

export default function HomePage() {
  return (
    <div className="flex flex-row w-screen h-screen bg-slate-400">
      <div>
        <TopBar />
      </div>
      <div className="flex justify-center items-center flex-col">
        <h1 className="text-6xl">Welcome to Stark Sprouts</h1>
        <img
          src="../static/logo.png"
          alt="Stark Sprouts"
          width={200}
          height={200}
        />
      </div>
    </div>
  );
}
