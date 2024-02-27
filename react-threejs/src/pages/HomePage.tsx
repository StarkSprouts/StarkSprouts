import { TopBar } from "@/components/TopBar";
import { StyledButton } from "../components/StyledButton";

export default function HomePage() {
  return (
    <div className="flex flex-col h-screen bg-banner bg-center bg-cover bg-no-repeat">
      <TopBar />
      <div className="flex-grow flex justify-center mt-5">
        <div className="flex items-center flex-col mb-4 ml-8">
          <h1 className="text-6xl mb-4 text-white">Welcome to Stark Sprouts</h1>

          <StyledButton>
            <a href="/game">Launch App</a>
          </StyledButton>
        </div>
      </div>
    </div>
  );
}
