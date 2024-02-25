"use client";

import { Button } from "@/components/Button";
import { useDojo } from "@/dojo/useDojo";

const TestPage = () => {
  const { account, setup } = useDojo();
  const handleSetupWorld = async () => {
    console.log("Setting up world");
  };

  return (
    <div className="flex justify-center items-center flex-col">
      <h1>Test Page</h1>
      <Button onClick={handleSetupWorld}>Setup World</Button>
    </div>
  );
};

export default TestPage;
