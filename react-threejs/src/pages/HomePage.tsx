import { TopBar } from "@/components/TopBar";

export default function HomePage() {
  return (
    <main className="w-screen h-screen">
      <TopBar />
      <div className="flex justify-center items-center flex-col ">
        <h1 className="text-6xl">Welcome to Stark Sprouts</h1>
        <img
          src="../assets/logo.png"
          alt="Stark Sprouts"
          width={200}
          height={200}
        />
      </div>
    </main>
  );
}
