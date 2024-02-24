export default function GardenCell({ cellNumber }: { cellNumber: number }) {
  return <div className="border border-white w-full p-2">{cellNumber}</div>;
}
