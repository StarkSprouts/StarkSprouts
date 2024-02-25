import { Button } from "./components/ui/button";

function App() {
  const handleInitWorld = () => {
    console.log("Init World");
  };
  return (
    <div className="relative w-screen h-screen flex flex-col">
      <main className="flex flex-col left-0 relative top-0 overflow-hidden grow">
        <div>
          <Button label="Init World" onPress={handleInitWorld} />
        </div>
      </main>
    </div>
  );
}

export default App;
