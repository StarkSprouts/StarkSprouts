import { StyledButton } from "./StyledButton";

export const TopBar = () => {
  return (
    <div className="bg-neutral-900 w-screen h-2">
      <StyledButton>
        <a href="/game">Launch App</a>
      </StyledButton>
    </div>
  );
};
