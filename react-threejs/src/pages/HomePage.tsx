import { Nav } from "@/components/ui/nav";

export default function HomePage() {
  return (
    <main className="relative w-screen h-screen">
      <Nav />
      <img
        src="../../assets/logo.png"
        alt="Stark Sprouts"
        width={100}
        height={100}
      />
    </main>
  );
}
