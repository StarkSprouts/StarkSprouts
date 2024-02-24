export default function GardenCell({ cellNumber }: { cellNumber: number }) {
  return <div className="border border-white w-10 h-10 m-1">{cellNumber}</div>;
}
