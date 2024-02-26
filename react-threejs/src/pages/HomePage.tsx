import { Nav } from "@/components/ui/Nav";

export default function HomePage() {
  return (
    <main className="relative w-screen h-screen">
      <Nav />
      <div className="flex justify-center items-center flex-col mt-20">
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
