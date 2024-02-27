import { StyledButton } from "./StyledButton";

export const TopBar = () => {
  return (
    <div className=" flex justify-between items-center bg-neutral-900 w-screen">
      <div className="flex items-center">
        <img
          className="ml-2"
          src="static/logo.png"
          alt="Logo"
          width="50"
          height="50"
        />
        <h6 className="text-white ml-2">Stark Sprouts</h6>
      </div>
      <h3 className="text-xl text-white mr-2">
        Starknet Hacker House Denver 2024
      </h3>
    </div>
  );
};
